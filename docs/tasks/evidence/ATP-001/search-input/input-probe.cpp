#include <QQmlExtensionPlugin>
#include <QQmlEngine>
#include <QQuickWindow>
#include <QQuickItem>
#include <QTest>
#include <QDebug>
#include <QRegion>
#include <QImage>
class Driver : public QObject {
 Q_OBJECT
public:
 QQuickItem *field(QQuickItem *item) {
  if(item->property("placeholderText").isValid() && item->isVisible()) return item;
  for(auto child:item->childItems()) if(auto result=field(child)) return result;
  return nullptr;
 }
 void dump(QQuickItem *item) {
  if (item->property("placeholderText").isValid()) qInfo()<<"SEARCH_FIELD"<<item<<item->isVisible()<<item->isEnabled()<<item->hasActiveFocus()<<item->hasFocus()<<item->mapToGlobal(QPointF(0,0));
  for(auto child:item->childItems()) dump(child);
 }
 Q_INVOKABLE bool check(QQuickItem *applet) {
  auto compact=applet->property("compactRepresentationItem").value<QQuickItem*>();
  auto full=applet->property("fullRepresentationItem").value<QQuickItem*>();
  if (!compact || !full) { qInfo()<<"SEARCH_POPUP_OK"<<false; return false; }
  auto panel=compact->window(); auto popup=full->window();
  applet->setProperty("expanded",false);
  QTest::qWait(150);
  QTest::mouseClick(panel,Qt::LeftButton,Qt::NoModifier,compact->mapToScene(QPointF(250,36)).toPoint());
  QTest::qWait(400);
  dump(full);
  auto actual=qobject_cast<QQuickWindow*>(QGuiApplication::focusWindow());
  bool ok=actual==popup;
  qInfo()<<"SEARCH_FOCUS_ITEM"<<panel->activeFocusItem();
  qInfo()<<"SEARCH_NATIVE_FOCUS"<<actual<<panel<<popup<<ok<<panel->flags();
  auto island=compact->mapToGlobal(QPointF(0,0));
  bool maskOk=false;
  for(auto background:popup->contentItem()->childItems()) {
   if(!QString(background->metaObject()->className()).contains("DialogBackground")) continue;
   for(auto frame:background->childItems()) {
    auto mask=frame->property("mask").value<QRegion>();
    if(mask.isEmpty()) continue;
    maskOk=mask.contains(QPoint(228,300)) && mask.contains(QPoint(228,633)) && !mask.contains(QPoint(228,593)) && !mask.contains(QPoint(0,0));
   }
  }
  qInfo()<<"SEARCH_NATIVE_MASK"<<maskOk; ok &= maskOk;
  bool geometry=popup->height()==669 && popup->geometry().bottom()+1==qRound(island.y()+compact->height()) && popup->y()+589+8==qRound(island.y());
  qInfo()<<"SEARCH_GEOMETRY"<<popup->geometry()<<island<<geometry; ok &= geometry;
  if(actual) {
   qInfo()<<"SEARCH_BEFORE_KEYS"<<actual->activeFocusItem();
   for(char c:QByteArray("sberos-input-probe")) QTest::keyClick(actual,c);
   QTest::qWait(500);
  }
  bool typed=applet->property("searchText").toString()==QStringLiteral("sberos-input-probe");
  qInfo()<<"SEARCH_TYPED"<<typed<<applet->property("searchText"); ok &= typed;
  bool query=false;
  for(auto child:full->findChildren<QObject*>()) {
   if(child->property("queryString").toString()==QStringLiteral("sberos-input-probe")) query=true;
  }
  qInfo()<<"SEARCH_MODEL_QUERY"<<query; ok &= query;
  if(actual) {
   QTest::keyClick(actual,Qt::Key_A,Qt::ControlModifier);
   for(char c:QByteArray("edited-probe")) QTest::keyClick(actual,c);
   QTest::qWait(150);
  }
  bool edited=applet->property("searchText").toString()==QStringLiteral("edited-probe");
  qInfo()<<"SEARCH_EDITED"<<edited; ok &= edited;
  int controls=0;
  if(auto input=field(full)) for(auto sibling:input->parentItem()->childItems()) {
   if(sibling->isVisible() && sibling->property("checkable").isValid() && sibling->width()>0) controls++;
  }
  qInfo()<<"SEARCH_PERSISTENT_CONTROLS"<<controls; ok &= controls==2;
  popup->grabWindow().save("/tmp/sber-search-typed.png");
  if(actual) QTest::keyClick(actual,Qt::Key_Escape);
  QTest::qWait(200);
  bool closed=!applet->property("expanded").toBool() && !popup->isVisible();
  qInfo()<<"SEARCH_ESCAPE"<<closed; ok &= closed;
  QTest::mouseClick(panel,Qt::LeftButton,Qt::NoModifier,compact->mapToScene(QPointF(250,36)).toPoint());
  QTest::qWait(500);
  actual=qobject_cast<QQuickWindow*>(QGuiApplication::focusWindow());
  bool reopen=applet->property("expanded").toBool() && actual==popup;
  if(reopen) for(char c:QByteArray("again-probe")) QTest::keyClick(actual,c);
  QTest::qWait(150);
  reopen &= applet->property("searchText").toString()==QStringLiteral("again-probe");
  qInfo()<<"SEARCH_REOPEN"<<reopen; ok &= reopen;
  if(actual) {
   QTest::keyClick(actual,Qt::Key_A,Qt::ControlModifier);
   QTest::keyClick(actual,Qt::Key_Backspace);
  }
  QTest::qWait(100);
  QTest::mouseClick(popup,Qt::LeftButton,Qt::NoModifier,QPoint(36,633));
  QTest::qWait(400);
  bool notifications=applet->property("notificationsOpen").toBool() && popup->height()==282
    && popup->geometry().bottom()+9==qRound(island.y());
  qInfo()<<"SEARCH_NOTIFICATIONS"<<notifications<<popup->geometry(); ok &= notifications;
  QTest::mouseClick(panel,Qt::LeftButton,Qt::NoModifier,compact->mapToScene(QPointF(250,36)).toPoint());
  QTest::qWait(400);
  actual=qobject_cast<QQuickWindow*>(QGuiApplication::focusWindow());
  bool returned=!applet->property("notificationsOpen").toBool() && actual==popup && popup->height()==669;
  if(actual) for(char c:QByteArray("returned-probe")) QTest::keyClick(actual,c);
  QTest::qWait(150);
  returned &= applet->property("searchText").toString()==QStringLiteral("returned-probe");
  qInfo()<<"SEARCH_RETURN_FROM_NOTIFICATIONS"<<returned; ok &= returned;
  if(actual) QTest::keyClick(actual,Qt::Key_Escape);
  qInfo()<<"SEARCH_POPUP_OK"<<ok; return ok;
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
