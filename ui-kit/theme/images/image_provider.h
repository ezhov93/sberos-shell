#pragma once

#include <QQuickImageProvider>
#include <QtQmlIntegration>

// QML interface
class ImagesPack;
class ImgCreator;
class ImageProvider : public QQuickImageProvider {
    Q_OBJECT

public:
    explicit ImageProvider(ImagesPack &images, const ImgCreator &creator);

    virtual QImage requestImage(const QString &token, QSize *size,
                                const QSize &requestedSize) override;
    virtual QPixmap requestPixmap(const QString &token, QSize *size,
                                  const QSize &requestedSize) override;

protected:
    ImagesPack &ImagesData;
    const ImgCreator &Creator;

    QHash<QString, QImage> ImageCache;
};
