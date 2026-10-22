#include <images/base_image.h>
#include <images/icon_image.h>
#include <images/icons_pack.h>
#include <images/img_creator.h>
#include <images/icon_image.h>

#include <mutex>
#include <QDirIterator>
#include <QFileInfo>

QMap<QString, QMap<int, IconsPack::ImagePtr>> IconsPack::Sources = {};

IconsPack::IconsPack(const QString& folder)
    : FolderPath(folder) {}

const QWeakPointer<Image> IconsPack::ImageSrc(const QString& name, const QSize& size) const {
  static std::once_flag initFlag;
  std::call_once(initFlag, &IconsPack::FolderParse, FolderPath);

  if(Sources[name].isEmpty())
    return QWeakPointer<Image>();

  int w_size = size.width();
  const auto keys = Sources[name].keys();
  if(!keys.contains(w_size)) {
    auto end = keys.end() - 1;
    auto iter = std::min(std::upper_bound(keys.cbegin(), keys.cend(), w_size), end);
    const auto basePtr = Sources[name][*iter];
    const auto pathVariant = basePtr->GetProperty(toUint(BaseImage::Role::Path));
    Sources[name][w_size] = ImagePtr(new BaseImage(pathVariant.toString(), size));
  }

  return Sources[name][w_size];
}

void IconsPack::FolderParse(const QString& path) {
  if (!QFileInfo(path).isDir()) {
    qWarning() << "Path is not a directory:" << path;
    return;
  }

  QDirIterator it(path, QStringList() << "*.svg",
                  QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot,
                  QDirIterator::Subdirectories);

  int size = 0;
  while (it.hasNext()) {
    const QFileInfo fi(it.next());
    if(!fi.isDir()) {
      Sources[fi.baseName()][size] = ImagePtr(new BaseImage(fi.absoluteFilePath(), {size, size}));
    } else {
      size = fi.baseName().toInt();
    }
  }
}

QImage IconsPack::GetImage(const ImgCreator& creator, const Params& params) const {
  const auto ptr = qSharedPointerCast<BaseImage>(ImageSrc(params.name, params.size));
  if (!ptr.isNull()) {
    auto img = IconImage(*ptr);
    img.setColor(params.color);
    return creator.GetImage(img);
  }
  return {};
}

QStringList IconsPack::GetAllImageNames() const {
  return Sources.keys();
}
