#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QVariantMap>

class AppArgs : public QObject {
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    explicit AppArgs(QObject *parent = nullptr);
    ~AppArgs() = default;
    Q_INVOKABLE QStringList getKeys() const;
    Q_INVOKABLE bool hasKey(const QString &key) const;
    Q_INVOKABLE QVariantList args(const QString &key) const;
    Q_INVOKABLE QVariant arg(const QString &key) const;

protected:
    void parse();

    QMap<QString, QVariantList> Args;
};
