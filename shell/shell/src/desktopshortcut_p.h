#pragma once

#include <QFile>
#include <QString>
#include <functional>

namespace DesktopShortcutPrivate {
enum class CopyResult { Success, CopyFailed, PermissionsFailed };
using PermissionSetter = std::function<bool(const QString &, QFile::Permissions)>;

CopyResult copyExecutableShortcut(const QString &source, const QString &destination,
                                  const PermissionSetter &setPermissions);
} // namespace DesktopShortcutPrivate
