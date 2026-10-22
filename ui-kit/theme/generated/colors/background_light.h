//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>


class BackgroundLightClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("BackgroundLight is for C++ instantiation only")

public:
  BackgroundLightClass(QObject* parent = nullptr);
  BackgroundLightClass(const QJsonObject& json, QObject* parent = nullptr);
  virtual ~BackgroundLightClass() = default;
  
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
Q_DECLARE_METATYPE(BackgroundLightClass*)
Q_DECLARE_METATYPE(BackgroundLightClass)

