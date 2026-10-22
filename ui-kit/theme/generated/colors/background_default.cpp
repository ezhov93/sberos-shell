//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <background_default.h>


BackgroundDefaultClass::BackgroundDefaultClass(QObject* parent) 
  : QObject(parent)
  , Basic("")
  , Primary("")
  , Quaternary("")
  , Secondary("")
  , Tertiary("") {}

BackgroundDefaultClass::BackgroundDefaultClass(const QJsonObject& json, QObject* parent)
  : QObject(parent)
  , Basic(json["Basic"].toString())
  , Primary(json["Primary"].toString())
  , Quaternary(json["Quaternary"].toString())
  , Secondary(json["Secondary"].toString())
  , Tertiary(json["Tertiary"].toString()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! BackgroundDefault map is empty";
}


