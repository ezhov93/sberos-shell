#include "lyrics.h"

#include <QCoreApplication>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QTemporaryDir>
#include <QTimer>
#include <QtTest>

class StubReply final : public QNetworkReply {
    Q_OBJECT
public:
    explicit StubReply(const QNetworkRequest &request, QObject *parent = nullptr)
        : QNetworkReply(parent) {
        setRequest(request);
        setUrl(request.url());
        setOperation(QNetworkAccessManager::GetOperation);
        open(QIODevice::ReadOnly | QIODevice::Unbuffered);
    }

    void finishWith(const QByteArray &data) {
        m_data = data;
        setAttribute(QNetworkRequest::HttpStatusCodeAttribute, 200);
        setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
        setFinished(true);
        emit readyRead();
        emit finished();
    }

    void abort() override {
        if (isFinished())
            return;
        setError(QNetworkReply::OperationCanceledError, QStringLiteral("cancelled"));
        setFinished(true);
        emit errorOccurred(error());
        emit finished();
    }

    qint64 bytesAvailable() const override { return m_data.size() + QNetworkReply::bytesAvailable(); }

protected:
    qint64 readData(char *data, qint64 maxSize) override {
        if (m_data.isEmpty())
            return -1;
        const qint64 amount = qMin(maxSize, qint64(m_data.size()));
        memcpy(data, m_data.constData(), size_t(amount));
        m_data.remove(0, qsizetype(amount));
        return amount;
    }

private:
    QByteArray m_data;
};

class StubNetworkAccessManager final : public QNetworkAccessManager {
    Q_OBJECT
public:
    using QNetworkAccessManager::QNetworkAccessManager;
    int requestCount = 0;
    StubReply *latestReply = nullptr;

protected:
    QNetworkReply *createRequest(Operation operation, const QNetworkRequest &request,
                                 QIODevice *outgoingData = nullptr) override {
        Q_UNUSED(operation);
        Q_UNUSED(outgoingData);
        ++requestCount;
        latestReply = new StubReply(request, this);
        if (requestCount == 2) {
            QPointer<StubReply> reply = latestReply;
            QTimer::singleShot(0, this, [reply] {
                if (reply)
                    reply->finishWith(R"({"plainLyrics":"second request lyrics"})");
            });
        }
        return latestReply;
    }
};

class LyricsTest : public QObject {
    Q_OBJECT

private slots:
    void lookupCanRestartAfterDisable();
};

void LyricsTest::lookupCanRestartAfterDisable() {
    StubNetworkAccessManager network;
    Lyrics lyrics(&network, nullptr);
    lyrics.setEnabled(true);
    lyrics.lookup(QStringLiteral("Test track"), QStringLiteral("Test artist"), {}, 180);
    QCOMPARE(network.requestCount, 1);
    QCOMPARE(lyrics.status(), QStringLiteral("loading"));

    lyrics.setEnabled(false);
    QCOMPARE(lyrics.status(), QStringLiteral("idle"));
    lyrics.setEnabled(true);
    lyrics.lookup(QStringLiteral("Test track"), QStringLiteral("Test artist"), {}, 180);
    QCOMPARE(network.requestCount, 2);

    QTRY_COMPARE_WITH_TIMEOUT(lyrics.status(), QStringLiteral("ready"), 1000);
    QCOMPARE(lyrics.plain(), QStringLiteral("second request lyrics"));
}

int main(int argc, char **argv) {
    QTemporaryDir cacheHome;
    if (!cacheHome.isValid())
        return 2;
    qputenv("XDG_CACHE_HOME", cacheHome.path().toUtf8());
    QCoreApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("sirca-lyrics-test"));
    LyricsTest test;
    return QTest::qExec(&test, argc, argv);
}

#include "test_lyrics.moc"
