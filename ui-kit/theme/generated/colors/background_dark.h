//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>


class BackgroundDarkClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("BackgroundDark is for C++ instantiation only")

public:
  BackgroundDarkClass(QObject* parent = nullptr);
  BackgroundDarkClass(const QJsonObject& json, QObject* parent = nullptr);
  virtual ~BackgroundDarkClass() = default;
  
// QML interface
  Q_PROPERTY(QString Basic MEMBER Basic CONSTANT);
  Q_PROPERTY(QString Primary MEMBER Primary CONSTANT);
  Q_PROPERTY(QString Quaternary MEMBER Quaternary CONSTANT);
  Q_PROPERTY(QString Secondary MEMBER Secondary CONSTANT);
  Q_PROPERTY(QString Tertiary MEMBER Tertiary CONSTANT);

// Members
  const QString Basic;
  const QString Primary;
  const QString Quaternary;
  const QString Secondary;
  const QString Tertiary;
};
Q_DECLARE_METATYPE(BackgroundDarkClass*)
Q_DECLARE_METATYPE(BackgroundDarkClass)

