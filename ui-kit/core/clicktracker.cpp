#include "clicktracker.h"

#include <QCoreApplication>
#include <QDBusPendingReply>
#include <QDebug>
#include <QQmlContext>
#include <QQmlEngine>

namespace {
const QString DBusService = QStringLiteral("org.sberos.ClickTracker");
const QString DBusPath = QStringLiteral("/org/sberos/ClickTracker");
const QString DBusIface = QStringLiteral("org.sberos.ClickTracker");

constexpr auto CustomNameProp = "clickTrackerName";
constexpr auto DBusMethodName = "RegisterClick";
} // namespace

ClickTracker::ClickTracker(QObject *parent)
    : QObject(parent), m_dbus(DBusService, DBusPath, DBusIface, QDBusConnection::systemBus()) {}

QString ClickTracker::qmlName(const QObject *obj) {
    const auto *ctx = QQmlEngine::contextForObject(obj);
    if (!ctx)
        return {};
    return ctx->nameForObject(obj);
}

void ClickTracker::registerClick(QObject *element) {
    if (!element)
        return;

    const auto appName = QCoreApplication::applicationName();
    if (appName.isEmpty())
        return;

    auto clickTrackerName = element->property(CustomNameProp).toString();
    clickTrackerName.remove(QRegularExpression("[ \\n\\t\\v\\f\\r]"));

    if (!clickTrackerName.isEmpty()) {
        callDBusRegisterClick(appName, clickTrackerName);
        return;
    }

    QStringList names;
    for (auto *current = element; current; current = current->parent()) {
        const QString name = qmlName(current);
        if (!name.isEmpty())
            names.prepend(name);
    }
    auto path = names.join('.');

    callDBusRegisterClick(appName, path);
    return;
}

void ClickTracker::callDBusRegisterClick(const QString &sourceId, const QString &elementId) {
    auto pendingCall = m_dbus.asyncCall(DBusMethodName, sourceId, elementId);
    auto *watcher = new QDBusPendingCallWatcher(pendingCall, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this,
            [this, sourceId, elementId](QDBusPendingCallWatcher *w) {
                QDBusPendingReply<bool> reply(*w);
                if (reply.isError()) {
                    qWarning() << "D-Bus RegisterClick failed for" << sourceId << elementId << ":"
                               << reply.error().message();
                    emit clickFailed(sourceId, elementId);
                }
                w->deleteLater();
            });
}
