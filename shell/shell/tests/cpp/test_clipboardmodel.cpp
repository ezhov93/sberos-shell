#include "clipboardmodel.h"

#include <QApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>
#include <QTemporaryDir>
#include <QtTest>

class ClipboardModelTest : public QObject {
    Q_OBJECT

private slots:
    void delayedSaveIsFlushedAtShutdown();
};

void ClipboardModelTest::delayedSaveIsFlushedAtShutdown() {
    const QString historyPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) +
                                QStringLiteral("/sirca-shell/clipboard/history.json");
    QVERIFY(QDir().mkpath(QFileInfo(historyPath).path()));

    QFile history(historyPath);
    QVERIFY(history.open(QIODevice::WriteOnly));
    history.write("[{\"kind\":\"text\",\"text\":\"saved\",\"image\":\"\","
                  "\"time\":\"2026-10-23T00:00:00Z\",\"note\":\"\",\"pinned\":false}]");
    history.close();

    {
        ClipboardModel model;
        QCOMPARE(model.count(), 1);
        model.togglePin(0); // schedules the normal delayed disk write

        QVERIFY(history.open(QIODevice::ReadOnly));
        const QJsonArray beforeShutdown = QJsonDocument::fromJson(history.readAll()).array();
        history.close();
        QVERIFY(!beforeShutdown.first().toObject().value(QStringLiteral("pinned")).toBool());
    } // destroying the model must flush that pending write

    QVERIFY(history.open(QIODevice::ReadOnly));
    const QJsonArray afterShutdown = QJsonDocument::fromJson(history.readAll()).array();
    history.close();
    QCOMPARE(afterShutdown.size(), 1);
    QVERIFY(afterShutdown.first().toObject().value(QStringLiteral("pinned")).toBool());
}

int main(int argc, char **argv) {
    QTemporaryDir dataHome;
    if (!dataHome.isValid())
        return 2;
    qputenv("XDG_DATA_HOME", dataHome.path().toUtf8());
    QApplication app(argc, argv);
    ClipboardModelTest test;
    return QTest::qExec(&test, argc, argv);
}

#include "test_clipboardmodel.moc"
