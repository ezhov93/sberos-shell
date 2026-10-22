#include <images/icons_creator.h>
#include <images/icon_image.h>

#include <QImage>
#include <QPixmap>
#include <QDebug>
#include <QPainter>
#include <QSvgRenderer>

template<typename T>
constexpr size_t toUint(T val) {
    return static_cast<size_t>(val);
}

QImage IconsCreator::GetImage(const Image& img) const {

  const auto pathIdx = toUint(BaseImage::Role::Path);
  const auto path = img.GetProperty(pathIdx).toString();
  QSvgRenderer renderer(path);
  if (!renderer.isValid()) {
    qDebug() << "Components: Failed to open svg icon " << path;
    return {};
  }

  const auto sizeIdx = toUint(BaseImage::Role::Size);
  const auto size = img.GetProperty(sizeIdx).toSize();
  QImage image(size, QImage::Format_ARGB32);
  image.fill(Qt::transparent);

  QPainter painter(&image);
  painter.setRenderHint(QPainter::Antialiasing);
  painter.setRenderHint(QPainter::SmoothPixmapTransform);

  renderer.render(&painter, QRectF(QPointF(), size));
  painter.setCompositionMode(QPainter::CompositionMode_SourceIn);
  const auto colorIdx = toUint(IconImage::IconRole::Color);
  painter.fillRect(image.rect(), img.GetProperty(colorIdx).toString());
  painter.end();
  return image;
}
