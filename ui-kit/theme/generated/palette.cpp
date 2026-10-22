//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <palette.h>


PaletteClass::PaletteClass(QObject* parent)
  : QObject(parent)
  , Background(nullptr)
  , Outline(nullptr)
  , Overlay(nullptr)
  , Surface(nullptr)
  , Text(nullptr)
  , Additional(nullptr)
  , General(nullptr)
  , Os(nullptr) {}

PaletteClass::PaletteClass(const QJsonObject& obj, QObject* parent)
  : QObject(parent)
  , Background(new BackgroundClass(obj["Background"].toObject(), this))
  , Outline(new OutlineClass(obj["Outline"].toObject(), this))
  , Overlay(new OverlayClass(obj["Overlay"].toObject(), this))
  , Surface(new SurfaceClass(obj["Surface"].toObject(), this))
  , Text(new TextClass(obj["Text"].toObject(), this))
  , Additional(new AdditionalClass(obj["additional"].toObject(), this))
  , General(new GeneralClass(obj["general"].toObject(), this))
  , Os(new OsClass(obj["os"].toObject(), this)) {}
  
BackgroundClass* PaletteClass::GetBackground() const { return Background; }
OutlineClass* PaletteClass::GetOutline() const { return Outline; }
OverlayClass* PaletteClass::GetOverlay() const { return Overlay; }
SurfaceClass* PaletteClass::GetSurface() const { return Surface; }
TextClass* PaletteClass::GetText() const { return Text; }
AdditionalClass* PaletteClass::GetAdditional() const { return Additional; }
GeneralClass* PaletteClass::GetGeneral() const { return General; }
OsClass* PaletteClass::GetOs() const { return Os; }

