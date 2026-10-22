//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>

#include <surface_default.h>
#include <surface_inverse.h>
#include <surface_on_dark.h>
#include <surface_on_light.h>


class SurfaceClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Colors is for C++ instantiation only")

public:
  SurfaceClass(QObject* parent = nullptr);
  SurfaceClass(const QJsonObject& obj, QObject* parent = nullptr);
  virtual ~SurfaceClass() = default;
  
// QML interface
  Q_PROPERTY(SurfaceDefaultClass* Default READ GetDefault CONSTANT);
  Q_PROPERTY(SurfaceInverseClass* Inverse READ GetInverse CONSTANT);
  Q_PROPERTY(SurfaceOnDarkClass* OnDark READ GetOnDark CONSTANT);
  Q_PROPERTY(SurfaceOnLightClass* OnLight READ GetOnLight CONSTANT);
  
  SurfaceDefaultClass* GetDefault() const;
  SurfaceInverseClass* GetInverse() const;
  SurfaceOnDarkClass* GetOnDark() const;
  SurfaceOnLightClass* GetOnLight() const;

// C++ interface
protected:
  SurfaceDefaultClass* Default;
  SurfaceInverseClass* Inverse;
  SurfaceOnDarkClass* OnDark;
  SurfaceOnLightClass* OnLight;
};
Q_DECLARE_METATYPE(SurfaceClass*)
Q_DECLARE_METATYPE(SurfaceClass)

