//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <border_radius.h>


BorderRadiusClass::BorderRadiusClass(QObject* parent) 
  : QObject(parent)
  , L(0)
  , M(0)
  , S(0)
  , Xl(0)
  , Xs(0)
  , Xxl(0)
  , Xxs(0) {}

BorderRadiusClass::BorderRadiusClass(const QJsonObject& json, QObject* parent)
  : QObject(parent)
  , L(json["l"].toInt())
  , M(json["m"].toInt())
  , S(json["s"].toInt())
  , Xl(json["xl"].toInt())
  , Xs(json["xs"].toInt())
  , Xxl(json["xxl"].toInt())
  , Xxs(json["xxs"].toInt()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! BorderRadius map is empty";
}


