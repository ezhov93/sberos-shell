//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <outline_on_dark.h>


OutlineOnDarkClass::OutlineOnDarkClass(QObject* parent) 
  : QObject(parent)
  , Accent("")
  , AccentActive("")
  , AccentGradient("")
  , AccentGradientActive("")
  , AccentGradientHover("")
  , AccentHover("")
  , Info("")
  , InfoActive("")
  , InfoHover("")
  , Negative("")
  , NegativeActive("")
  , NegativeHover("")
  , Positive("")
  , PositiveActive("")
  , PositiveHover("")
  , PromoGradient("")
  , PromoGradientActive("")
  , PromoGradientHover("")
  , SolidPrimary("")
  , SolidPrimaryActive("")
  , SolidPrimaryHover("")
  , SolidSecondary("")
  , SolidSecondaryActive("")
  , SolidSecondaryHover("")
  , SolidTertiary("")
  , SolidTertiaryActive("")
  , SolidTertiaryHover("")
  , Warning("")
  , WarningActive("")
  , WarningHover("") {}

OutlineOnDarkClass::OutlineOnDarkClass(const QJsonObject& json, QObject* parent)
  : QObject(parent)
  , Accent(json["Accent"].toString())
  , AccentActive(json["AccentActive"].toString())
  , AccentGradient(json["AccentGradient"].toString())
  , AccentGradientActive(json["AccentGradientActive"].toString())
  , AccentGradientHover(json["AccentGradientHover"].toString())
  , AccentHover(json["AccentHover"].toString())
  , Info(json["Info"].toString())
  , InfoActive(json["InfoActive"].toString())
  , InfoHover(json["InfoHover"].toString())
  , Negative(json["Negative"].toString())
  , NegativeActive(json["NegativeActive"].toString())
  , NegativeHover(json["NegativeHover"].toString())
  , Positive(json["Positive"].toString())
  , PositiveActive(json["PositiveActive"].toString())
  , PositiveHover(json["PositiveHover"].toString())
  , PromoGradient(json["PromoGradient"].toString())
  , PromoGradientActive(json["PromoGradientActive"].toString())
  , PromoGradientHover(json["PromoGradientHover"].toString())
  , SolidPrimary(json["SolidPrimary"].toString())
  , SolidPrimaryActive(json["SolidPrimaryActive"].toString())
  , SolidPrimaryHover(json["SolidPrimaryHover"].toString())
  , SolidSecondary(json["SolidSecondary"].toString())
  , SolidSecondaryActive(json["SolidSecondaryActive"].toString())
  , SolidSecondaryHover(json["SolidSecondaryHover"].toString())
  , SolidTertiary(json["SolidTertiary"].toString())
  , SolidTertiaryActive(json["SolidTertiaryActive"].toString())
  , SolidTertiaryHover(json["SolidTertiaryHover"].toString())
  , Warning(json["Warning"].toString())
  , WarningActive(json["WarningActive"].toString())
  , WarningHover(json["WarningHover"].toString()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! OutlineOnDark map is empty";
}


