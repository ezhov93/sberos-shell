// Accent from the wallpaper (Material-You style): `Palette.fromImage(path)` /
// `Palette.themeForWallpaper(path)`. The shell derives the accent for its own surfaces. The steps
// are deterministic and documented in palette.cpp.
#pragma once
#include <QImage>
#include <QJSValue>
#include <QObject>
#include <QString>
#include <QVariantMap>
#include <qqml.h>

class Palette : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    explicit Palette(QObject *parent = nullptr);
    // {accent, accentLight, hue (degrees), chroma, sourceChroma, source (the winning box),
    // swatches: [{hex, population, chroma}]}. accent: OKLCH L ~0.62 (a touch more for yellows), C
    // 0.10..0.20: reads on dark and on light panel surfaces; accentLight is the same hue 0.12 darker,
    // for things that sit on white. An unreadable file gives an empty map.
    Q_INVOKABLE QVariantMap fromImage(const QString &path) const;
    // a Config.themes entry: {accent, dark: path, light: lightPath || path}. The accent comes from
    // `path` (the dark picture when the theme has two: it is the one on screen most of the day
    // here)
    Q_INVOKABLE QVariantMap themeForWallpaper(const QString &path,
                                              const QString &lightPath = QString()) const;
    // the same off the GUI thread: decoding a 5120-wide PNG takes ~100 ms; callback(theme) runs on
    // the GUI thread
    Q_INVOKABLE void themeForWallpaperAsync(const QString &path, const QString &lightPath,
                                            const QJSValue &callback);
    static QVariantMap analyse(const QImage &image);
};
