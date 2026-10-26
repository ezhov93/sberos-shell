#include "appargs.h"

#include <QCoreApplication>

#include <type_registration.h>
REGISTER_SINGLETON_TYPE(AppArgs, "Sber.Utils", QString(VERSION_MAJOR).toInt(),
                        QString(VERSION_MINOR).toInt(), "AppArgs")

QStringList AppArgs::getKeys() const {
    return Args.keys();
}

bool AppArgs::hasKey(const QString &key) const {
    return Args.contains(key);
}

QVariantList AppArgs::args(const QString &key) const {
    return Args.value(key);
}

QVariant AppArgs::arg(const QString &key) const {
    return Args.value(key).value(0);
}

AppArgs::AppArgs(QObject *parent) : QObject{parent} {
    parse();
}

void AppArgs::parse() {
    const auto arg_list = QCoreApplication::arguments();

    QString key;
    bool ok = false;
    for (qsizetype i = 1; i < arg_list.size(); ++i) {
        const QString token = arg_list.at(i);

        const double numberToken = token.toDouble(&ok);
        if (token.front() != '-' || token.front() == '-' && ok) {
            if (!key.isEmpty()) {
                if (ok)
                    Args[key].append(numberToken);
                else
                    Args[key].append(token);
            }
        } else {
            if (!key.isEmpty() && !Args.contains(key))
                Args[key].append(true);
            key = token;
            if (key.startsWith('-'))
                key = key.removeFirst();
        }
    }
}
