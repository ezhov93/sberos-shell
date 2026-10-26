#include "process.h"

#include <type_registration.h>
REGISTER_CREATABLE_TYPE(Process, "Sber.Utils", QString(VERSION_MAJOR).toInt(),
                        QString(VERSION_MINOR).toInt(), "Process")

QStringList fromVariant(const QVariantList &vars) {
    QStringList list;
    for (const auto &var : vars)
        list << var.toString();
    return list;
}

QVariantList toVariant(const QStringList &vars) {
    QVariantList list;
    for (const auto &var : vars)
        list << var;
    return list;
}

Process::Process(QObject *parent) : QObject(parent) {
    connect(&Instance, &QProcess::finished, this, &Process::finished);
    connect(&Instance, &QProcess::readyReadStandardError, this, &Process::readyReadStandardError);
    connect(&Instance, &QProcess::readyReadStandardOutput, this, &Process::readyReadStandardOutput);
    connect(&Instance, &QProcess::started, this, &Process::started);
}

Process::~Process() {
    if (Instance.state() != QProcess::NotRunning) {
        Instance.terminate();
        Instance.waitForFinished(300);
        Instance.kill();
    }
}

QVariantList Process::arguments() const {
    return toVariant(Instance.arguments());
}

int Process::exitCode() const {
    return Instance.exitCode();
}

void Process::kill() {
    Instance.kill();
}

int Process::processId() const {
    return Instance.processId();
}

QString Process::program() const {
    return Instance.program();
}

QByteArray Process::readAllStandardError() {
    return Instance.readAllStandardError();
}

QByteArray Process::readAllStandardOutput() {
    return Instance.readAllStandardOutput();
}

void Process::terminate() {
    Instance.terminate();
}

void Process::setArguments(const QVariantList &args) {
    Instance.setArguments(fromVariant(args));
}

void Process::setProgram(const QString &program) {
    Instance.setProgram(program);
}

void Process::setWorkingDirectory(const QString &dir) {
    Instance.setWorkingDirectory(dir);
}

void Process::start(const QString &program, const QVariantList &args) {
    Instance.start(program, fromVariant(args));
}

void Process::start() {
    Instance.start();
}

void Process::startDetached(const QString &program, const QVariantList &args) {
    Instance.startDetached(program, fromVariant(args));
}

void Process::startDetached() {
    Instance.startDetached();
}

void Process::waitForFinished(const int msecs) {
    Instance.waitForFinished(msecs);
}

void Process::waitForStarted(const int msecs) {
    Instance.waitForStarted(msecs);
}

QString Process::workingDirectory() const {
    return Instance.workingDirectory();
}

void Process::write(const QString &command) {
    Instance.write(QString(command + "\n").toStdString().c_str());
}

void Process::closeWriteChannel() {
    Instance.closeWriteChannel();
}
