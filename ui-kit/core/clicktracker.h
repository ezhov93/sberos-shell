#pragma once

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusPendingCall>
#include <QDBusPendingCallWatcher>
#include <QObject>
#include <QtQmlIntegration>

class ClickTracker : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("ClickTracker is for C++ instantiation only")

  friend class Core;

public:
  Q_INVOKABLE void registerClick(QObject *element);

signals:
  void clickFailed(const QString &sourceId, const QString &elementId);

protected:
  explicit ClickTracker(QObject *parent = nullptr);
  ~ClickTracker() override = default;

private:
  static QString qmlName(const QObject *obj);
  void callDBusRegisterClick(const QString &sourceId, const QString &elementId);

  QDBusInterface m_dbus;
};

Q_DECLARE_METATYPE(ClickTracker *)
Q_DECLARE_METATYPE(ClickTracker)
