#pragma once

#include <QtQmlIntegration>
#include <QQmlEngine>

class AppScreen : public QObject {
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    explicit AppScreen(QObject *parent = nullptr);
    ~AppScreen() = default;

    Q_INVOKABLE void create(QObject *appWindow);

    static QString screenshotsDir();

public slots:
    void notificationActionInvoked(uint notificationId, QString actionKey);

private:
    void notify();

    QString m_fullPath;
};
