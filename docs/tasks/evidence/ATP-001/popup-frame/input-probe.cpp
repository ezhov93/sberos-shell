// SPDX-License-Identifier: GPL-2.0-or-later
#include <QQmlExtensionPlugin>
#include <QQmlEngine>
#include <QQuickWindow>
#include <QQuickItem>
#include <QTest>
#include <QCursor>
#include <QDebug>
class Driver : public QObject {
 Q_OBJECT
 public:
 Q_INVOKABLE bool check(QQuickItem *item) {
  auto w=item->window();
  bool ok=true;
  for (const QPoint &p: QList<QPoint>{{0,0},{1,1},{24,1},{1,270},{487,1},{487,539},{244,539},{244,1}}) {
   QTest::mouseMove(w,p,10);
   qInfo()<<"POPUP_CURSOR"<<p<<w->cursor().shape();
   ok &= w->cursor().shape()==Qt::ArrowCursor;
  }
  item->forceActiveFocus();
  QTest::keyClick(w,Qt::Key_Tab);
  auto focus=w->activeFocusItem();
  qInfo()<<"POPUP_TAB"<<focus;
  ok &= focus && focus!=item;
  QTest::keyClick(w,Qt::Key_Backtab,Qt::ShiftModifier);
  qInfo()<<"POPUP_BACKTAB"<<w->activeFocusItem();
  QTest::keyClick(w,Qt::Key_Escape);
  QTest::qWait(100);
  qInfo()<<"POPUP_ESCAPE_VISIBLE"<<w->isVisible();
  ok &= !w->isVisible();
  qInfo()<<"POPUP_INPUT_OK"<<ok;
  return ok;
 }
};
class Plugin : public QQmlExtensionPlugin {
 Q_OBJECT
 Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
 public: void registerTypes(const char *uri) override {
  qmlRegisterSingletonType<Driver>(uri,1,0,"Driver",[](QQmlEngine*,QJSEngine*)->QObject* {return new Driver;});
 }
};
#include "driver.moc"
