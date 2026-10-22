#pragma once

#include <QtQmlIntegration>
#include <QQmlEngine>


class Shell : public QObject {
  Q_OBJECT
  QML_SINGLETON
  QML_ELEMENT

public:
  explicit Shell(QObject* parent = nullptr);
  ~Shell() = default;

  Q_INVOKABLE QString run(const QString& command, const QStringList& args = QStringList()) const;
};
