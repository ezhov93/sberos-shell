#pragma once

#include <QColor>
#include <QSize>

class QImage;
class Image;

class ImgCreator {
public:
  virtual ~ImgCreator() = default;
  virtual QImage GetImage(const Image& svg) const = 0;
};
