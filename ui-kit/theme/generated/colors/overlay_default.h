//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>


class OverlayDefaultClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("OverlayDefault is for C++ instantiation only")

public:
  OverlayDefaultClass(QObject* parent = nullptr);
  OverlayDefaultClass(const QJsonObject& json, QObject* parent = nullptr);
  virtual ~OverlayDefaultClass() = default;
  
// QML interface
  Q_PROPERTY(QString Blur MEMBER Blur CONSTANT);
  Q_PROPERTY(QString Hard MEMBER Hard CONSTANT);
  Q_PROPERTY(QString Soft MEMBER Soft CONSTANT);

// Members
  const QString Blur;
  const QString Hard;
  const QString Soft;
};
Q_DECLARE_METATYPE(OverlayDefaultClass*)
Q_DECLARE_METATYPE(OverlayDefaultClass)

