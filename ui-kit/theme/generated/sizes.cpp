//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <sizes.h>


SizesClass::SizesClass(QObject* parent)
  : QObject(parent)
  , BorderRadius(nullptr)
  , LineHeight(nullptr) {}

SizesClass::SizesClass(const QJsonObject& obj, QObject* parent)
  : QObject(parent)
  , BorderRadius(new BorderRadiusClass(obj["BorderRadius"].toObject(), this))
  , LineHeight(new LineHeightClass(obj["LineHeight"].toObject(), this)) {}
  
BorderRadiusClass* SizesClass::GetBorderRadius() const { return BorderRadius; }
LineHeightClass* SizesClass::GetLineHeight() const { return LineHeight; }

