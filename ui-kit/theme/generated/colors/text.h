//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>

#include <text_default.h>
#include <text_inverse.h>
#include <text_on_dark.h>
#include <text_on_light.h>


class TextClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Colors is for C++ instantiation only")

public:
  TextClass(QObject* parent = nullptr);
  TextClass(const QJsonObject& obj, QObject* parent = nullptr);
  virtual ~TextClass() = default;
  
// QML interface
  Q_PROPERTY(TextDefaultClass* Default READ GetDefault CONSTANT);
  Q_PROPERTY(TextInverseClass* Inverse READ GetInverse CONSTANT);
  Q_PROPERTY(TextOnDarkClass* OnDark READ GetOnDark CONSTANT);
  Q_PROPERTY(TextOnLightClass* OnLight READ GetOnLight CONSTANT);
  
  TextDefaultClass* GetDefault() const;
  TextInverseClass* GetInverse() const;
  TextOnDarkClass* GetOnDark() const;
  TextOnLightClass* GetOnLight() const;

// C++ interface
protected:
  TextDefaultClass* Default;
  TextInverseClass* Inverse;
  TextOnDarkClass* OnDark;
  TextOnLightClass* OnLight;
};
Q_DECLARE_METATYPE(TextClass*)
Q_DECLARE_METATYPE(TextClass)

