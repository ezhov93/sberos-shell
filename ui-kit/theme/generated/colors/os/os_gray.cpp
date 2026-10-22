//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <os_gray.h>


OsGrayClass::OsGrayClass(QObject* parent) 
  : QObject(parent)
  , _50("")
  , _100("")
  , _150("")
  , _200("")
  , _250("")
  , _300("")
  , _350("")
  , _400("")
  , _450("")
  , _500("")
  , _550("")
  , _600("")
  , _650("")
  , _700("")
  , _750("")
  , _800("")
  , _850("")
  , _900("")
  , _950("")
  , _1000("") {}

OsGrayClass::OsGrayClass(const QJsonObject& json, QObject* parent)
  : QObject(parent)
  , _50(json["50"].toString())
  , _100(json["100"].toString())
  , _150(json["150"].toString())
  , _200(json["200"].toString())
  , _250(json["250"].toString())
  , _300(json["300"].toString())
  , _350(json["350"].toString())
  , _400(json["400"].toString())
  , _450(json["450"].toString())
  , _500(json["500"].toString())
  , _550(json["550"].toString())
  , _600(json["600"].toString())
  , _650(json["650"].toString())
  , _700(json["700"].toString())
  , _750(json["750"].toString())
  , _800(json["800"].toString())
  , _850(json["850"].toString())
  , _900(json["900"].toString())
  , _950(json["950"].toString())
  , _1000(json["1000"].toString()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! OsGray map is empty";
}


