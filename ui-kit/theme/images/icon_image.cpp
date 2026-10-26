#include "icon_image.h"

IconImage::IconImage(const QString &filename, const QSize &size, const QColor &color)
    : BaseImage(filename, size), Color(color) {}

IconImage::IconImage(const BaseImage &baseImage) : BaseImage(baseImage) {}

QVariant IconImage::GetProperty(size_t idx) const {
    if (idx == static_cast<size_t>(IconRole::Color))
        return QVariant::fromValue(Color);

    return BaseImage::GetProperty(idx);
}

void IconImage::setColor(const QColor &color) {
    Color = color;
}
