//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <green.h>


GreenClass::GreenClass(QObject* parent) 
  : QObject(parent)
  , _50("")
  , _100("")
  , _150("")
  , _200("")
  , _250("")
  , _300("")
  , _400("")
  , _500("")
  , _600("")
  , _700("")
  , _800("")
  , _850("")
  , _900("")
  , _950("")
  , _1000("") {}

GreenClass::GreenClass(const QJsonObject& json, QObject* parent)
  : QObject(parent)
  , _50(json["50"].toString())
  , _100(json["100"].toString())
  , _150(json["150"].toString())
  , _200(json["200"].toString())
  , _250(json["250"].toString())
  , _300(json["300"].toString())
  , _400(json["400"].toString())
  , _500(json["500"].toString())
  , _600(json["600"].toString())
  , _700(json["700"].toString())
  , _800(json["800"].toString())
  , _850(json["850"].toString())
  , _900(json["900"].toString())
  , _950(json["950"].toString())
  , _1000(json["1000"].toString()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! Green map is empty";
}


