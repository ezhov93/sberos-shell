#pragma once

#include <fonts_base.h>

#include <QFont>
#include <QJsonObject>
#include <QObject>
#include <QtQmlIntegration>


class FontsClass : public FontsBase {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON
  QML_UNCREATABLE("FontsClass is for C++ instantiation only")

public:
  static FontsClass* Get();
  Q_INVOKABLE QFont GetFont(const QString& tag) const;

protected:
  FontsClass();
  ~FontsClass() = default;

  QMap<QString, QFont> FontsMap;
};
Q_DECLARE_METATYPE(FontsClass*)
Q_DECLARE_METATYPE(FontsClass)
