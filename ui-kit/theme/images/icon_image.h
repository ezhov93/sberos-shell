#pragma once

#include "base_image.h"

#include <QColor>

class IconImage : public BaseImage {
public:
    enum class IconRole : size_t {
        Color = static_cast<size_t>(IconImage::Role::Last) + 1,
        Last
    };
    explicit IconImage(const QString& filename, const QSize& size, const QColor& color);
    explicit IconImage(const BaseImage& baseImage);

    virtual QVariant GetProperty(size_t idx) const override;
    void setColor(const QColor& color);

protected:
    QColor Color;
};
