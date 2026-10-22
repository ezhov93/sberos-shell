//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <overlay_inverse.h>


OverlayInverseClass::OverlayInverseClass(QObject* parent) 
  : QObject(parent)
  , Blur("")
  , Hard("")
  , Soft("") {}

OverlayInverseClass::OverlayInverseClass(const QJsonObject& json, QObject* parent)
  : QObject(parent)
  , Blur(json["Blur"].toString())
  , Hard(json["Hard"].toString())
  , Soft(json["Soft"].toString()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! OverlayInverse map is empty";
}


