//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <outline.h>


OutlineClass::OutlineClass(QObject* parent)
  : QObject(parent)
  , Default(nullptr)
  , Inverse(nullptr)
  , OnDark(nullptr)
  , OnLight(nullptr) {}

OutlineClass::OutlineClass(const QJsonObject& obj, QObject* parent)
  : QObject(parent)
  , Default(new OutlineDefaultClass(obj["Default"].toObject(), this))
  , Inverse(new OutlineInverseClass(obj["Inverse"].toObject(), this))
  , OnDark(new OutlineOnDarkClass(obj["OnDark"].toObject(), this))
  , OnLight(new OutlineOnLightClass(obj["OnLight"].toObject(), this)) {}
  
OutlineDefaultClass* OutlineClass::GetDefault() const { return Default; }
OutlineInverseClass* OutlineClass::GetInverse() const { return Inverse; }
OutlineOnDarkClass* OutlineClass::GetOnDark() const { return OnDark; }
OutlineOnLightClass* OutlineClass::GetOnLight() const { return OnLight; }

