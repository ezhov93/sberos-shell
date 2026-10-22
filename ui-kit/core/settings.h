#pragma once

#include <QObject>
#include <QtQmlIntegration>


class Settings : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Settings is for C++ instantiation only")

public:
  enum ThemeModes {
    Light,
    Dark,
    System
  };
  Q_ENUM(ThemeModes)

  enum class HeaderButtons {
      Close = 1,
      Maximize = 2,
      Minimize = 4
  };
  Q_ENUM(HeaderButtons)

  static QString GetSettingsPath();
  static void SetAppInSystemMode();

  Q_PROPERTY(const QString ThemeName READ GetThemeName WRITE SetThemeName NOTIFY ThemeNameChanged)
  Q_PROPERTY(const bool IsDarkTheme READ GetIsDarkTheme NOTIFY IsDarkThemeChanged)
  Q_PROPERTY(const int LineHeight READ GetLineHeight WRITE SetLineHeight NOTIFY LineHeightChanged)

public:
  QString GetThemeName() const;
  void    SetThemeName(const QString&);
  bool    GetIsDarkTheme() const;
  int     GetLineHeight();
  void    SetLineHeight(const int);
  Q_INVOKABLE uint getThemeMode() const;
  Q_INVOKABLE void setThemeMode(const uint);

public slots:
  bool eventFilter(QObject* watched, QEvent* event);

signals:
  void ThemeNameChanged(QString);
  void IsDarkThemeChanged(bool);
  void LineHeightChanged(int);

protected:
  Settings(QObject* parent = nullptr);
  ~Settings();

  void LoadSettings();
  void SaveSettings() const;
  bool GetSystemIsDarkMode() const;

  QString ThemeName;
  uint ThemeMode;
  int  LineHeight;

  friend class Core;
};
Q_DECLARE_METATYPE(Settings*)
Q_DECLARE_METATYPE(Settings)
