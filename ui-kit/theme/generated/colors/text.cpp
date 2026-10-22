//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <text.h>


TextClass::TextClass(QObject* parent)
  : QObject(parent)
  , Default(nullptr)
  , Inverse(nullptr)
  , OnDark(nullptr)
  , OnLight(nullptr) {}

TextClass::TextClass(const QJsonObject& obj, QObject* parent)
  : QObject(parent)
  , Default(new TextDefaultClass(obj["Default"].toObject(), this))
  , Inverse(new TextInverseClass(obj["Inverse"].toObject(), this))
  , OnDark(new TextOnDarkClass(obj["OnDark"].toObject(), this))
  , OnLight(new TextOnLightClass(obj["OnLight"].toObject(), this)) {}
  
TextDefaultClass* TextClass::GetDefault() const { return Default; }
TextInverseClass* TextClass::GetInverse() const { return Inverse; }
TextOnDarkClass* TextClass::GetOnDark() const { return OnDark; }
TextOnLightClass* TextClass::GetOnLight() const { return OnLight; }

