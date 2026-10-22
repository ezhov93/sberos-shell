//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <%(class_file).h>


%(class_name)Class::%(class_name)Class(QObject* parent)
  : QObject(parent)
%([  , %(member_name)(nullptr)\n]) {}

%(class_name)Class::%(class_name)Class(const QJsonObject& obj, QObject* parent)
  : QObject(parent)
%([  , %(member_name)(new %(member_class)Class(obj["%(json_name)"].toObject(), this))\n]) {}
  
%([%(member_class)Class* %(class_name)Class::Get%(member_name)() const { return %(member_name); }\n])

