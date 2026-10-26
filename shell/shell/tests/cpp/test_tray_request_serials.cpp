#include "trayrequestserials_p.h"

#include <QtTest>

class TrayRequestSerialsTest : public QObject {
    Q_OBJECT

private slots:
    void laterRefreshRejectsOlderRefresh();
    void propertyFetchWinsOverOlderRefresh();
    void laterPropertyFetchRejectsOlderFetch();
};

void TrayRequestSerialsTest::laterRefreshRejectsOlderRefresh() {
    TrayRequestSerials serials;
    const quint64 older = serials.beginRefresh();
    const quint64 newer = serials.beginRefresh();

    QVERIFY(!serials.isCurrentRefresh(older));
    QVERIFY(serials.isCurrentRefresh(newer));
}

void TrayRequestSerialsTest::propertyFetchWinsOverOlderRefresh() {
    TrayRequestSerials serials;
    const quint64 refresh = serials.beginRefresh();
    const quint64 property = serials.beginPropertyFetch(QStringLiteral("Title"));

    QVERIFY(!serials.refreshMayApplyProperty(QStringLiteral("Title"), refresh));
    QVERIFY(serials.isCurrentPropertyFetch(QStringLiteral("Title"), property));
}

void TrayRequestSerialsTest::laterPropertyFetchRejectsOlderFetch() {
    TrayRequestSerials serials;
    serials.beginRefresh();
    const quint64 older = serials.beginPropertyFetch(QStringLiteral("Title"));
    const quint64 newer = serials.beginPropertyFetch(QStringLiteral("Title"));

    QVERIFY(!serials.isCurrentPropertyFetch(QStringLiteral("Title"), older));
    QVERIFY(serials.isCurrentPropertyFetch(QStringLiteral("Title"), newer));
}

QTEST_GUILESS_MAIN(TrayRequestSerialsTest)
#include "test_tray_request_serials.moc"
