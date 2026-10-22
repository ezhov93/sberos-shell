//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////

#include <%(class_file).h>


%(class_name)Base::%(class_name)Base(QObject* parent)
  : QObject(parent) {}
  
%([%(member_type) %(class_name)Base::Get%(member_name)() { return Get%(getter_name)("%(json_name)"); }\n])

