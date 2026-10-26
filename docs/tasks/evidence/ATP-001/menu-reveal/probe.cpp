// SPDX-License-Identifier: GPL-2.0-or-later
#include <QQmlExtensionPlugin>
#include <QQmlEngine>
#include <QQuickWindow>
#include <QQuickItem>
#include <QTest>
#include <QDebug>
#include <QRegion>
#include <QDir>
class Driver : public QObject {
 Q_OBJECT
 QQuickItem *full(QQuickItem *a) {return a->property("fullRepresentationItem").value<QQuickItem*>();}
 QQuickItem *button(QQuickItem *a) {
  auto c=a->property("compactRepresentationItem").value<QQuickItem*>();
  return c ? c->property("menuButton").value<QQuickItem*>() : nullptr;
 }
 QRegion mask(QQuickWindow *w) {
  for(auto b:w->contentItem()->childItems()) {
   if(!QString(b->metaObject()->className()).contains("PlasmaQuick::DialogBackground"))continue;
   for(auto f:b->childItems()) if(f->property("mask").isValid()) return f->property("mask").value<QRegion>();
  }
  return {};
 }
 public:
 Q_INVOKABLE bool check(QQuickItem *a) {
  auto p=full(a);auto b=button(a);
  if(!p||!b){qInfo()<<"MENU_REVEAL_OK false missing items";return false;}
  auto original=b;auto origin=b->mapToGlobal(QPointF());
  bool ok=p->property("reveal").toDouble()==1;
  qInfo()<<"WINDOW"<<p->window()->size()<<p->window()->property("leftPadding")<<p->window()->property("bottomPadding")<<"APPLET"<<a->size()<<a->property("panelExtent")<<"BUTTON_VISIBLE"<<b->isVisible();
  qInfo()<<"OPEN_BUTTON"<<b<<origin<<b->size();
  QMetaObject::invokeMethod(a,"closeMenu"); QTest::qWait(350);
  qInfo()<<"CLOSED_BUTTON"<<button(a)<<b->mapToGlobal(QPointF())<<a->property("expanded");
  ok &= !a->property("expanded").toBool() && b==button(a) && b->mapToGlobal(QPointF())==origin;
  QMetaObject::invokeMethod(a,"toggleMenu");
  bool intermediate=false;int frame=0;
  const auto out=qEnvironmentVariable("SBER_MENU_EVIDENCE");
  for(int step=0;step<22;step++) {
   QTest::qWait(15);auto v=p->property("reveal").toDouble();
   auto region=mask(p->window());
   ok &= region.contains(QPoint(36,215));
   if(v>0 && v<1) {
    intermediate=true;
    const int top=216-(72+qRound(v*72)*2);
    const bool empty=top<2 || !region.contains(QPoint(36,top-2));
    qInfo()<<"REVEAL"<<v<<"TOP"<<top<<"EMPTY"<<empty<<"BUTTON"<<b->mapToGlobal(QPointF());
    ok &= empty && b->mapToGlobal(QPointF())==origin;
   }
   p->window()->grabWindow().save(out+QString("/motion-%1.png").arg(frame++,2,10,QChar('0')));
  }
  ok &= intermediate && p->property("reveal").toDouble()==1 && b==original;
  p->forceActiveFocus();QTest::keyClick(p->window(),Qt::Key_Tab);
  qInfo()<<"TAB"<<p->window()->activeFocusItem();
  ok &= p->window()->activeFocusItem() && p->window()->activeFocusItem()!=p;
  a->setProperty("powerMenuOpen",true);QTest::qWait(180);
  auto region=mask(p->window());
  qInfo()<<"POWER"<<p->size()<<"EMPTY"<<region.contains(QPoint(36,24))<<region.contains(QPoint(76,100));
  ok &= p->size()==QSizeF(352,264) && !region.contains(QPoint(36,24)) && !region.contains(QPoint(76,100));
  p->window()->grabWindow().save(out+"/power.png");
  QTest::keyClick(p->window(),Qt::Key_Escape);QTest::qWait(180);
  ok &= !a->property("powerMenuOpen").toBool() && a->property("expanded").toBool();
  QTest::keyClick(p->window(),Qt::Key_Escape);QTest::qWait(350);
  ok &= !a->property("expanded").toBool() && b==button(a) && b->mapToGlobal(QPointF())==origin;
  qInfo()<<"MENU_REVEAL_OK"<<ok;
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
