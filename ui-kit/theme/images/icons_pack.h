#pragma once

#include <QHash>
#include <QImage>
#include <QMap>
#include <QWeakPointer>

#include <images/image.h>
#include <images/images_pack.h>

class IconsPack : public ImagesPack {
  using ImagePtr = QSharedPointer<Image>;
public:
  explicit IconsPack(const QString& folder);
  QImage GetImage(const ImgCreator& creator,  const Params& params) const override;
  QStringList GetAllImageNames() const override;

protected:
  const QWeakPointer<Image> ImageSrc(const QString& name, const QSize& size) const;
  static void FolderParse(const QString& path);

  const QString FolderPath;
  static QMap<QString, QMap<int, ImagePtr>> Sources;

  template <typename T>
  constexpr size_t toUint(T val) const {
    return static_cast<size_t>(val);
  }
};
