//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <overlay_on_light.h>


OverlayOnLightClass::OverlayOnLightClass(QObject* parent) 
  : QObject(parent)
  , Blur("")
  , Hard("")
  , Soft("") {}

OverlayOnLightClass::OverlayOnLightClass(const QJsonObject& json, QObject* parent)
  : QObject(parent)
  , Blur(json["Blur"].toString())
  , Hard(json["Hard"].toString())
  , Soft(json["Soft"].toString()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! OverlayOnLight map is empty";
}


