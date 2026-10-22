//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <overlay_default.h>


OverlayDefaultClass::OverlayDefaultClass(QObject* parent) 
  : QObject(parent)
  , Blur("")
  , Hard("")
  , Soft("") {}

OverlayDefaultClass::OverlayDefaultClass(const QJsonObject& json, QObject* parent)
  : QObject(parent)
  , Blur(json["Blur"].toString())
  , Hard(json["Hard"].toString())
  , Soft(json["Soft"].toString()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! OverlayDefault map is empty";
}


