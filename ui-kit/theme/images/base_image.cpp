#include "base_image.h"

BaseImage::BaseImage(const QString& filename, const QSize& size)
    : Path(filename), Size(size) {}

QVariant BaseImage::GetProperty(size_t idx) const {
    if (idx < static_cast<int>(Role::Last))
        return  static_cast<Role>(idx) == Role::Path ? QVariant::fromValue(Path) : QVariant::fromValue(Size);

    return QVariant();
}


