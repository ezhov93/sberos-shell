#include "desktopfilesmodel.h"
#include "desktopshortcut_p.h"

#include <KIO/ApplicationLauncherJob>
#include <KIO/OpenUrlJob>
#include <KIO/CopyJob>
#include <KIO/Job>
#include <KService>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QStandardPaths>
#include <QUrl>
#include <algorithm>
#include <utility>

DesktopFilesModel::DesktopFilesModel(QObject *parent)
    : QObject(parent),
      m_directory(QStandardPaths::writableLocation(QStandardPaths::DesktopLocation)),
      m_settings(QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) +
                     QStringLiteral("/desktop-files.ini"),
                 QSettings::IniFormat) {
    if (m_directory.isEmpty())
        m_directory = QDir::homePath() + QStringLiteral("/Desktop");
    QDir().mkpath(m_directory);
    loadSettings();
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged, this, &DesktopFilesModel::refresh);
    connect(&m_watcher, &QFileSystemWatcher::fileChanged, this, &DesktopFilesModel::refresh);
    refresh();
}

void DesktopFilesModel::loadSettings() {
    m_sortMode = m_settings.value(QStringLiteral("sortMode"), QStringLiteral("manual")).toString();
    if (m_sortMode != QLatin1String("manual") && m_sortMode != QLatin1String("name") &&
        m_sortMode != QLatin1String("type"))
        m_sortMode = QStringLiteral("manual");
    m_iconSize = std::clamp(m_settings.value(QStringLiteral("iconSize"), 64).toInt(), 48, 96);
    m_iconSpacing = std::clamp(m_settings.value(QStringLiteral("iconSpacing"), 24).toInt(), 12, 48);
    const auto owners = m_settings.value(QStringLiteral("owners")).toMap();
    for (auto it = owners.cbegin(); it != owners.cend(); ++it)
        m_owners.insert(it.key(), it.value().toString());
    const auto savedSlots = m_settings.value(QStringLiteral("slots")).toMap();
    for (auto it = savedSlots.cbegin(); it != savedSlots.cend(); ++it)
        m_slots.insert(it.key(), it.value().toInt());
}

void DesktopFilesModel::saveSettings() {
    QVariantMap owners;
    for (auto it = m_owners.cbegin(); it != m_owners.cend(); ++it)
        owners.insert(it.key(), it.value());
    QVariantMap savedSlots;
    for (auto it = m_slots.cbegin(); it != m_slots.cend(); ++it)
        savedSlots.insert(it.key(), it.value());
    m_settings.setValue(QStringLiteral("owners"), owners);
    m_settings.setValue(QStringLiteral("slots"), savedSlots);
    m_settings.setValue(QStringLiteral("sortMode"), m_sortMode);
    m_settings.setValue(QStringLiteral("iconSize"), m_iconSize);
    m_settings.setValue(QStringLiteral("iconSpacing"), m_iconSpacing);
    m_settings.sync();
}

QString DesktopFilesModel::ownerFor(const QString &path) const {
    return m_owners.value(path, m_primaryOutput);
}

int DesktopFilesModel::slotFor(const QString &path, const QString &output) const {
    return m_slots.value(output + QLatin1Char('\n') + path, -1);
}

void DesktopFilesModel::persistPlacement(const QString &path, const QString &output, int slot) {
    m_owners.insert(path, output);
    m_slots.insert(output + QLatin1Char('\n') + path, (std::max)(0, slot));
}

void DesktopFilesModel::configureOutputs(const QStringList &outputs, const QString &primaryOutput) {
    m_outputs = outputs;
    const QString fallbackOutput =
        m_outputs.contains(QStringLiteral("DP-7"))
            ? QStringLiteral("DP-7")
            : (m_outputs.contains(primaryOutput)
                   ? primaryOutput
                   : (m_outputs.isEmpty() ? QString() : m_outputs.first()));
    m_primaryOutput = fallbackOutput;
    if (m_primaryOutput.isEmpty())
        return;

    // New items start on DP-7 when it is connected (otherwise the primary
    // output). Existing items stay on their selected output; if it disconnects,
    // move them once to the fallback output while preserving their grid order.
    QList<Entry> ordered = m_entries;
    std::sort(ordered.begin(), ordered.end(), [this](const Entry &left, const Entry &right) {
        const QString leftOwner = ownerFor(left.path), rightOwner = ownerFor(right.path);
        if (leftOwner != rightOwner)
            return leftOwner < rightOwner;
        const int leftSlot = slotFor(left.path, leftOwner),
                  rightSlot = slotFor(right.path, rightOwner);
        if (leftSlot != rightSlot) {
            if (leftSlot < 0)
                return false;
            if (rightSlot < 0)
                return true;
            return leftSlot < rightSlot;
        }
        return left.name.localeAwareCompare(right.name) < 0;
    });
    QHash<QString, int> nextSlots;
    bool changedPlacement = false;
    for (const Entry &entry : std::as_const(ordered)) {
        QString owner = ownerFor(entry.path);
        int slot = slotFor(entry.path, owner);
        if (!m_outputs.contains(owner)) {
            if (!m_primaryOutput.isEmpty() && owner != m_primaryOutput)
                m_slots.remove(owner + QLatin1Char('\n') + entry.path);
            owner = m_primaryOutput;
            slot = -1;
        }
        int &next = nextSlots[owner];
        if (next == 0) {
            for (const Entry &other : std::as_const(ordered)) {
                if (ownerFor(other.path) == owner)
                    next = (std::max)(next, slotFor(other.path, owner) + 1);
            }
        }
        if (slot < 0) {
            slot = next++;
            persistPlacement(entry.path, owner, slot);
            changedPlacement = true;
        } else if (owner != ownerFor(entry.path)) {
            persistPlacement(entry.path, owner, slot);
            changedPlacement = true;
        }
    }
    if (changedPlacement)
        saveSettings();
    emit changed();
}

QVariantList DesktopFilesModel::entriesForOutput(const QString &output) const {
    QList<Entry> entries;
    for (const Entry &entry : m_entries)
        if (ownerFor(entry.path) == output)
            entries.push_back(entry);
    std::sort(entries.begin(), entries.end(),
              [this, &output](const Entry &left, const Entry &right) {
                  const int leftSlot = slotFor(left.path, output),
                            rightSlot = slotFor(right.path, output);
                  if (m_sortMode == QLatin1String("name"))
                      return left.name.localeAwareCompare(right.name) < 0;
                  if (m_sortMode == QLatin1String("type")) {
                      const QString leftType = QFileInfo(left.path).suffix().toCaseFolded();
                      const QString rightType = QFileInfo(right.path).suffix().toCaseFolded();
                      if (leftType != rightType)
                          return leftType < rightType;
                      return left.name.localeAwareCompare(right.name) < 0;
                  }
                  if (leftSlot != rightSlot) {
                      if (leftSlot < 0)
                          return false;
                      if (rightSlot < 0)
                          return true;
                      return leftSlot < rightSlot;
                  }
                  return left.name.localeAwareCompare(right.name) < 0;
              });
    QVariantList result;
    for (int i = 0; i < entries.size(); ++i) {
        const Entry &entry = entries.at(i);
        result.push_back(
            QVariantMap{{QStringLiteral("path"), entry.path},
                        {QStringLiteral("name"), entry.name},
                        {QStringLiteral("icon"), entry.icon},
                        {QStringLiteral("isDirectory"), entry.directory},
                        {QStringLiteral("isDesktopFile"), entry.desktopFile},
                        {QStringLiteral("slot"),
                         m_sortMode == QLatin1String("manual")
                             ? (slotFor(entry.path, output) >= 0 ? slotFor(entry.path, output) : i)
                             : i}});
    }
    return result;
}

void DesktopFilesModel::moveEntry(const QString &path, const QString &output, int slot) {
    if (!m_outputs.contains(output) || slot < 0 || QFileInfo(path).absolutePath() != m_directory)
        return;
    if (m_sortMode != QLatin1String("manual"))
        setSortMode(QStringLiteral("manual"));
    const QString sourceOutput = ownerFor(path);
    const int sourceSlot = slotFor(path, sourceOutput);
    const QVariantList current = entriesForOutput(output);
    QString occupant;
    for (const QVariant &value : current) {
        const QVariantMap item = value.toMap();
        if (item.value(QStringLiteral("path")).toString() != path &&
            item.value(QStringLiteral("slot")).toInt() == slot)
            occupant = item.value(QStringLiteral("path")).toString();
    }
    if (!occupant.isEmpty() && !sourceOutput.isEmpty() && sourceSlot >= 0)
        persistPlacement(occupant, sourceOutput, sourceSlot);
    persistPlacement(path, output, slot);
    saveSettings();
    emit changed();
}

void DesktopFilesModel::setSortMode(const QString &mode) {
    if (mode != QLatin1String("manual") && mode != QLatin1String("name") &&
        mode != QLatin1String("type"))
        return;
    if (m_sortMode == mode)
        return;
    m_sortMode = mode;
    saveSettings();
    emit presentationChanged();
    emit changed();
}

void DesktopFilesModel::setIconSize(int size) {
    size = std::clamp(size, 48, 96);
    if (m_iconSize == size)
        return;
    m_iconSize = size;
    saveSettings();
    emit presentationChanged();
}

void DesktopFilesModel::setIconSpacing(int spacing) {
    spacing = std::clamp(spacing, 12, 48);
    if (m_iconSpacing == spacing)
        return;
    m_iconSpacing = spacing;
    saveSettings();
    emit presentationChanged();
}

void DesktopFilesModel::openEntry(const QString &path) {
    const QFileInfo info(path);
    if (!info.exists() || (path != m_directory && info.absolutePath() != m_directory)) {
        emit operationFailed(tr("This desktop item is no longer available."));
        return;
    }
    if (info.isFile() &&
        info.suffix().compare(QStringLiteral("desktop"), Qt::CaseInsensitive) == 0) {
        const KService::Ptr service = KService::serviceByDesktopPath(path);
        if (service && service->isValid()) {
            auto *job = new KIO::ApplicationLauncherJob(service, this);
            connect(job, &KJob::result, this, [this](KJob *finished) {
                if (finished->error())
                    emit operationFailed(finished->errorText());
            });
            job->start();
            return;
        }
    }
    auto *job = new KIO::OpenUrlJob(QUrl::fromLocalFile(path), this);
    connect(job, &KJob::result, this, [this](KJob *finished) {
        if (finished->error())
            emit operationFailed(finished->errorText());
    });
    job->start();
}

bool DesktopFilesModel::createApplicationShortcut(const QString &storageId) {
    const KService::Ptr service = KService::serviceByStorageId(storageId);
    if (!service || !service->isValid() || service->entryPath().isEmpty())
        return false;
    QString fileName = QFileInfo(storageId).fileName();
    if (fileName.isEmpty())
        fileName = service->desktopEntryName() + QStringLiteral(".desktop");
    if (!fileName.endsWith(QStringLiteral(".desktop"), Qt::CaseInsensitive))
        fileName += QStringLiteral(".desktop");
    const QString base = QFileInfo(fileName).completeBaseName();
    QString destination = m_directory + QLatin1Char('/') + fileName;
    for (int suffix = 1; QFileInfo::exists(destination); ++suffix)
        destination = m_directory + QLatin1Char('/') + base +
                      QStringLiteral("-shortcut-%1.desktop").arg(suffix);
    const auto result = DesktopShortcutPrivate::copyExecutableShortcut(
        service->entryPath(), destination,
        [](const QString &path, QFile::Permissions permissions) {
            return QFile::setPermissions(path, permissions);
        });
    if (result == DesktopShortcutPrivate::CopyResult::CopyFailed) {
        emit operationFailed(tr("Could not add this application to the desktop."));
        return false;
    }
    if (result == DesktopShortcutPrivate::CopyResult::PermissionsFailed) {
        emit operationFailed(tr("Could not set permissions for the application shortcut."));
        return false;
    }
    refresh();
    return true;
}

void DesktopFilesModel::renameEntry(const QString &path, const QString &name) {
    const QString trimmed = name.trimmed();
    if (QFileInfo(path).absolutePath() != m_directory || trimmed.isEmpty() ||
        trimmed == QLatin1String(".") || trimmed == QLatin1String("..") ||
        trimmed.contains(QLatin1Char('/')))
        return;
    const QFileInfo info(path);
    if (!QDir(m_directory).rename(info.fileName(), trimmed)) {
        emit operationFailed(tr("Could not rename this desktop item."));
        return;
    }
    const QString next = m_directory + QLatin1Char('/') + trimmed;
    const QString oldOwner = m_owners.take(path);
    const int oldSlot = m_slots.take(oldOwner + QLatin1Char('\n') + path);
    if (!oldOwner.isEmpty())
        m_owners.insert(next, oldOwner);
    if (oldSlot >= 0)
        m_slots.insert(oldOwner + QLatin1Char('\n') + next, oldSlot);
    saveSettings();
    refresh();
}

void DesktopFilesModel::createFolder(const QString &name) {
    const QString trimmed = name.trimmed();
    if (trimmed.isEmpty() || trimmed == QLatin1String(".") || trimmed == QLatin1String("..") ||
        trimmed.contains(QLatin1Char('/')))
        return;
    if (!QDir(m_directory).mkdir(trimmed)) {
        emit operationFailed(tr("Could not create this folder."));
        return;
    }
    refresh();
}

void DesktopFilesModel::trashEntry(const QString &path) {
    if (QFileInfo(path).absolutePath() != m_directory || !QFileInfo::exists(path))
        return;
    auto *job = KIO::trash(QList<QUrl>{QUrl::fromLocalFile(path)});
    connect(job, &KJob::result, this, [this, path](KJob *finished) {
        if (finished->error()) {
            emit operationFailed(finished->errorText());
            return;
        }
        m_owners.remove(path);
        for (auto it = m_slots.begin(); it != m_slots.end();) {
            if (it.key().endsWith(QStringLiteral("\n") + path))
                it = m_slots.erase(it);
            else
                ++it;
        }
        saveSettings();
        refresh();
    });
    job->start();
}

void DesktopFilesModel::rewatchDirectory() {
    const QStringList oldDirectories = m_watcher.directories();
    if (!oldDirectories.isEmpty())
        m_watcher.removePaths(oldDirectories);
    const QStringList oldFiles = m_watcher.files();
    if (!oldFiles.isEmpty())
        m_watcher.removePaths(oldFiles);
    m_watcher.addPath(m_directory);
    for (const Entry &entry : std::as_const(m_entries))
        if (QFileInfo(entry.path).isFile())
            m_watcher.addPath(entry.path);
}

void DesktopFilesModel::refresh() {
    QList<Entry> next;
    QDir dir(m_directory);
    QMimeDatabase mimeDb;
    const QFileInfoList files = dir.entryInfoList(
        QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Hidden, QDir::Name | QDir::DirsFirst);
    for (const QFileInfo &file : files) {
        if (file.fileName().startsWith(QLatin1Char('.')))
            continue;
        const QMimeType mime = mimeDb.mimeTypeForFile(file.filePath(), QMimeDatabase::MatchDefault);
        Entry entry;
        entry.path = file.absoluteFilePath();
        entry.name = file.fileName();
        entry.directory = file.isDir();
        entry.desktopFile = file.isFile() && file.suffix().compare(QStringLiteral("desktop"),
                                                                   Qt::CaseInsensitive) == 0;
        entry.icon = mime.iconName();
        if (entry.desktopFile) {
            const KService::Ptr service = KService::serviceByDesktopPath(entry.path);
            if (service && service->isValid() && !service->icon().isEmpty())
                entry.icon = service->icon();
        }
        next.push_back(entry);
        if (!m_owners.contains(entry.path) && !m_primaryOutput.isEmpty())
            m_owners.insert(entry.path, m_primaryOutput);
    }
    m_entries = std::move(next);
    for (auto it = m_owners.begin(); it != m_owners.end();) {
        const bool exists =
            std::any_of(m_entries.cbegin(), m_entries.cend(),
                        [&it](const Entry &entry) { return entry.path == it.key(); });
        if (!exists)
            it = m_owners.erase(it);
        else
            ++it;
    }
    rewatchDirectory();
    saveSettings();
    emit changed();
}
