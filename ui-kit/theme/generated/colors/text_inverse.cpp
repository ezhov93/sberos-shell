//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#include <text_inverse.h>


TextInverseClass::TextInverseClass(QObject* parent) 
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
  , Primary("")
  , PrimaryActive("")
  , PrimaryHover("")
  , PromoGradient("")
  , PromoGradientActive("")
  , PromoGradientHover("")
  , Secondary("")
  , SecondaryActive("")
  , SecondaryHover("")
  , Tertiary("")
  , TertiaryActive("")
  , TertiaryHover("")
  , Warning("")
  , WarningActive("")
  , WarningHover("") {}

TextInverseClass::TextInverseClass(const QJsonObject& json, QObject* parent)
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
  , Primary(json["Primary"].toString())
  , PrimaryActive(json["PrimaryActive"].toString())
  , PrimaryHover(json["PrimaryHover"].toString())
  , PromoGradient(json["PromoGradient"].toString())
  , PromoGradientActive(json["PromoGradientActive"].toString())
  , PromoGradientHover(json["PromoGradientHover"].toString())
  , Secondary(json["Secondary"].toString())
  , SecondaryActive(json["SecondaryActive"].toString())
  , SecondaryHover(json["SecondaryHover"].toString())
  , Tertiary(json["Tertiary"].toString())
  , TertiaryActive(json["TertiaryActive"].toString())
  , TertiaryHover(json["TertiaryHover"].toString())
  , Warning(json["Warning"].toString())
  , WarningActive(json["WarningActive"].toString())
  , WarningHover(json["WarningHover"].toString()) {
  if (json.isEmpty())
    qDebug() << "Components: Warning! TextInverse map is empty";
}


