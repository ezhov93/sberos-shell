#include "clipboard.h"

#include <QGuiApplication>
#include <QClipboard>

#include <type_registration.h>
REGISTER_SINGLETON_TYPE(Clipboard, "Sber.Utils", QString(VERSION_MAJOR).toInt(), QString(VERSION_MINOR).toInt(), "Clipboard")


Clipboard::Clipboard(QObject* parent)
  : QObject(parent) {
  QClipboard* clipboard = QGuiApplication::clipboard();
  connect(clipboard, &QClipboard::dataChanged, this, &Clipboard::TextChanged);
}

QString Clipboard::GetText() const {
  return QGuiApplication::clipboard()->text(QClipboard::Clipboard);
}

void Clipboard::SetText(const QString& text) const {
  QGuiApplication::clipboard()->setText(text, QClipboard::Clipboard);
}
