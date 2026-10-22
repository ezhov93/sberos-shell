//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <overlay_on_dark.h>


OverlayOnDarkClass::OverlayOnDarkClass(QObject* parent) 
  : QObject(parent)
  , Blur("")
  , Hard("")
  , Soft("") {}

OverlayOnDarkClass::OverlayOnDarkClass(const QJsonObject& json, QObject* parent)
  : QObject(parent)
  , Blur(json["Blur"].toString())
  , Hard(json["Hard"].toString())
  , Soft(json["Soft"].toString()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! OverlayOnDark map is empty";
}


