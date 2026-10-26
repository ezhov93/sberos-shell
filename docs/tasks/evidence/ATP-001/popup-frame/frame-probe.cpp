// SPDX-License-Identifier: GPL-2.0-or-later
#include <QApplication>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQuickItem>
#include <QQuickWindow>
#include <QTimer>
#include <QCursor>
#include <QTest>
#include <KSvg/FrameSvg>
#include <PlasmaQuick/AppletPopup>
#include <QDebug>
int main(int argc, char **argv) {
 QApplication app(argc, argv);
 QQmlEngine engine;
 QQmlComponent comp(&engine);
 comp.setData("import QtQuick; import QtQuick.Layouts; Rectangle { implicitWidth: 488; implicitHeight: 540; color: '#d9ffffff'; radius: 24; Layout.minimumWidth: 488; Layout.maximumWidth: 488; Layout.minimumHeight: 540; Layout.maximumHeight: 540 }", QUrl());
 auto item=qobject_cast<QQuickItem*>(comp.create());
 if (!item) {qCritical()<<comp.errors(); return 2;}
 PlasmaQuick::AppletPopup popup;
 popup.setMainItem(item);
 popup.setPosition(400,200);
 popup.show();
 QTimer::singleShot(500,[&]{
  qInfo()<<"BEFORE"<<popup.padding()<<popup.size();
  for(auto child: popup.contentItem()->childItems()) {
   if(!QString(child->metaObject()->className()).contains("DialogBackground")) continue;
   child->setOpacity(0);
   for(auto frame: child->childItems()) {
    qInfo()<<"FRAME"<<frame->metaObject()->className()<<frame->property("imagePath");
    if(argc>1) frame->setProperty("imagePath", QString::fromLocal8Bit(argv[1]));
   }
  }
  QTimer::singleShot(600,[&]{
   qInfo()<<"AFTER"<<popup.padding()<<popup.size()<<popup.topPadding();
   bool cursorOk=true;
   const QList<QPoint> points{{0,0},{1,1},{24,1},{1,270},{487,1},{487,539},{244,539},{244,1}};
   for(auto point: points) {
    QTest::mouseMove(&popup,point,10);
    qInfo()<<"CURSOR"<<point<<popup.cursor().shape();
    cursorOk &= popup.cursor().shape()==Qt::ArrowCursor;
   }
   KSvg::FrameSvg svg;
   if(argc>1) {
    svg.setImagePath(QString::fromLocal8Bit(argv[1])); svg.resizeFrame(QSizeF(488,540));
    auto mask=svg.mask();
    qInfo()<<"MASK"<<mask.boundingRect()<<mask.contains(QPoint(0,0))<<mask.contains(QPoint(24,0))<<mask.contains(QPoint(244,270));
   }
   popup.grabWindow().save("/tmp/sber-popup-probe/after.png");
   app.exit(argc>1 && (popup.padding()!=QMargins() || !cursorOk) ? 1:0);
  });
 });
 return app.exec();
}
