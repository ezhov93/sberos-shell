//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////

#pragma once

#include <QFont>
#include <QObject>
#include <QtQmlIntegration>


class %(class_name)Base : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("%(class_name)Base is for C++ instantiation only")

public: 
  %(class_name)Base(QObject* parent = nullptr);
  ~%(class_name)Base() = default;
  
  virtual %(member_type) Get%(getter_name)(const QString& tag) const = 0;
  
// QML interface
%([  Q_PROPERTY(%(member_type) %(member_name) READ Get%(member_name) CONSTANT);\n])

// C++ interface
%([  %(member_type) Get%(member_name)();\n])
};
Q_DECLARE_METATYPE(%(class_name)Base*)
Q_DECLARE_METATYPE(const %(class_name)Base*)
Q_DECLARE_METATYPE(%(class_name)Base)
Q_DECLARE_METATYPE(const %(class_name)Base)

