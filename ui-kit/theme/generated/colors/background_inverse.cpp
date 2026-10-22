//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <background_inverse.h>


BackgroundInverseClass::BackgroundInverseClass(QObject* parent) 
  : QObject(parent)
  , Basic("")
  , Primary("")
  , Quaternary("")
  , Secondary("")
  , Tertiary("") {}

BackgroundInverseClass::BackgroundInverseClass(const QJsonObject& json, QObject* parent)
  : QObject(parent)
  , Basic(json["Basic"].toString())
  , Primary(json["Primary"].toString())
  , Quaternary(json["Quaternary"].toString())
  , Secondary(json["Secondary"].toString())
  , Tertiary(json["Tertiary"].toString()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! BackgroundInverse map is empty";
}


