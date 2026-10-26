#include <theme.h>

#include <core.h>
#include <fonts.h>
#include <images/icons_pack.h>
#include <images/icons_creator.h>
#include <images/image_provider.h>
#include <palette.h>
#include <resource_paths_p.h>
#include <sizes.h>
#include <settings.h>
#include <theme_functions.h>

#include <QApplication>
#include <QColor>
#include <QDir>
#include <QDirIterator>
#include <QFont>
#include <QJsonValue>
#include <QIcon>
#include <QRegularExpression>
#include <QSurfaceFormat>

#include <type_registration.h>

class QJSEngine;
void initilizeQMLEngine(QQmlEngine *engine, QJSEngine *) {
    static IconsCreator icons_creator;
    engine->addImageProvider("Default", new ImageProvider(Theme::Images(), icons_creator));
}
REGISTER_SINGLETON_INITILIZABLE_INSTANCE(Theme, "Sber.Theme", QString(VERSION_MAJOR).toInt(),
                                         QString(VERSION_MINOR).toInt(), "Theme",
                                         initilizeQMLEngine)

Theme::Theme() : NeedRefresh(false) {
    QApplication::instance()->setProperty("Theme", QVariant::fromValue(this));

    LoadThemes();
    LoadSizes();
    if (!AvaliableThemes.isEmpty()) {
        SetTheme(Core::GetSettings()->GetThemeName(), true);
    }

    connect(Core::GetSettings(), &Settings::IsDarkThemeChanged, this, [this]() { ReloadTheme(); });
}

Theme *Theme::Get() {
    static Theme _theme;
    return &_theme;
}

QMap<QString, QString> Theme::GetAvaliableThemes() const {
    return AvaliableThemes;
}

void Theme::SetThemeByFilename(const QString &filename) {
    const QJsonObject themeJson =
        ThemeFunctions::UploadTheme(SberComponents::resourcePath("theme/colors", true), filename);
    const auto themeName = Core::GetSettings()->GetIsDarkTheme() ? "Dark" : "Light";
    Palette.reset(new PaletteClass(themeJson[themeName].toObject()));
    NeedRefresh = true;
    emit ThemeChanged();
}

void Theme::SetTheme(QString name, bool force) {
    if (name.isEmpty() || !AvaliableThemes.contains(name))
        name = AvaliableThemes.firstKey();
    if (force || Core::GetSettings()->GetThemeName() != name) {
        SetThemeByFilename(AvaliableThemes[name]);
        Core::GetSettings()->SetThemeName(name);
    }
}

void Theme::ReloadTheme() {
    SetTheme(Core::GetSettings()->GetThemeName(), true);
}

QStringList Theme::getAllImageNames() const {
    return Theme::Images().GetAllImageNames();
}

QVariantMap Theme::getAvaliableThemes() const {
    QVariantMap v;
    for (const auto &[key, value] : AvaliableThemes.asKeyValueRange())
        v[key] = value;
    return v;
}

QList<QString> Theme::getAvaliableThemeNames() const {
    QList<QString> v;
    for (const auto &[key, value] : AvaliableThemes.asKeyValueRange())
        v << key;
    return v;
}

void Theme::setTheme(const QString &name) {
    SetTheme(name);
}

void Theme::reloadTheme() {
    ReloadTheme();
}

FontsClass *Theme::GetFonts() {
    return FontsClass::Get();
}

PaletteClass *Theme::GetPalette() {
    return Get()->Palette.data();
}

SizesClass *Theme::GetSizes() {
    return Get()->Sizes.data();
}

ImagesPack &Theme::Images() {
    static IconsPack pack(SberComponents::resourcePath("icons", true));
    return pack;
}

void Theme::LoadThemes() {
    const QString theme_file = SberComponents::resourcePath("theme/sdds_os.json");
    QFile f(theme_file);
    if (f.open(QIODevice::ReadOnly)) {
        const auto json = QJsonDocument::fromJson(f.readAll());
        if (json.isObject()) {
            const auto obj = json.object();
            if (obj.contains("Config") && obj["Config"].isObject()) {
                auto config = obj["Config"].toObject();
                if (config.contains("Name") && config["Name"].isString()) {
                    AvaliableThemes.insert(config["Name"].toString(), theme_file);
                }
            }
        }
    } else {
        qDebug() << "Components: Failed to open theme config " + theme_file;
    }
    if (AvaliableThemes.isEmpty()) {
        qDebug() << "Components: Failed to load themes";
    }
}

void Theme::LoadSizes() {
    const QString sizes_file = SberComponents::resourcePath("theme/sizes_os.json");
    QFile f(sizes_file);
    if (f.open(QIODevice::ReadOnly)) {
        const auto json = QJsonDocument::fromJson(f.readAll());
        if (json.isObject()) {
            Sizes.reset(new SizesClass(json.object()));
        }
    } else {
        qDebug() << "Components: Failed to open sizes config " + sizes_file;
    }
    if (AvaliableThemes.isEmpty()) {
        qDebug() << "Components: Failed to load sizes";
    }
}
