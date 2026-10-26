#pragma once

#include "image.h"

#include <QSize>
#include <QString>

class BaseImage : public Image {
public:
    enum class Role : size_t { Path, Size, Last };
    explicit BaseImage(const QString &filename, const QSize &size);
    virtual QVariant GetProperty(size_t idx) const override;

private:
    QString Path;
    QSize Size;
};
