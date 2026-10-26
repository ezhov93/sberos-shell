#include "removable.h"

#include <QDBusConnection>
#include <QDBusObjectPath>
#include <QDBusMetaType>
#include <QCoreApplication>
#include <QtTest>

static const QString kUDisksService = QStringLiteral("org.freedesktop.UDisks2");
static const QString kBlockIface = QStringLiteral("org.freedesktop.UDisks2.Block");
static const QString kFilesystemIface = QStringLiteral("org.freedesktop.UDisks2.Filesystem");
static const QString kDriveIface = QStringLiteral("org.freedesktop.UDisks2.Drive");

class FakeObjectManager : public QObject {
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.DBus.ObjectManager")
public:
    ManagedObjects objects;

public slots:
    ManagedObjects GetManagedObjects() const { return objects; }
};

class FakeFilesystems : public QObject {
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.UDisks2.Filesystem")
public:
    int unmountCalls = 0;

public slots:
    void Unmount(const QVariantMap &) { ++unmountCalls; }
};

class FakeDrive : public QObject {
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.UDisks2.Drive")
public:
    int ejectCalls = 0;

public slots:
    void Eject(const QVariantMap &) { ++ejectCalls; }
};

class RemovableBusyEjectTest : public QObject {
    Q_OBJECT

private slots:
    void ejectRefusesDriveWithBusyFilesystem();
};

void RemovableBusyEjectTest::ejectRefusesDriveWithBusyFilesystem() {
    QDBusConnection bus = QDBusConnection::sessionBus();
    QVERIFY(bus.registerService(kUDisksService));

    FakeObjectManager objectManager;
    FakeFilesystems filesystems;
    FakeDrive drive;
    const QString drivePath = QStringLiteral("/org/freedesktop/UDisks2/drives/usb_disk");
    const QString firstBlock = QStringLiteral("/org/freedesktop/UDisks2/block_devices/sda1");
    const QString secondBlock = QStringLiteral("/org/freedesktop/UDisks2/block_devices/sda2");
    const auto block = [&drivePath](const QByteArray &device, const QString &label) {
        return QVariantMap{
            {QStringLiteral("Drive"), QVariant::fromValue(QDBusObjectPath(drivePath))},
            {QStringLiteral("PreferredDevice"), device},
            {QStringLiteral("Size"), qulonglong(1024 * 1024)},
            {QStringLiteral("IdLabel"), label},
            {QStringLiteral("HintIgnore"), false},
            {QStringLiteral("HintSystem"), false},
        };
    };
    const QVariantMap filesystem{{QStringLiteral("MountPoints"), QStringList{QStringLiteral("/media/test")}}};
    const QVariantMap driveProperties{{QStringLiteral("Removable"), true},
                                      {QStringLiteral("Ejectable"), true},
                                      {QStringLiteral("ConnectionBus"), QStringLiteral("usb")}};
    objectManager.objects.insert(QDBusObjectPath(drivePath), {{kDriveIface, driveProperties}});
    objectManager.objects.insert(QDBusObjectPath(firstBlock),
                                 {{kBlockIface, block(QByteArray("/dev/sda1"), QStringLiteral("First"))},
                                  {kFilesystemIface, filesystem}});
    objectManager.objects.insert(QDBusObjectPath(secondBlock),
                                 {{kBlockIface, block(QByteArray("/dev/sda2"), QStringLiteral("Second"))},
                                  {kFilesystemIface, filesystem}});

    QVERIFY(bus.registerObject(QStringLiteral("/org/freedesktop/UDisks2"), &objectManager,
                               QDBusConnection::ExportAllSlots));
    QVERIFY(bus.registerObject(firstBlock, &filesystems, QDBusConnection::ExportAllSlots));
    QVERIFY(bus.registerObject(secondBlock, &filesystems, QDBusConnection::ExportAllSlots));
    QVERIFY(bus.registerObject(drivePath, &drive, QDBusConnection::ExportAllSlots));

    RemovableModel model(bus, nullptr);
    QTRY_COMPARE_WITH_TIMEOUT(model.count(), 2, 1000);
    model.unmount(0); // marks one filesystem busy before its D-Bus reply is dispatched
    QVERIFY(model.data(model.index(0), RemovableModel::BusyRole).toBool());
    model.eject(1); // the other filesystem belongs to the same drive
    QVERIFY(!model.lastError().isEmpty());

    QTRY_COMPARE_WITH_TIMEOUT(filesystems.unmountCalls, 1, 1000);
    QCOMPARE(drive.ejectCalls, 0);

    bus.unregisterObject(QStringLiteral("/org/freedesktop/UDisks2"));
    bus.unregisterObject(firstBlock);
    bus.unregisterObject(secondBlock);
    bus.unregisterObject(drivePath);
    bus.unregisterService(kUDisksService);
}

QTEST_GUILESS_MAIN(RemovableBusyEjectTest)
#include "test_removable_busy_eject.moc"
