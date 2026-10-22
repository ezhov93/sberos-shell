//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>

#include <amber.h>
#include <arctic.h>
#include <blue.h>
#include <cool_gray.h>
#include <electric_blue.h>
#include <fuchsia.h>
#include <gold.h>
#include <gray.h>
#include <green.h>
#include <herbal.h>
#include <malachite.h>
#include <orange.h>
#include <orchid.h>
#include <pink.h>
#include <red.h>
#include <sky_blue.h>
#include <spring.h>
#include <sunny.h>


class GeneralClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Colors is for C++ instantiation only")

public:
  GeneralClass(QObject* parent = nullptr);
  GeneralClass(const QJsonObject& obj, QObject* parent = nullptr);
  virtual ~GeneralClass() = default;
  
// QML interface
  Q_PROPERTY(AmberClass* Amber READ GetAmber CONSTANT);
  Q_PROPERTY(ArcticClass* Arctic READ GetArctic CONSTANT);
  Q_PROPERTY(BlueClass* Blue READ GetBlue CONSTANT);
  Q_PROPERTY(CoolGrayClass* CoolGray READ GetCoolGray CONSTANT);
  Q_PROPERTY(ElectricBlueClass* ElectricBlue READ GetElectricBlue CONSTANT);
  Q_PROPERTY(FuchsiaClass* Fuchsia READ GetFuchsia CONSTANT);
  Q_PROPERTY(GoldClass* Gold READ GetGold CONSTANT);
  Q_PROPERTY(GrayClass* Gray READ GetGray CONSTANT);
  Q_PROPERTY(GreenClass* Green READ GetGreen CONSTANT);
  Q_PROPERTY(HerbalClass* Herbal READ GetHerbal CONSTANT);
  Q_PROPERTY(MalachiteClass* Malachite READ GetMalachite CONSTANT);
  Q_PROPERTY(OrangeClass* Orange READ GetOrange CONSTANT);
  Q_PROPERTY(OrchidClass* Orchid READ GetOrchid CONSTANT);
  Q_PROPERTY(PinkClass* Pink READ GetPink CONSTANT);
  Q_PROPERTY(RedClass* Red READ GetRed CONSTANT);
  Q_PROPERTY(SkyBlueClass* SkyBlue READ GetSkyBlue CONSTANT);
  Q_PROPERTY(SpringClass* Spring READ GetSpring CONSTANT);
  Q_PROPERTY(SunnyClass* Sunny READ GetSunny CONSTANT);
  
  AmberClass* GetAmber() const;
  ArcticClass* GetArctic() const;
  BlueClass* GetBlue() const;
  CoolGrayClass* GetCoolGray() const;
  ElectricBlueClass* GetElectricBlue() const;
  FuchsiaClass* GetFuchsia() const;
  GoldClass* GetGold() const;
  GrayClass* GetGray() const;
  GreenClass* GetGreen() const;
  HerbalClass* GetHerbal() const;
  MalachiteClass* GetMalachite() const;
  OrangeClass* GetOrange() const;
  OrchidClass* GetOrchid() const;
  PinkClass* GetPink() const;
  RedClass* GetRed() const;
  SkyBlueClass* GetSkyBlue() const;
  SpringClass* GetSpring() const;
  SunnyClass* GetSunny() const;

// C++ interface
protected:
  AmberClass* Amber;
  ArcticClass* Arctic;
  BlueClass* Blue;
  CoolGrayClass* CoolGray;
  ElectricBlueClass* ElectricBlue;
  FuchsiaClass* Fuchsia;
  GoldClass* Gold;
  GrayClass* Gray;
  GreenClass* Green;
  HerbalClass* Herbal;
  MalachiteClass* Malachite;
  OrangeClass* Orange;
  OrchidClass* Orchid;
  PinkClass* Pink;
  RedClass* Red;
  SkyBlueClass* SkyBlue;
  SpringClass* Spring;
  SunnyClass* Sunny;
};
Q_DECLARE_METATYPE(GeneralClass*)
Q_DECLARE_METATYPE(GeneralClass)

