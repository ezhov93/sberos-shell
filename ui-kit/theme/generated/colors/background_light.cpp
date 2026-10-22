//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <background_light.h>


BackgroundLightClass::BackgroundLightClass(QObject* parent) 
  : QObject(parent)
  , Basic("")
  , Primary("")
  , Quaternary("")
  , Secondary("")
  , Tertiary("") {}

BackgroundLightClass::BackgroundLightClass(const QJsonObject& json, QObject* parent)
  : QObject(parent)
  , Basic(json["Basic"].toString())
  , Primary(json["Primary"].toString())
  , Quaternary(json["Quaternary"].toString())
  , Secondary(json["Secondary"].toString())
  , Tertiary(json["Tertiary"].toString()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! BackgroundLight map is empty";
}


