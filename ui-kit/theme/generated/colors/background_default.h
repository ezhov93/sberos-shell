//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>


class BackgroundDefaultClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("BackgroundDefault is for C++ instantiation only")

public:
  BackgroundDefaultClass(QObject* parent = nullptr);
  BackgroundDefaultClass(const QJsonObject& json, QObject* parent = nullptr);
  virtual ~BackgroundDefaultClass() = default;
  
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
Q_DECLARE_METATYPE(BackgroundDefaultClass*)
Q_DECLARE_METATYPE(BackgroundDefaultClass)

