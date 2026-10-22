//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <background.h>


BackgroundClass::BackgroundClass(QObject* parent)
  : QObject(parent)
  , Dark(nullptr)
  , Default(nullptr)
  , Inverse(nullptr)
  , Light(nullptr) {}

BackgroundClass::BackgroundClass(const QJsonObject& obj, QObject* parent)
  : QObject(parent)
  , Dark(new BackgroundDarkClass(obj["Dark"].toObject(), this))
  , Default(new BackgroundDefaultClass(obj["Default"].toObject(), this))
  , Inverse(new BackgroundInverseClass(obj["Inverse"].toObject(), this))
  , Light(new BackgroundLightClass(obj["Light"].toObject(), this)) {}
  
BackgroundDarkClass* BackgroundClass::GetDark() const { return Dark; }
BackgroundDefaultClass* BackgroundClass::GetDefault() const { return Default; }
BackgroundInverseClass* BackgroundClass::GetInverse() const { return Inverse; }
BackgroundLightClass* BackgroundClass::GetLight() const { return Light; }

