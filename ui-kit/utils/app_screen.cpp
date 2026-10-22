#include "app_screen.h"

#include <QCoreApplication>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QQuickWindow>

#include <type_registration.h>
REGISTER_SINGLETON_TYPE(AppScreen, "Sber.Utils", QString(VERSION_MAJOR).toInt(), QString(VERSION_MINOR).toInt(), "AppScreen")

namespace {
    static const QString NotifyTitle = "Снимок экрана сделан";
    static const QString NotifyBody = "Вы можете вставить изображение из буфера обмена";
    static const QString NotifyIcon = "dialog-information";
    static const QString NotifyDBusService = "org.freedesktop.Notifications";
    static const QString NotifyDBusPath = "/org/freedesktop/Notifications";
    static const QString NotifyDBusInterface = "org.freedesktop.Notifications";
}

AppScreen::AppScreen(QObject *parent)
    : QObject{parent}
{}

void AppScreen::create(QObject* appWindow)
{
    QQuickWindow *window = qobject_cast<QQuickWindow*>(appWindow);
    if (!window) {
        return;
    }

    const auto image = window->grabWindow();
    if (image.isNull()) {
        return;
    }

    static QString directory;

    if (directory.isEmpty()) {
        directory = screenshotsDir();

        QDir dir;
        if (!dir.exists(directory)) {
            dir.mkpath(directory);
        }
    }

    const auto now = QDateTime::currentDateTime();
    const auto filename = QCoreApplication::translate("Utils", "Screenshot From") +
                          now.toString("' 'yyyy-MM-dd HH-mm-ss") + ".png";
    m_fullPath = directory + "/" + filename;

    image.save(m_fullPath);

    notify();
}

void AppScreen::notificationActionInvoked(uint notificationId, QString actionKey)
{
    Q_UNUSED(notificationId);

    if (actionKey == "open-folder") {
      QProcess::startDetached("nautilus", {"--select", m_fullPath});
    }
}

void AppScreen::notify()
{
    static QDBusInterface notifications(
        NotifyDBusService,
        NotifyDBusPath,
        NotifyDBusInterface,
        QDBusConnection::sessionBus()
        );

    if (!notifications.isValid()) {
        qDebug() << "D-Bus connection failed:" << QDBusConnection::sessionBus().lastError().message();
        return;
    }

    const QVariantMap hints{{"image-path", m_fullPath}, {"urgency", 1}};
    const QStringList actions{"open-folder", "Открыть папку"};

    QDBusConnection::sessionBus().connect(
        NotifyDBusService,
        NotifyDBusPath,
        NotifyDBusInterface,
        "ActionInvoked",
        this,
        SLOT(notificationActionInvoked(uint, QString))
        );

    QDBusPendingCall call = notifications.asyncCall(
        "Notify",
        QCoreApplication::applicationName(),
        0U,
        NotifyIcon,
        NotifyTitle,
        NotifyBody,
        actions,
        hints,
        5000
        );
}

QString AppScreen::screenshotsDir() {
    auto picturesDir = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);

    if (picturesDir.isEmpty()) {
        picturesDir = QDir::homePath();
    }

    const auto screenDir = QCoreApplication::translate("Utils", "Screenshots");

    return QDir(picturesDir).filePath(screenDir);
}
