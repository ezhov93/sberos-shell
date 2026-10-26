#include "calendarmodel.h"

#include <QFile>
#include <QTemporaryDir>
#include <QtTest>

class CalendarModelTest : public QObject {
    Q_OBJECT

private slots:
    void monthlyRecurrenceSkipsMonthsWithoutStartDay();
    void yearlyRecurrenceSkipsYearsWithoutStartDate();
};

void CalendarModelTest::monthlyRecurrenceSkipsMonthsWithoutStartDay() {
    QTemporaryDir directory;
    QVERIFY(directory.isValid());
    QFile file(directory.filePath(QStringLiteral("monthly.ics")));
    QVERIFY(file.open(QIODevice::WriteOnly | QIODevice::Text));
    file.write("BEGIN:VCALENDAR\r\n"
               "BEGIN:VEVENT\r\n"
               "UID:monthly\r\n"
               "DTSTART:20240131T090000Z\r\n"
               "DTEND:20240131T100000Z\r\n"
               "RRULE:FREQ=MONTHLY\r\n"
               "SUMMARY:Monthly\r\n"
               "END:VEVENT\r\n"
               "END:VCALENDAR\r\n");
    file.close();

    CalendarModel model;
    model.setDirs({directory.path()});
    const QVariantList occurrences = model.occurrences(QDate(2024, 1, 1), QDate(2024, 5, 31));

    QCOMPARE(occurrences.size(), 3);
    QCOMPARE(occurrences.at(0).toMap().value(QStringLiteral("firstDay")).toString(),
             QStringLiteral("2024-01-31"));
    QCOMPARE(occurrences.at(1).toMap().value(QStringLiteral("firstDay")).toString(),
             QStringLiteral("2024-03-31"));
    QCOMPARE(occurrences.at(2).toMap().value(QStringLiteral("firstDay")).toString(),
             QStringLiteral("2024-05-31"));
}

void CalendarModelTest::yearlyRecurrenceSkipsYearsWithoutStartDate() {
    QTemporaryDir directory;
    QVERIFY(directory.isValid());
    QFile file(directory.filePath(QStringLiteral("yearly.ics")));
    QVERIFY(file.open(QIODevice::WriteOnly | QIODevice::Text));
    file.write("BEGIN:VCALENDAR\r\n"
               "BEGIN:VEVENT\r\n"
               "UID:yearly\r\n"
               "DTSTART:20240229T090000Z\r\n"
               "DTEND:20240229T100000Z\r\n"
               "RRULE:FREQ=YEARLY\r\n"
               "SUMMARY:Yearly\r\n"
               "END:VEVENT\r\n"
               "END:VCALENDAR\r\n");
    file.close();

    CalendarModel model;
    model.setDirs({directory.path()});
    const QVariantList occurrences = model.occurrences(QDate(2025, 1, 1), QDate(2028, 12, 31));

    QCOMPARE(occurrences.size(), 1);
    QCOMPARE(occurrences.first().toMap().value(QStringLiteral("firstDay")).toString(),
             QStringLiteral("2028-02-29"));
}

QTEST_GUILESS_MAIN(CalendarModelTest)
#include "test_calendarmodel.moc"
