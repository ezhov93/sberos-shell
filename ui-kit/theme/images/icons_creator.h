#pragma once

#include <QColor>
#include <images/img_creator.h>

class IconsCreator : public ImgCreator {
public:
    QImage GetImage(const Image &img) const override;
};
