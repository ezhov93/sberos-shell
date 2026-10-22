//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <background_dark.h>


BackgroundDarkClass::BackgroundDarkClass(QObject* parent) 
  : QObject(parent)
  , Basic("")
  , Primary("")
  , Quaternary("")
  , Secondary("")
  , Tertiary("") {}

BackgroundDarkClass::BackgroundDarkClass(const QJsonObject& json, QObject* parent)
  : QObject(parent)
  , Basic(json["Basic"].toString())
  , Primary(json["Primary"].toString())
  , Quaternary(json["Quaternary"].toString())
  , Secondary(json["Secondary"].toString())
  , Tertiary(json["Tertiary"].toString()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! BackgroundDark map is empty";
}


