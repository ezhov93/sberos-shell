//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <surface.h>


SurfaceClass::SurfaceClass(QObject* parent)
  : QObject(parent)
  , Default(nullptr)
  , Inverse(nullptr)
  , OnDark(nullptr)
  , OnLight(nullptr) {}

SurfaceClass::SurfaceClass(const QJsonObject& obj, QObject* parent)
  : QObject(parent)
  , Default(new SurfaceDefaultClass(obj["Default"].toObject(), this))
  , Inverse(new SurfaceInverseClass(obj["Inverse"].toObject(), this))
  , OnDark(new SurfaceOnDarkClass(obj["OnDark"].toObject(), this))
  , OnLight(new SurfaceOnLightClass(obj["OnLight"].toObject(), this)) {}
  
SurfaceDefaultClass* SurfaceClass::GetDefault() const { return Default; }
SurfaceInverseClass* SurfaceClass::GetInverse() const { return Inverse; }
SurfaceOnDarkClass* SurfaceClass::GetOnDark() const { return OnDark; }
SurfaceOnLightClass* SurfaceClass::GetOnLight() const { return OnLight; }

