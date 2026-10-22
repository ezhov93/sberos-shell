//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>

#include <background_dark.h>
#include <background_default.h>
#include <background_inverse.h>
#include <background_light.h>


class BackgroundClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Colors is for C++ instantiation only")

public:
  BackgroundClass(QObject* parent = nullptr);
  BackgroundClass(const QJsonObject& obj, QObject* parent = nullptr);
  virtual ~BackgroundClass() = default;
  
// QML interface
  Q_PROPERTY(BackgroundDarkClass* Dark READ GetDark CONSTANT);
  Q_PROPERTY(BackgroundDefaultClass* Default READ GetDefault CONSTANT);
  Q_PROPERTY(BackgroundInverseClass* Inverse READ GetInverse CONSTANT);
  Q_PROPERTY(BackgroundLightClass* Light READ GetLight CONSTANT);
  
  BackgroundDarkClass* GetDark() const;
  BackgroundDefaultClass* GetDefault() const;
  BackgroundInverseClass* GetInverse() const;
  BackgroundLightClass* GetLight() const;

// C++ interface
protected:
  BackgroundDarkClass* Dark;
  BackgroundDefaultClass* Default;
  BackgroundInverseClass* Inverse;
  BackgroundLightClass* Light;
};
Q_DECLARE_METATYPE(BackgroundClass*)
Q_DECLARE_METATYPE(BackgroundClass)

