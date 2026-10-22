#include <core.h>

#include <type_registration.h>
REGISTER_SINGLETON_TYPE(Core, "Sber.Core", QString(VERSION_MAJOR).toInt(), QString(VERSION_MINOR).toInt(), "Core")


Core* Core::Get() {
  static Core _core;
  return &_core;
}

Settings* Core::GetSettings() {
  return Get()->SettingsInst;
}

Notifier* Core::GetNotifier() {
  return Get()->NotifierInst;
}

ClickTracker* Core::GetClickTracker() {
  return Get()->ClickTrackerInst;
}

Core::Core()
  : QObject(),
    SettingsInst(new Settings(this)),
    NotifierInst(new Notifier(this)),
    ClickTrackerInst(new ClickTracker(this))
{
    setTranslation();
}

void Core::setTranslation() {
    const auto translationsPath = QString{"%1/Sber/po/%2.qm"}
                    .arg(QLibraryInfo::path(QLibraryInfo::QmlImportsPath), QLocale::system().bcp47Name());

    if (!QFile::exists(translationsPath)) {
        qDebug() << "Translation file not found";
        return;
    }

    auto* translator = new QTranslator(this);

    if (translator->load(translationsPath)) {
        qApp->installTranslator(translator);
    } else {
        qDebug() << "Failed to load translation file";
    }
}
