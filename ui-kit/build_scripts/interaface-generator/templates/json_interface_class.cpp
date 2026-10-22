//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <%(class_file).h>


%(class_name)Class::%(class_name)Class(QObject* parent) 
  : QObject(parent)
%([  , %(member_name)(%(member_default_value))\n]) {}

%(class_name)Class::%(class_name)Class(const QJsonObject& json, QObject* parent)
  : QObject(parent)
%([  , %(member_name)(json["%(json_name)"]%(json_getter))\n]) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! %(class_name) map is empty";
}


