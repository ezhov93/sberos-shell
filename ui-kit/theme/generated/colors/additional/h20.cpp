//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <h20.h>


H20Class::H20Class(QObject* parent) 
  : QObject(parent)
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

H20Class::H20Class(const QJsonObject& json, QObject* parent)
  : QObject(parent)
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
    qDebug() << "Components: Warning! H20 map is empty";
}


