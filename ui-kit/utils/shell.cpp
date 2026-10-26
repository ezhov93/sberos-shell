#include "shell.h"

#include <QStringList>

#include <type_registration.h>
REGISTER_SINGLETON_TYPE(Shell, "Sber.Utils", QString(VERSION_MAJOR).toInt(),
                        QString(VERSION_MINOR).toInt(), "Shell")

QString Shell::run(const QString &command, const QStringList &args) const {
    QProcess proc;
    proc.start("bash", {"-c", command + ' ' + args.join(' ')});
    proc.waitForFinished(3000);
    if (proc.exitCode() != 0) {
        qDebug() << QString::fromUtf8(proc.readAllStandardError());
        return {};
    }
    QString result = proc.readAllStandardOutput();
    if (result.endsWith('\n'))
        result = result.removeLast();
    if (result.endsWith(' '))
        result = result.removeLast();
    return result;
}

Shell::Shell(QObject *parent) : QObject(parent) {}
