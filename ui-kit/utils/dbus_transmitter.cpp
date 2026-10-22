#include "dbus_transmitter.h"
#include <QDBusPendingCallWatcher>

#include <type_registration.h>
REGISTER_CREATABLE_TYPE(DBusTransmitter, "Sber.Utils", QString(VERSION_MAJOR).toInt(), QString(VERSION_MINOR).toInt(), "DBusTransmitter")


DBusTransmitter::DBusTransmitter(QObject* parent)
  : QObject(parent)
  , BusConnection(QDBusConnection::sessionBus()) {}

QString DBusTransmitter::serviceName() const {
  return ServiceName;
}

void DBusTransmitter::setServiceName(const QString& serviceName) {
  if (ServiceName != serviceName) {
    ServiceName = serviceName;
    if (UpdateInterface())
      emit serviceNameChanged();
  }
}

QString DBusTransmitter::objectPath() const {
  return ObjectPath;
}

void DBusTransmitter::setObjectPath(const QString& objectPath) {
  if (ObjectPath != objectPath) {
    ObjectPath = objectPath;
    if (UpdateInterface())
      emit objectPathChanged();
  }
}

QString DBusTransmitter::interfaceName() const {
  return InterfaceName;
}

void DBusTransmitter::setInterfaceName(const QString& interfaceName) {
  if (InterfaceName != interfaceName) {
    InterfaceName = interfaceName;
    if (UpdateInterface())
      emit interfaceNameChanged();
  }
}

QString DBusTransmitter::connection() const {
  return BusConnection.name();
}

void DBusTransmitter::setConnection(const QString& value) {
  if (value != BusConnection.name()) {
    BusConnection = QDBusConnection(value);
    if (UpdateInterface())
      emit connectionChanged();
  }
}

bool DBusTransmitter::UpdateInterface() {
  if (!ServiceName.isEmpty() && !ObjectPath.isEmpty() && !InterfaceName.isEmpty()) {
    if (Interface)
      Interface->deleteLater();

    Interface = new QDBusInterface(ServiceName, ObjectPath, InterfaceName, BusConnection, this);
    return true;
  }
  return false;
}

void DBusTransmitter::Convert(QVariantList& args) {
  for (auto& item : args) {
    QMap map = item.toMap();
    const QMetaType type(map.cbegin().key().toInt());
    item = map.cbegin().value();
    item.convert(type);
  }
}

QList<QVariant> DBusTransmitter::get(const QString& method, QVariantList args) const {
  if (!Interface)
    return {};

  Convert(args);
  QDBusMessage reply = Interface->callWithArgumentList(QDBus::BlockWithGui, method, args);

  if (reply.type() == QDBusMessage::ErrorMessage) {
    qWarning() << "DBus call failed:" << reply.errorMessage();
    return {};
  }

  if (!reply.arguments().isEmpty() && reply.arguments().at(0).userType() == qMetaTypeId<QDBusArgument>()) {
    const QDBusArgument& arg = reply.arguments().at(0).value<QDBusArgument>();
    QList<QVariant> list;

    arg.beginArray();
    while (!arg.atEnd()) {
      QVariant element;
      arg >> element;
      list.append(element);
    }
    arg.endArray();

    return list;
  }

  return reply.arguments();
}

void DBusTransmitter::set(const QString& method, QVariantList args) {
  if (!Interface) {
    emit asyncCallFailed("Interface is not exists");
    return;
  }

  Convert(args);
  QDBusPendingCall asyncCall = Interface->asyncCallWithArgumentList(method, args);
  QDBusPendingCallWatcher* watcher = new QDBusPendingCallWatcher(asyncCall, this);

  connect(watcher, &QDBusPendingCallWatcher::finished,
          this, &DBusTransmitter::onAsyncCallFinished, Qt::SingleShotConnection);
}

QVariant DBusTransmitter::getProperty(const QString& propertyName) const {
  if (Interface && Interface->isValid())
    return Interface->property(propertyName.toUtf8().constData());
  return QVariant();
}

void DBusTransmitter::setProperty(const QString& propertyName, const QVariant& value) {
  if (Interface && Interface->isValid())
    Interface->setProperty(propertyName.toUtf8().constData(), value);
}

void DBusTransmitter::onAsyncCallFinished(QDBusPendingCallWatcher* watcher) {
  QDBusPendingReply reply = *watcher;
  watcher->deleteLater();

  if (reply.isError())
    emit asyncCallFailed(reply.error().message());
  else
    emit asyncCallFinished(reply.reply().arguments());
}
