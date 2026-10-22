//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>

%([#include <%(member_file).h>\n])


class %(class_name)Class : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Colors is for C++ instantiation only")

public:
  %(class_name)Class(QObject* parent = nullptr);
  %(class_name)Class(const QJsonObject& obj, QObject* parent = nullptr);
  virtual ~%(class_name)Class() = default;
  
// QML interface
%([  Q_PROPERTY(%(member_class)Class* %(member_name) READ Get%(member_name) CONSTANT);\n])
  
%([  %(member_class)Class* Get%(member_name)() const;\n])

// C++ interface
protected:
%([  %(member_class)Class* %(member_name);\n])
};
Q_DECLARE_METATYPE(%(class_name)Class*)
Q_DECLARE_METATYPE(%(class_name)Class)

