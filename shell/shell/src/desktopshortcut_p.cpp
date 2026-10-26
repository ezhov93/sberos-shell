#include "desktopshortcut_p.h"

namespace DesktopShortcutPrivate {
CopyResult copyExecutableShortcut(const QString &source, const QString &destination,
                                  const PermissionSetter &setPermissions) {
    if (!QFile::copy(source, destination))
        return CopyResult::CopyFailed;

    const QFile::Permissions permissions =
        QFile::permissions(destination) | QFile::ExeOwner | QFile::ExeGroup | QFile::ExeOther;
    if (setPermissions(destination, permissions))
        return CopyResult::Success;

    QFile::remove(destination);
    return CopyResult::PermissionsFailed;
}
} // namespace DesktopShortcutPrivate
