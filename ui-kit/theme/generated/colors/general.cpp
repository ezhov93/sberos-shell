//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <general.h>


GeneralClass::GeneralClass(QObject* parent)
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
  , Sunny(nullptr) {}

GeneralClass::GeneralClass(const QJsonObject& obj, QObject* parent)
  : QObject(parent)
  , Amber(new AmberClass(obj["amber"].toObject(), this))
  , Arctic(new ArcticClass(obj["arctic"].toObject(), this))
  , Blue(new BlueClass(obj["blue"].toObject(), this))
  , CoolGray(new CoolGrayClass(obj["coolGray"].toObject(), this))
  , ElectricBlue(new ElectricBlueClass(obj["electricBlue"].toObject(), this))
  , Fuchsia(new FuchsiaClass(obj["fuchsia"].toObject(), this))
  , Gold(new GoldClass(obj["gold"].toObject(), this))
  , Gray(new GrayClass(obj["gray"].toObject(), this))
  , Green(new GreenClass(obj["green"].toObject(), this))
  , Herbal(new HerbalClass(obj["herbal"].toObject(), this))
  , Malachite(new MalachiteClass(obj["malachite"].toObject(), this))
  , Orange(new OrangeClass(obj["orange"].toObject(), this))
  , Orchid(new OrchidClass(obj["orchid"].toObject(), this))
  , Pink(new PinkClass(obj["pink"].toObject(), this))
  , Red(new RedClass(obj["red"].toObject(), this))
  , SkyBlue(new SkyBlueClass(obj["skyBlue"].toObject(), this))
  , Spring(new SpringClass(obj["spring"].toObject(), this))
  , Sunny(new SunnyClass(obj["sunny"].toObject(), this)) {}
  
AmberClass* GeneralClass::GetAmber() const { return Amber; }
ArcticClass* GeneralClass::GetArctic() const { return Arctic; }
BlueClass* GeneralClass::GetBlue() const { return Blue; }
CoolGrayClass* GeneralClass::GetCoolGray() const { return CoolGray; }
ElectricBlueClass* GeneralClass::GetElectricBlue() const { return ElectricBlue; }
FuchsiaClass* GeneralClass::GetFuchsia() const { return Fuchsia; }
GoldClass* GeneralClass::GetGold() const { return Gold; }
GrayClass* GeneralClass::GetGray() const { return Gray; }
GreenClass* GeneralClass::GetGreen() const { return Green; }
HerbalClass* GeneralClass::GetHerbal() const { return Herbal; }
MalachiteClass* GeneralClass::GetMalachite() const { return Malachite; }
OrangeClass* GeneralClass::GetOrange() const { return Orange; }
OrchidClass* GeneralClass::GetOrchid() const { return Orchid; }
PinkClass* GeneralClass::GetPink() const { return Pink; }
RedClass* GeneralClass::GetRed() const { return Red; }
SkyBlueClass* GeneralClass::GetSkyBlue() const { return SkyBlue; }
SpringClass* GeneralClass::GetSpring() const { return Spring; }
SunnyClass* GeneralClass::GetSunny() const { return Sunny; }

