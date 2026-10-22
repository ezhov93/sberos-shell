#pragma once

#include <QtQmlIntegration>
#include <QQmlEngine>


class Clipboard : public QObject {
  Q_OBJECT
  QML_SINGLETON
  QML_ELEMENT

  Q_PROPERTY(QString text READ GetText WRITE SetText NOTIFY TextChanged)

public:
  explicit Clipboard(QObject* parent = nullptr);
  ~Clipboard() = default;

protected:
  QString GetText() const;
  void SetText(const QString& text) const;

signals:
  void TextChanged();
};
