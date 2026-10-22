#pragma once

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QObject>
#include <QtQml/qqml.h>
#include <QVariant>


class DBusTransmitter : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString connection READ connection WRITE setConnection NOTIFY connectionChanged FINAL)
  Q_PROPERTY(QString serviceName READ serviceName WRITE setServiceName NOTIFY serviceNameChanged)
  Q_PROPERTY(QString objectPath READ objectPath WRITE setObjectPath NOTIFY objectPathChanged)
  Q_PROPERTY(QString interfaceName READ interfaceName WRITE setInterfaceName NOTIFY interfaceNameChanged)

public:
  explicit DBusTransmitter(QObject* parent = nullptr);

  Q_INVOKABLE QList<QVariant> get(const QString& method, QVariantList args = {}) const;
  Q_INVOKABLE void set(const QString& method, QVariantList args = {});
  Q_INVOKABLE QVariant getProperty(const QString& propertyName) const;
  Q_INVOKABLE void setProperty(const QString& propertyName, const QVariant& value);

  static void Convert(QVariantList& args);

signals:
  void serviceNameChanged();
  void objectPathChanged();
  void interfaceNameChanged();
  void connectionChanged();
  void asyncCallFinished(const QVariant& result);
  void asyncCallFailed(const QString& error);

private slots:
  void onAsyncCallFinished(QDBusPendingCallWatcher* watcher);

private:
  QString serviceName() const;
  void setServiceName(const QString& serviceName);
  QString objectPath() const;
  void setObjectPath(const QString& objectPath);
  QString interfaceName() const;
  void setInterfaceName(const QString& interfaceName);
  QString connection() const;
  void setConnection(const QString& value);

  bool UpdateInterface();

  QString ServiceName;
  QString ObjectPath;
  QString InterfaceName;
  QDBusConnection BusConnection;
  QDBusInterface* Interface = nullptr;
};
