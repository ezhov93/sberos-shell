#include <settings.h>

#include <QApplication>
#include <QFileInfo>
#include <QProcess>
#include <QStyleHints>


const QString THEME_NAME_KEY = "theme_name";
const QString THEME_MODE_KEY = "theme_mode";
const QString LINE_HEIGHT_KEY = "line_height";
bool APP_IN_SYSTEM_MODE = false;

QString Settings::GetSettingsPath() {
  static const auto dir = QStandardPaths::locate(QStandardPaths::GenericDataLocation, QString(),
                                                 QStandardPaths::LocateOption::LocateDirectory);
  return dir + QApplication::applicationName();
}


Settings::Settings(QObject* parent)
  : QObject(parent),
    ThemeMode(Settings::System),
    LineHeight(0) {
  const auto appName = QApplication::applicationName();
  if (appName.isEmpty() || appName.endsWith(".py"))
    SetAppInSystemMode();

  LoadSettings();
  if (ThemeMode == Settings::System) {
    QApplication::instance()->installEventFilter(this);
  }
}

Settings::~Settings() {
  SaveSettings();
}

void Settings::LoadSettings() {
  QSettings settings(GetSettingsPath(), QSettings::IniFormat);
  settings.beginGroup("General");

  ThemeName = settings.value(THEME_NAME_KEY).toString();
  ThemeMode = APP_IN_SYSTEM_MODE ? Settings::System : settings.value(THEME_MODE_KEY, Settings::System).toInt();
  LineHeight = settings.value(LINE_HEIGHT_KEY).toInt();

  settings.endGroup();
}

void Settings::SaveSettings() const {
  if (!APP_IN_SYSTEM_MODE) {
    QSettings settings(GetSettingsPath(), QSettings::IniFormat);
    settings.beginGroup("General");

    settings.setValue(THEME_NAME_KEY, ThemeName);
    settings.setValue(THEME_MODE_KEY, ThemeMode);
    settings.setValue(LINE_HEIGHT_KEY, LineHeight);

    settings.endGroup();
  }
}

QString Settings::GetThemeName() const {
  return ThemeName;
}

void Settings::SetThemeName(const QString& name) {
  if (ThemeName != name) {
    ThemeName = name;
    emit ThemeNameChanged(ThemeName);
    SaveSettings();
  }
}

bool Settings::GetIsDarkTheme() const {
  if (ThemeMode == Settings::System)
    return GetSystemIsDarkMode();
  return ThemeMode == Settings::Dark;
}

uint Settings::getThemeMode() const {
  return ThemeMode;
}

void Settings::setThemeMode(const uint mode) {
  if (ThemeMode != mode) {
    if (mode == Settings::System) {
      QApplication::instance()->installEventFilter(this);
    } else if (ThemeMode == Settings::System) {
      QApplication::instance()->removeEventFilter(this);
    }
    ThemeMode = mode;
    emit IsDarkThemeChanged(GetIsDarkTheme());
    SaveSettings();
  }
}

int Settings::GetLineHeight() {
  if (LineHeight)
    return LineHeight;
  if (auto theme = QPointer(QApplication::instance()->property("Theme").value<QObject*>())) {
    if (auto sizes = QPointer(theme->property("Sizes").value<QObject*>())) {
      if (auto height = QPointer(sizes->property("LineHeight").value<QObject*>())) {
        LineHeight = height->property("S").toInt();
      }
    }
  }
  return LineHeight;
}

void Settings::SetLineHeight(const int height) {
  if (LineHeight != height) {
    LineHeight = height;
    emit LineHeightChanged(LineHeight);
    SaveSettings();
  }
}

void Settings::SetAppInSystemMode() {
  APP_IN_SYSTEM_MODE = true;
}

bool Settings::eventFilter(QObject* watched, QEvent* event) {
  if (event->type() == QEvent::ThemeChange)
    emit IsDarkThemeChanged(GetSystemIsDarkMode());
  return false;
}

bool Settings::GetSystemIsDarkMode() const {
  return QGuiApplication::styleHints()->colorScheme() == Qt::ColorScheme::Dark;
}
