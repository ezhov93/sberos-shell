#include "file.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>

#include <type_registration.h>
REGISTER_SINGLETON_TYPE(File, "Sber.Utils", QString(VERSION_MAJOR).toInt(), QString(VERSION_MINOR).toInt(), "File")


File::File(QObject* parent)
  : QObject(parent) {}

bool File::appendData(const QString& path, const QByteArray& data) {
  QFile file(path);
  if (file.open(QIODevice::Append)) {
    file.write(data);
    return true;
  }
  return false;
}

bool File::copyFile(const QString& source, const QString& dest) {
  return QFile::copy(source, dest);
}

bool File::exists(const QString& path) {
  return QFileInfo::exists(path);
}

bool File::isDir(const QString& path) {
  QFileInfo info(path);
  return info.isDir();
}

bool File::isFile(const QString& path) {
  QFileInfo info(path);
  return info.isFile();
}

QStringList File::listFiles(const QString& path, const QStringList& formats) {
  QDir dir(path);
  return dir.entryList(formats, QDir::Files);
}

QStringList File::listDirs(const QString& path) {
  QDir dir(path);
  return dir.entryList(QDir::Dirs);
}

QByteArray File::readFile(const QString& path) {
  QFile file(path);
  if (file.open(QIODevice::ReadOnly))
    return file.readAll();
  return {};
}

bool File::removeFile(const QString& path) {
  if (isFile(path)) {
    return QFile::remove(path);
  }
  return false;
}

bool File::removeDir(const QString& path) {
  if (isDir(path)) {
    QDir dir(path);
    return dir.removeRecursively();
  }
  return false;
}

bool File::writeFile(const QString& path, const QByteArray& data) {
  QFile file(path);
  if (file.open(QIODevice::WriteOnly)) {
    file.write(data);
    return true;
  }
  return false;
}
