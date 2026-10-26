#pragma once

#include <QHash>
#include <QString>

class TrayRequestSerials {
public:
    quint64 beginRefresh() {
        m_latestRefresh = ++m_next;
        return m_latestRefresh;
    }
    quint64 beginPropertyFetch(const QString &name) {
        const quint64 serial = ++m_next;
        m_propertyFetches.insert(name, serial);
        return serial;
    }
    bool isCurrentRefresh(quint64 serial) const {
        return serial == m_latestRefresh;
    }
    bool refreshMayApplyProperty(const QString &name, quint64 refreshSerial) const {
        return m_propertyFetches.value(name, 0) <= refreshSerial;
    }
    bool isCurrentPropertyFetch(const QString &name, quint64 serial) const {
        return serial > m_latestRefresh && serial == m_propertyFetches.value(name, 0);
    }

private:
    quint64 m_next = 0, m_latestRefresh = 0;
    QHash<QString, quint64> m_propertyFetches;
};
