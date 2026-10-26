#pragma once

#include <QVariant>

class QSize;
class QString;
class QPixmap;

class Image {
public:
    virtual ~Image() = default;

    virtual QVariant GetProperty(size_t idx) const = 0;
};
