#include <images/image_provider.h>
#include <images/images_pack.h>
#include <images/image.h>
#include <images/img_creator.h>

static const QSize _DEFAULT_SIZE(24, 24);

ImageProvider::ImageProvider(ImagesPack &images, const ImgCreator &creator)
    : QQuickImageProvider(Image), ImagesData(images), Creator(creator) {}

QImage ImageProvider::requestImage(const QString &token, QSize *size, const QSize &requestedSize) {
    if (size)
        *size = _DEFAULT_SIZE;

    if (token.isEmpty()) {
        qDebug() << "empty token";
        return {};
    }

    const auto strPair = token.split('/');

    if (strPair.size() < 2) {
        qDebug() << "token does not have a color part";
        return {};
    }

    const auto &name = strPair[0];
    const QColor color = QColor{strPair[1]};
    const QSize q_size = requestedSize.isEmpty() ? _DEFAULT_SIZE : requestedSize;
    QString key =
        name + QString::number(q_size.width()) + QString::number(q_size.height()) + strPair[1];

    if (!ImageCache.contains(key))
        ImageCache[key] =
            ImagesData.GetImage(Creator, {.name = name, .size = q_size, .color = color});

    return ImageCache.value(key);
}

QPixmap ImageProvider::requestPixmap(const QString &token, QSize *size,
                                     const QSize &requestedSize) {
    return QPixmap::fromImage(requestImage(token, size, requestedSize));
}
