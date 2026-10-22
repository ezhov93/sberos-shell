#include <dbus_image.h>
#include <notifier.h>

#include <QApplication>
#include <QDBusInterface>
#include <QDBusMetaType>


Notifier::Notifier(QObject* parent)
  : QObject(parent) {
}

Notice Notifier::createNotify() const {
  return Notice();
}

void Notifier::sendNotify(const Notice& message) const {
  emit newNotify(message);
}

void Notifier::sendSystemNotify(const Notice& message) const {
  QDBusInterface dbus("org.freedesktop.Notifications",
                      "/org/freedesktop/Notifications",
                      "org.freedesktop.Notifications",
                      QDBusConnection::sessionBus());

  QVariantList args;
  args << qApp->applicationName();
  args << uint(0);
  args << "";
  args << message.title;
  args << message.text;
  args << QStringList();

  QVariantMap hints;
  if (!message.iconName.isEmpty()) {
    hints["image-path"] = "file://" + QString(THEME_RESOURCES_PATH) + "/icons/36/" + message.iconName + ".svg";
  } else if (!message.iconPath.isEmpty()) {
    hints["image-path"] = "file://" + message.iconPath;
  } else if (!message.image.isNull()) {
    auto type = qDBusRegisterMetaType<IIIBIIAY>();
    IIIBIIAY img(message.image);
    hints["image-data"] = QVariant(type, &img);
  }
  args << hints;
  args << message.timeout;

  dbus.callWithArgumentList(QDBus::AutoDetect, "Notify", args);
}

void Notifier::sendSystemNotify(const QString& title, const QString& message) const {
  sendSystemNotify(Notice(title, message));
}
