#pragma once

#include <QObject>
#include <QPixmap>
#include <QtQmlIntegration>


struct Notice {
  Q_GADGET

public:
  Q_PROPERTY(QString text MEMBER text);
  Q_PROPERTY(QString title MEMBER title);
  Q_PROPERTY(QString iconName MEMBER iconName);
  Q_PROPERTY(QString iconPath MEMBER iconPath);
  Q_PROPERTY(QImage image MEMBER image);
  Q_PROPERTY(bool closable MEMBER closable);
  Q_PROPERTY(int timeout MEMBER timeout);

  QString text;
  QString title;
  QString iconName;
  QString iconPath;
  QImage  image;
  bool    closable;
  int     timeout;

  Notice(const QString& text = QString(),
         const QString& title = QString(),
         const bool closable = false,
         const int timeout = 10000)
    : text(text),
      title(title),
      closable(closable),
      timeout(timeout) {}
  ~Notice() = default;
  Notice(const Notice&) = default;
  Notice& operator=(const Notice&) = default;
};
Q_DECLARE_METATYPE(Notice)


class Notifier : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Notifier is for C++ instantiation only")

public:
  Q_INVOKABLE Notice createNotify() const;
  Q_INVOKABLE void sendNotify(const Notice& message) const;
  Q_INVOKABLE void sendSystemNotify(const Notice& message) const;
  Q_INVOKABLE void sendSystemNotify(const QString& title, const QString& message) const;

signals:
  void newNotify(const Notice& message) const;

protected:
  Notifier(QObject* parent = nullptr);
  ~Notifier() = default;

  friend class Core;
};
Q_DECLARE_METATYPE(Notifier*)
Q_DECLARE_METATYPE(Notifier)
