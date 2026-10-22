//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>


class OverlayInverseClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("OverlayInverse is for C++ instantiation only")

public:
  OverlayInverseClass(QObject* parent = nullptr);
  OverlayInverseClass(const QJsonObject& json, QObject* parent = nullptr);
  virtual ~OverlayInverseClass() = default;
  
// QML interface
  Q_PROPERTY(QString Blur MEMBER Blur CONSTANT);
  Q_PROPERTY(QString Hard MEMBER Hard CONSTANT);
  Q_PROPERTY(QString Soft MEMBER Soft CONSTANT);

// Members
  const QString Blur;
  const QString Hard;
  const QString Soft;
};
Q_DECLARE_METATYPE(OverlayInverseClass*)
Q_DECLARE_METATYPE(OverlayInverseClass)

