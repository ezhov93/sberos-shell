#pragma once

#include <QObject>
#include <QQmlApplicationEngine>
#include <QtQmlIntegration>

class FontsClass;
class PaletteClass;
class SizesClass;
class ImagesPack;


class Theme : public QObject {
  Q_OBJECT
  QML_SINGLETON
  QML_ELEMENT
  QML_UNCREATABLE("Theme is for C++ instantiation only")

public:
  static Theme* Get();

  Q_PROPERTY(FontsClass* Fonts READ GetFonts CONSTANT)
  Q_PROPERTY(PaletteClass* Palette READ GetPalette NOTIFY ThemeChanged)
  Q_PROPERTY(SizesClass* Sizes READ GetSizes NOTIFY ThemeChanged)

  QMap<QString, QString> GetAvaliableThemes() const;
  void SetThemeByFilename(const QString& filename);
  void SetTheme(QString name, bool force = false);
  void ReloadTheme();

signals:
  void ThemeChanged();

// QML interface
public:
  Q_INVOKABLE QStringList getAllImageNames() const;
  Q_INVOKABLE QVariantMap getAvaliableThemes() const;
  Q_INVOKABLE QList<QString> getAvaliableThemeNames() const;
  Q_INVOKABLE void setTheme(const QString& name);
  Q_INVOKABLE void reloadTheme();

// C++ interface
public:
  static FontsClass* GetFonts();
  static PaletteClass* GetPalette();
  static SizesClass* GetSizes();
  static ImagesPack& Images();

protected:
  Theme();
  ~Theme() = default;

  void LoadThemes();
  void LoadSizes();

  QMap<QString, QString> AvaliableThemes;
  QScopedPointer<PaletteClass> Palette;
  QScopedPointer<SizesClass> Sizes;

  bool NeedRefresh;
};
Q_DECLARE_METATYPE(Theme*)
Q_DECLARE_METATYPE(Theme)
