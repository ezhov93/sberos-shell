#include <types_provider.h>

#include <type_registration.h>
REGISTER_SINGLETON_TYPE(TypesProvider, "Sber.Utils", QString(VERSION_MAJOR).toInt(), QString(VERSION_MINOR).toInt(), "TypesProvider")


TypesProvider::TypesProvider(QObject* parent)
  : QObject{parent} {}
