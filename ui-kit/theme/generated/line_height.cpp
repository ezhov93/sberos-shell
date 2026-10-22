//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <line_height.h>


LineHeightClass::LineHeightClass(QObject* parent) 
  : QObject(parent)
  , L(0)
  , M(0)
  , S(0)
  , Xs(0)
  , Xxs(0) {}

LineHeightClass::LineHeightClass(const QJsonObject& json, QObject* parent)
  : QObject(parent)
  , L(json["l"].toInt())
  , M(json["m"].toInt())
  , S(json["s"].toInt())
  , Xs(json["xs"].toInt())
  , Xxs(json["xxs"].toInt()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! LineHeight map is empty";
}


