#include "SettingsBridge.h"

#include <QJsonDocument>

void SettingsBridge::appearanceSnapshot() { callAppearance({ QStringLiteral("snapshot") }); }

void SettingsBridge::updateGlobalIconMode(const QString& mode)
{
    callAppearance({ QStringLiteral("updateGlobalIconMode"), mode });
}

void SettingsBridge::updateGlobalIconOpacity(double opacity)
{
    callAppearance({ QStringLiteral("updateGlobalIconOpacity"), QString::number(opacity, 'f', 3) });
}

void SettingsBridge::updateGlobalIconTintColor(const QString& color)
{
    callAppearance({ QStringLiteral("updateGlobalIconTintColor"), color });
}

void SettingsBridge::updateSpatialWallpaperEnabled(bool enabled)
{
    callAppearance({ QStringLiteral("updateSpatialWallpaperEnabled"),
        enabled ? QStringLiteral("true") : QStringLiteral("false") });
}

void SettingsBridge::updateBarVisibilityMode(const QString& mode)
{
    callAppearance({ QStringLiteral("updateBarVisibilityMode"), mode });
}

void SettingsBridge::updateDockWindowAnimationStyle(const QString& style)
{
    callAppearance({ QStringLiteral("updateDockWindowAnimationStyle"), style });
}

void SettingsBridge::applySystemAppearance(bool dark)
{
    callShell(QStringLiteral("appearance-settings"),
        { QStringLiteral("applySystemAppearance"),
            dark ? QStringLiteral("true") : QStringLiteral("false") },
        QStringLiteral("Appearance settings request failed"), RequestKind::ApplySystemAppearance);
}

QVariantMap SettingsBridge::appearanceSnapshotFromReply(const QString& payload)
{
    if (payload.isEmpty())
        return { };

    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(payload.toUtf8(), &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
        setLastError(
            QStringLiteral("The desktop environment returned an invalid appearance configuration"));
        return { };
    }

    const QJsonObject object = document.object();
    if (!object.contains(QStringLiteral("dockWindowAnimationStyle"))) {
        setLastError(QStringLiteral(
            "The appearance configuration from the desktop environment is incomplete"));
        return { };
    }

    const QString barVisibility
        = object.value(QStringLiteral("barVisibilityMode")).toString(QStringLiteral("always"));

    setLastError({ });
    return {
        { QStringLiteral("iconMode"),
            object.value(QStringLiteral("iconMode")).toString(QStringLiteral("color")) },
        { QStringLiteral("iconOpacity"),
            object.value(QStringLiteral("iconOpacity")).toDouble(0.5) },
        { QStringLiteral("iconTintColor"),
            object.value(QStringLiteral("iconTintColor")).toString(QStringLiteral("#a855f7")) },
        { QStringLiteral("spatialWallpaperEnabled"),
            object.value(QStringLiteral("spatialWallpaperEnabled")).toBool(false) },
        { QStringLiteral("barVisibilityMode"),
            barVisibility.isEmpty() ? QStringLiteral("always") : barVisibility },
        { QStringLiteral("dockWindowAnimationStyle"),
            object.value(QStringLiteral("dockWindowAnimationStyle")).toString() },
        { QStringLiteral("tokenVersion"), object.value(QStringLiteral("tokenVersion")).toInt() },
    };
}

void SettingsBridge::callAppearance(const QStringList& arguments)
{
    callShell(QStringLiteral("appearance-settings"), arguments,
        QStringLiteral("Appearance settings request failed"), RequestKind::Appearance);
}
