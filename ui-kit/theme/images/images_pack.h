#pragma once

#include <QColor>
#include <QStringList>

#include <img_creator.h>

class QImage;
class QSize;
class Image;

class ImagesPack {
public:
    struct Params {
        QString name;
        QSize size;
        QColor color;
    };
    virtual ~ImagesPack() = default;
    virtual QImage GetImage(const ImgCreator &creator, const Params &params) const = 0;
    virtual QStringList GetAllImageNames() const = 0;
};
