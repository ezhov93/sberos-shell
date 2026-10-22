//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>

#include <overlay_default.h>
#include <overlay_inverse.h>
#include <overlay_on_dark.h>
#include <overlay_on_light.h>


class OverlayClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Colors is for C++ instantiation only")

public:
  OverlayClass(QObject* parent = nullptr);
  OverlayClass(const QJsonObject& obj, QObject* parent = nullptr);
  virtual ~OverlayClass() = default;
  
// QML interface
  Q_PROPERTY(OverlayDefaultClass* Default READ GetDefault CONSTANT);
  Q_PROPERTY(OverlayInverseClass* Inverse READ GetInverse CONSTANT);
  Q_PROPERTY(OverlayOnDarkClass* OnDark READ GetOnDark CONSTANT);
  Q_PROPERTY(OverlayOnLightClass* OnLight READ GetOnLight CONSTANT);
  
  OverlayDefaultClass* GetDefault() const;
  OverlayInverseClass* GetInverse() const;
  OverlayOnDarkClass* GetOnDark() const;
  OverlayOnLightClass* GetOnLight() const;

// C++ interface
protected:
  OverlayDefaultClass* Default;
  OverlayInverseClass* Inverse;
  OverlayOnDarkClass* OnDark;
  OverlayOnLightClass* OnLight;
};
Q_DECLARE_METATYPE(OverlayClass*)
Q_DECLARE_METATYPE(OverlayClass)

