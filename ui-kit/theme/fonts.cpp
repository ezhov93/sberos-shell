#include <fonts.h>
#include <resource_paths_p.h>

#include <QJsonDocument>
#include <QJsonArray>
#include <QFile>
#include <QFontDatabase>

FontsClass *FontsClass::Get() {
    static FontsClass _fonts;
    return &_fonts;
}

QFont FontsClass::GetFont(const QString &tag) const {
    return FontsMap.value(tag, FontsMap.value("bodyM"));
}

// upload fonts settings
FontsClass::FontsClass() : FontsBase() {
    QFile fontStyles(SberComponents::resourcePath("theme/font_styles.json"));
    if (fontStyles.open(QIODevice::ReadOnly)) {
        auto json = QJsonDocument::fromJson(fontStyles.readAll());
        if (json.isObject()) {
            const auto obj = json.object();
            for (auto it = obj.begin(); it != obj.end(); ++it) {
                if (it.value().isObject()) {
                    auto fontObj = it.value().toObject();
                    QFont font(fontObj["fontFamily"].toString());
                    font.setWeight(QFont::Weight(fontObj["fontWeight"].toInt()));
                    font.setPixelSize(fontObj["textSize"].toInt());
                    font.setLetterSpacing(QFont::PercentageSpacing,
                                          (1. + fontObj["letterSpacing"].toDouble()) * 100);
                    FontsMap[it.key()] = font;
                }
            }
        }
    }
    if (FontsMap.isEmpty()) {
        qDebug() << "Components: Failed to open fonts styles";
    }
}
