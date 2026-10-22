//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>

#include <os_amber.h>
#include <os_arctic.h>
#include <os_blue.h>
#include <os_cool_gray.h>
#include <os_electric_blue.h>
#include <os_fuchsia.h>
#include <os_gold.h>
#include <os_gray.h>
#include <os_green.h>
#include <os_herbal.h>
#include <os_malachite.h>
#include <os_orange.h>
#include <os_orchid.h>
#include <os_pink.h>
#include <os_red.h>
#include <os_sky_blue.h>
#include <os_spring.h>
#include <os_sunny.h>
#include <os_super_gray.h>


class OsClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Colors is for C++ instantiation only")

public:
  OsClass(QObject* parent = nullptr);
  OsClass(const QJsonObject& obj, QObject* parent = nullptr);
  virtual ~OsClass() = default;
  
// QML interface
  Q_PROPERTY(OsAmberClass* Amber READ GetAmber CONSTANT);
  Q_PROPERTY(OsArcticClass* Arctic READ GetArctic CONSTANT);
  Q_PROPERTY(OsBlueClass* Blue READ GetBlue CONSTANT);
  Q_PROPERTY(OsCoolGrayClass* CoolGray READ GetCoolGray CONSTANT);
  Q_PROPERTY(OsElectricBlueClass* ElectricBlue READ GetElectricBlue CONSTANT);
  Q_PROPERTY(OsFuchsiaClass* Fuchsia READ GetFuchsia CONSTANT);
  Q_PROPERTY(OsGoldClass* Gold READ GetGold CONSTANT);
  Q_PROPERTY(OsGrayClass* Gray READ GetGray CONSTANT);
  Q_PROPERTY(OsGreenClass* Green READ GetGreen CONSTANT);
  Q_PROPERTY(OsHerbalClass* Herbal READ GetHerbal CONSTANT);
  Q_PROPERTY(OsMalachiteClass* Malachite READ GetMalachite CONSTANT);
  Q_PROPERTY(OsOrangeClass* Orange READ GetOrange CONSTANT);
  Q_PROPERTY(OsOrchidClass* Orchid READ GetOrchid CONSTANT);
  Q_PROPERTY(OsPinkClass* Pink READ GetPink CONSTANT);
  Q_PROPERTY(OsRedClass* Red READ GetRed CONSTANT);
  Q_PROPERTY(OsSkyBlueClass* SkyBlue READ GetSkyBlue CONSTANT);
  Q_PROPERTY(OsSpringClass* Spring READ GetSpring CONSTANT);
  Q_PROPERTY(OsSunnyClass* Sunny READ GetSunny CONSTANT);
  Q_PROPERTY(OsSuperGrayClass* SuperGray READ GetSuperGray CONSTANT);
  
  OsAmberClass* GetAmber() const;
  OsArcticClass* GetArctic() const;
  OsBlueClass* GetBlue() const;
  OsCoolGrayClass* GetCoolGray() const;
  OsElectricBlueClass* GetElectricBlue() const;
  OsFuchsiaClass* GetFuchsia() const;
  OsGoldClass* GetGold() const;
  OsGrayClass* GetGray() const;
  OsGreenClass* GetGreen() const;
  OsHerbalClass* GetHerbal() const;
  OsMalachiteClass* GetMalachite() const;
  OsOrangeClass* GetOrange() const;
  OsOrchidClass* GetOrchid() const;
  OsPinkClass* GetPink() const;
  OsRedClass* GetRed() const;
  OsSkyBlueClass* GetSkyBlue() const;
  OsSpringClass* GetSpring() const;
  OsSunnyClass* GetSunny() const;
  OsSuperGrayClass* GetSuperGray() const;

// C++ interface
protected:
  OsAmberClass* Amber;
  OsArcticClass* Arctic;
  OsBlueClass* Blue;
  OsCoolGrayClass* CoolGray;
  OsElectricBlueClass* ElectricBlue;
  OsFuchsiaClass* Fuchsia;
  OsGoldClass* Gold;
  OsGrayClass* Gray;
  OsGreenClass* Green;
  OsHerbalClass* Herbal;
  OsMalachiteClass* Malachite;
  OsOrangeClass* Orange;
  OsOrchidClass* Orchid;
  OsPinkClass* Pink;
  OsRedClass* Red;
  OsSkyBlueClass* SkyBlue;
  OsSpringClass* Spring;
  OsSunnyClass* Sunny;
  OsSuperGrayClass* SuperGray;
};
Q_DECLARE_METATYPE(OsClass*)
Q_DECLARE_METATYPE(OsClass)

