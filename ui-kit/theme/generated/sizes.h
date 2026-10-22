//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>

#include <border_radius.h>
#include <line_height.h>


class SizesClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Colors is for C++ instantiation only")

public:
  SizesClass(QObject* parent = nullptr);
  SizesClass(const QJsonObject& obj, QObject* parent = nullptr);
  virtual ~SizesClass() = default;
  
// QML interface
  Q_PROPERTY(BorderRadiusClass* BorderRadius READ GetBorderRadius CONSTANT);
  Q_PROPERTY(LineHeightClass* LineHeight READ GetLineHeight CONSTANT);
  
  BorderRadiusClass* GetBorderRadius() const;
  LineHeightClass* GetLineHeight() const;

// C++ interface
protected:
  BorderRadiusClass* BorderRadius;
  LineHeightClass* LineHeight;
};
Q_DECLARE_METATYPE(SizesClass*)
Q_DECLARE_METATYPE(SizesClass)

