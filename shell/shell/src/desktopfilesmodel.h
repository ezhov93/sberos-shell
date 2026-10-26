#pragma once

#include <QObject>
#include <QFileSystemWatcher>
#include <QSettings>
#include <QVariantList>
#include <qqml.h>

class DesktopFilesModel final : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(DesktopFiles)
    QML_SINGLETON
    Q_PROPERTY(QString directory READ directory CONSTANT)
    Q_PROPERTY(QString sortMode READ sortMode NOTIFY presentationChanged)
    Q_PROPERTY(int iconSize READ iconSize NOTIFY presentationChanged)
    Q_PROPERTY(int iconSpacing READ iconSpacing NOTIFY presentationChanged)
public:
    explicit DesktopFilesModel(QObject *parent = nullptr);
    QString directory() const {
        return m_directory;
    }
    QString sortMode() const {
        return m_sortMode;
    }
    int iconSize() const {
        return m_iconSize;
    }
    int iconSpacing() const {
        return m_iconSpacing;
    }

    Q_INVOKABLE QVariantList entriesForOutput(const QString &output) const;
    Q_INVOKABLE void configureOutputs(const QStringList &outputs, const QString &primaryOutput);
    Q_INVOKABLE void moveEntry(const QString &path, const QString &output, int slot);
    Q_INVOKABLE void setSortMode(const QString &mode);
    Q_INVOKABLE void setIconSize(int size);
    Q_INVOKABLE void setIconSpacing(int spacing);
    Q_INVOKABLE void openEntry(const QString &path);
    Q_INVOKABLE bool createApplicationShortcut(const QString &storageId);
    Q_INVOKABLE void renameEntry(const QString &path, const QString &name);
    Q_INVOKABLE void createFolder(const QString &name);
    Q_INVOKABLE void trashEntry(const QString &path);
    Q_INVOKABLE void refresh();

signals:
    void changed();
    void presentationChanged();
    void operationFailed(const QString &message);

private:
    struct Entry {
        QString path;
        QString name;
        QString icon;
        bool directory = false;
        bool desktopFile = false;
    };
    void loadSettings();
    void saveSettings();
    int slotFor(const QString &path, const QString &output) const;
    QString ownerFor(const QString &path) const;
    void persistPlacement(const QString &path, const QString &output, int slot);
    void rewatchDirectory();

    QString m_directory;
    QString m_primaryOutput;
    QStringList m_outputs;
    QList<Entry> m_entries;
    QHash<QString, QString> m_owners;
    QHash<QString, int> m_slots;
    QString m_sortMode = QStringLiteral("manual");
    int m_iconSize = 64;
    int m_iconSpacing = 24;
    QSettings m_settings;
    QFileSystemWatcher m_watcher;
};
