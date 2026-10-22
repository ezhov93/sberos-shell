//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>

#include <outline_default.h>
#include <outline_inverse.h>
#include <outline_on_dark.h>
#include <outline_on_light.h>


class OutlineClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Colors is for C++ instantiation only")

public:
  OutlineClass(QObject* parent = nullptr);
  OutlineClass(const QJsonObject& obj, QObject* parent = nullptr);
  virtual ~OutlineClass() = default;
  
// QML interface
  Q_PROPERTY(OutlineDefaultClass* Default READ GetDefault CONSTANT);
  Q_PROPERTY(OutlineInverseClass* Inverse READ GetInverse CONSTANT);
  Q_PROPERTY(OutlineOnDarkClass* OnDark READ GetOnDark CONSTANT);
  Q_PROPERTY(OutlineOnLightClass* OnLight READ GetOnLight CONSTANT);
  
  OutlineDefaultClass* GetDefault() const;
  OutlineInverseClass* GetInverse() const;
  OutlineOnDarkClass* GetOnDark() const;
  OutlineOnLightClass* GetOnLight() const;

// C++ interface
protected:
  OutlineDefaultClass* Default;
  OutlineInverseClass* Inverse;
  OutlineOnDarkClass* OnDark;
  OutlineOnLightClass* OnLight;
};
Q_DECLARE_METATYPE(OutlineClass*)
Q_DECLARE_METATYPE(OutlineClass)

