//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>

#include <background.h>
#include <outline.h>
#include <overlay.h>
#include <surface.h>
#include <text.h>
#include <additional.h>
#include <general.h>
#include <os.h>


class PaletteClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Colors is for C++ instantiation only")

public:
  PaletteClass(QObject* parent = nullptr);
  PaletteClass(const QJsonObject& obj, QObject* parent = nullptr);
  virtual ~PaletteClass() = default;
  
// QML interface
  Q_PROPERTY(BackgroundClass* Background READ GetBackground CONSTANT);
  Q_PROPERTY(OutlineClass* Outline READ GetOutline CONSTANT);
  Q_PROPERTY(OverlayClass* Overlay READ GetOverlay CONSTANT);
  Q_PROPERTY(SurfaceClass* Surface READ GetSurface CONSTANT);
  Q_PROPERTY(TextClass* Text READ GetText CONSTANT);
  Q_PROPERTY(AdditionalClass* Additional READ GetAdditional CONSTANT);
  Q_PROPERTY(GeneralClass* General READ GetGeneral CONSTANT);
  Q_PROPERTY(OsClass* Os READ GetOs CONSTANT);
  
  BackgroundClass* GetBackground() const;
  OutlineClass* GetOutline() const;
  OverlayClass* GetOverlay() const;
  SurfaceClass* GetSurface() const;
  TextClass* GetText() const;
  AdditionalClass* GetAdditional() const;
  GeneralClass* GetGeneral() const;
  OsClass* GetOs() const;

// C++ interface
protected:
  BackgroundClass* Background;
  OutlineClass* Outline;
  OverlayClass* Overlay;
  SurfaceClass* Surface;
  TextClass* Text;
  AdditionalClass* Additional;
  GeneralClass* General;
  OsClass* Os;
};
Q_DECLARE_METATYPE(PaletteClass*)
Q_DECLARE_METATYPE(PaletteClass)

