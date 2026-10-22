#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QtQml/qqmlmoduleregistration.h>


class File : public QObject {
  Q_OBJECT
  QML_SINGLETON
  QML_ELEMENT

public:
  explicit File(QObject* parent = nullptr);
  ~File() = default;

  Q_INVOKABLE bool appendData(const QString& path, const QByteArray& data);
  Q_INVOKABLE bool copyFile(const QString& source, const QString& dest);
  Q_INVOKABLE bool exists(const QString& path);
  Q_INVOKABLE bool isDir(const QString& path);
  Q_INVOKABLE bool isFile(const QString& path);
  Q_INVOKABLE QStringList listFiles(const QString& path, const QStringList& formats = QStringList());
  Q_INVOKABLE QStringList listDirs(const QString& path);
  Q_INVOKABLE QByteArray readFile(const QString& path);
  Q_INVOKABLE bool removeFile(const QString& path);
  Q_INVOKABLE bool removeDir(const QString& path);
  Q_INVOKABLE bool writeFile(const QString& path, const QByteArray& data = QByteArray());
};
