//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <overlay.h>


OverlayClass::OverlayClass(QObject* parent)
  : QObject(parent)
  , Default(nullptr)
  , Inverse(nullptr)
  , OnDark(nullptr)
  , OnLight(nullptr) {}

OverlayClass::OverlayClass(const QJsonObject& obj, QObject* parent)
  : QObject(parent)
  , Default(new OverlayDefaultClass(obj["Default"].toObject(), this))
  , Inverse(new OverlayInverseClass(obj["Inverse"].toObject(), this))
  , OnDark(new OverlayOnDarkClass(obj["OnDark"].toObject(), this))
  , OnLight(new OverlayOnLightClass(obj["OnLight"].toObject(), this)) {}
  
OverlayDefaultClass* OverlayClass::GetDefault() const { return Default; }
OverlayInverseClass* OverlayClass::GetInverse() const { return Inverse; }
OverlayOnDarkClass* OverlayClass::GetOnDark() const { return OnDark; }
OverlayOnLightClass* OverlayClass::GetOnLight() const { return OnLight; }

