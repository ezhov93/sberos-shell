//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>


class %(class_name)Class : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("%(class_name) is for C++ instantiation only")

public:
  %(class_name)Class(QObject* parent = nullptr);
  %(class_name)Class(const QJsonObject& json, QObject* parent = nullptr);
  virtual ~%(class_name)Class() = default;
  
// QML interface
%([  Q_PROPERTY(%(member_type) %(member_name) MEMBER %(member_name) CONSTANT);\n])

// Members
%([  const %(member_type) %(member_name);\n])
};
Q_DECLARE_METATYPE(%(class_name)Class*)
Q_DECLARE_METATYPE(%(class_name)Class)

