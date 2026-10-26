#pragma once

#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QString>

namespace SberComponents {

inline QString resourcePath(const QString &relativePath, bool directory = false) {
    const QString overridePath = qEnvironmentVariable("SBER_COMPONENTS_DATA_DIR");
    if (!overridePath.isEmpty()) {
        const QString candidate = QDir(overridePath).filePath(relativePath);
        if (QFileInfo::exists(candidate))
            return candidate;
    }

    const QString sourcePath = QDir(QStringLiteral(THEME_RESOURCES_PATH)).filePath(relativePath);
    if (QFileInfo::exists(sourcePath))
        return sourcePath;

    const QString installedPath = QStandardPaths::locate(
        QStandardPaths::GenericDataLocation, QStringLiteral("SberComponents/") + relativePath,
        directory ? QStandardPaths::LocateDirectory : QStandardPaths::LocateFile);
    if (!installedPath.isEmpty())
        return installedPath;

    return sourcePath;
}

} // namespace SberComponents
