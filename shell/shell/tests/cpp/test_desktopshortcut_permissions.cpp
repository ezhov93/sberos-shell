#include "desktopshortcut_p.h"

#include <QFileInfo>
#include <QTemporaryDir>
#include <QtTest>

class DesktopShortcutPermissionsTest : public QObject {
    Q_OBJECT

private slots:
    void failedPermissionChangeRemovesPartialShortcut();
};

void DesktopShortcutPermissionsTest::failedPermissionChangeRemovesPartialShortcut() {
    QTemporaryDir directory;
    QVERIFY(directory.isValid());
    const QString source = directory.filePath(QStringLiteral("source.desktop"));
    const QString destination = directory.filePath(QStringLiteral("shortcut.desktop"));
    QFile file(source);
    QVERIFY(file.open(QIODevice::WriteOnly));
    QCOMPARE(file.write("[Desktop Entry]\nType=Application\nExec=true\n"), 43);
    file.close();

    QString permissionPath;
    const auto result = DesktopShortcutPrivate::copyExecutableShortcut(
        source, destination, [&permissionPath](const QString &path, QFile::Permissions) {
            permissionPath = path;
            return false;
        });

    QCOMPARE(result, DesktopShortcutPrivate::CopyResult::PermissionsFailed);
    QCOMPARE(permissionPath, destination);
    QVERIFY(!QFileInfo::exists(destination));
}

QTEST_GUILESS_MAIN(DesktopShortcutPermissionsTest)
#include "test_desktopshortcut_permissions.moc"
