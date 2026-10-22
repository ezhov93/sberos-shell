//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <os.h>


OsClass::OsClass(QObject* parent)
  : QObject(parent)
  , Amber(nullptr)
  , Arctic(nullptr)
  , Blue(nullptr)
  , CoolGray(nullptr)
  , ElectricBlue(nullptr)
  , Fuchsia(nullptr)
  , Gold(nullptr)
  , Gray(nullptr)
  , Green(nullptr)
  , Herbal(nullptr)
  , Malachite(nullptr)
  , Orange(nullptr)
  , Orchid(nullptr)
  , Pink(nullptr)
  , Red(nullptr)
  , SkyBlue(nullptr)
  , Spring(nullptr)
  , Sunny(nullptr)
  , SuperGray(nullptr) {}

OsClass::OsClass(const QJsonObject& obj, QObject* parent)
  : QObject(parent)
  , Amber(new OsAmberClass(obj["osAmber"].toObject(), this))
  , Arctic(new OsArcticClass(obj["osArctic"].toObject(), this))
  , Blue(new OsBlueClass(obj["osBlue"].toObject(), this))
  , CoolGray(new OsCoolGrayClass(obj["osCoolGray"].toObject(), this))
  , ElectricBlue(new OsElectricBlueClass(obj["osElectricBlue"].toObject(), this))
  , Fuchsia(new OsFuchsiaClass(obj["osFuchsia"].toObject(), this))
  , Gold(new OsGoldClass(obj["osGold"].toObject(), this))
  , Gray(new OsGrayClass(obj["osGray"].toObject(), this))
  , Green(new OsGreenClass(obj["osGreen"].toObject(), this))
  , Herbal(new OsHerbalClass(obj["osHerbal"].toObject(), this))
  , Malachite(new OsMalachiteClass(obj["osMalachite"].toObject(), this))
  , Orange(new OsOrangeClass(obj["osOrange"].toObject(), this))
  , Orchid(new OsOrchidClass(obj["osOrchid"].toObject(), this))
  , Pink(new OsPinkClass(obj["osPink"].toObject(), this))
  , Red(new OsRedClass(obj["osRed"].toObject(), this))
  , SkyBlue(new OsSkyBlueClass(obj["osSkyBlue"].toObject(), this))
  , Spring(new OsSpringClass(obj["osSpring"].toObject(), this))
  , Sunny(new OsSunnyClass(obj["osSunny"].toObject(), this))
  , SuperGray(new OsSuperGrayClass(obj["osSuperGray"].toObject(), this)) {}
  
OsAmberClass* OsClass::GetAmber() const { return Amber; }
OsArcticClass* OsClass::GetArctic() const { return Arctic; }
OsBlueClass* OsClass::GetBlue() const { return Blue; }
OsCoolGrayClass* OsClass::GetCoolGray() const { return CoolGray; }
OsElectricBlueClass* OsClass::GetElectricBlue() const { return ElectricBlue; }
OsFuchsiaClass* OsClass::GetFuchsia() const { return Fuchsia; }
OsGoldClass* OsClass::GetGold() const { return Gold; }
OsGrayClass* OsClass::GetGray() const { return Gray; }
OsGreenClass* OsClass::GetGreen() const { return Green; }
OsHerbalClass* OsClass::GetHerbal() const { return Herbal; }
OsMalachiteClass* OsClass::GetMalachite() const { return Malachite; }
OsOrangeClass* OsClass::GetOrange() const { return Orange; }
OsOrchidClass* OsClass::GetOrchid() const { return Orchid; }
OsPinkClass* OsClass::GetPink() const { return Pink; }
OsRedClass* OsClass::GetRed() const { return Red; }
OsSkyBlueClass* OsClass::GetSkyBlue() const { return SkyBlue; }
OsSpringClass* OsClass::GetSpring() const { return Spring; }
OsSunnyClass* OsClass::GetSunny() const { return Sunny; }
OsSuperGrayClass* OsClass::GetSuperGray() const { return SuperGray; }

