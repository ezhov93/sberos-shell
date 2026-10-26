#pragma once

#include <QByteArray>
#include <QDBusArgument>
#include <QImage>

struct IIIBIIAY {
    int width;
    int height;
    int rowStride;
    bool hasAlpha;
    int bitsPerSample;
    int channels;
    QByteArray data;

    IIIBIIAY(QImage image) {
        image = image.scaled(200, 100);
        width = image.width();
        height = image.height();
        rowStride = image.bytesPerLine();
        hasAlpha = image.hasAlphaChannel();
        channels = image.isGrayscale() ? 1 : hasAlpha ? 4 : 3;
        bitsPerSample = image.depth() / channels;
        data.append((char *)image.bits(), image.sizeInBytes());
    }
    IIIBIIAY() = default;
    ~IIIBIIAY() = default;
    IIIBIIAY(const IIIBIIAY &) = default;
    IIIBIIAY &operator=(const IIIBIIAY &) = default;
};
Q_DECLARE_METATYPE(IIIBIIAY);

QDBusArgument &operator<<(QDBusArgument &a, const IIIBIIAY &i) {
    a.beginStructure();
    a << i.width << i.height << i.rowStride << i.hasAlpha << i.bitsPerSample << i.channels
      << i.data;
    a.endStructure();
    return a;
}

const QDBusArgument &operator>>(const QDBusArgument &a, IIIBIIAY &i) {
    a.beginStructure();
    a >> i.width >> i.height >> i.rowStride >> i.hasAlpha >> i.bitsPerSample >> i.channels >>
        i.data;
    a.endStructure();
    return a;
}
