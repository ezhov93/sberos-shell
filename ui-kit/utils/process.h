#pragma once

#include <QProcess>
#include <QtQmlIntegration>
#include <QVariant>

class Process : public QObject {
    Q_OBJECT
    QML_ELEMENT

public:
    explicit Process(QObject *parent = nullptr);
    ~Process();

    Q_PROPERTY(QVariantList arguments READ arguments WRITE setArguments)
    Q_PROPERTY(int exitCode READ exitCode NOTIFY finished)
    Q_PROPERTY(int processId READ processId NOTIFY started)
    Q_PROPERTY(QString program READ program WRITE setProgram)
    Q_PROPERTY(QString workingDirectory READ workingDirectory WRITE setWorkingDirectory)

    Q_INVOKABLE QVariantList arguments() const;
    Q_INVOKABLE int exitCode() const;
    Q_INVOKABLE void kill();
    Q_INVOKABLE int processId() const;
    Q_INVOKABLE QString program() const;
    Q_INVOKABLE QByteArray readAllStandardError();
    Q_INVOKABLE QByteArray readAllStandardOutput();
    Q_INVOKABLE void setArguments(const QVariantList &args);
    Q_INVOKABLE void setProgram(const QString &program);
    Q_INVOKABLE void setWorkingDirectory(const QString &dir);
    Q_INVOKABLE void start(const QString &program, const QVariantList &args);
    Q_INVOKABLE void start();
    Q_INVOKABLE void startDetached(const QString &program, const QVariantList &args);
    Q_INVOKABLE void startDetached();
    Q_INVOKABLE void terminate();
    Q_INVOKABLE void waitForFinished(const int msecs = 30000);
    Q_INVOKABLE void waitForStarted(const int msecs = 30000);
    Q_INVOKABLE QString workingDirectory() const;
    Q_INVOKABLE void write(const QString &command);
    Q_INVOKABLE void closeWriteChannel();

signals:
    void finished(int exitCode);
    void readyReadStandardError();
    void readyReadStandardOutput();
    void started();

protected:
    QProcess Instance;
};
