//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////

#pragma once

#include <QFont>
#include <QObject>
#include <QtQmlIntegration>


class FontsBase : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("FontsBase is for C++ instantiation only")

public: 
  FontsBase(QObject* parent = nullptr);
  ~FontsBase() = default;
  
  virtual QFont GetFont(const QString& tag) const = 0;
  
// QML interface
  Q_PROPERTY(QFont BodyL READ GetBodyL CONSTANT);
  Q_PROPERTY(QFont BodyLB READ GetBodyLB CONSTANT);
  Q_PROPERTY(QFont BodyM READ GetBodyM CONSTANT);
  Q_PROPERTY(QFont BodyMB READ GetBodyMB CONSTANT);
  Q_PROPERTY(QFont BodyS READ GetBodyS CONSTANT);
  Q_PROPERTY(QFont BodySB READ GetBodySB CONSTANT);
  Q_PROPERTY(QFont BodyXs READ GetBodyXs CONSTANT);
  Q_PROPERTY(QFont BodyXsB READ GetBodyXsB CONSTANT);
  Q_PROPERTY(QFont BodyXxs READ GetBodyXxs CONSTANT);
  Q_PROPERTY(QFont BodyXxsB READ GetBodyXxsB CONSTANT);
  Q_PROPERTY(QFont DisplayL READ GetDisplayL CONSTANT);
  Q_PROPERTY(QFont DisplayLB READ GetDisplayLB CONSTANT);
  Q_PROPERTY(QFont DisplayM READ GetDisplayM CONSTANT);
  Q_PROPERTY(QFont DisplayMB READ GetDisplayMB CONSTANT);
  Q_PROPERTY(QFont DisplayS READ GetDisplayS CONSTANT);
  Q_PROPERTY(QFont DisplaySB READ GetDisplaySB CONSTANT);
  Q_PROPERTY(QFont HeaderH1 READ GetHeaderH1 CONSTANT);
  Q_PROPERTY(QFont HeaderH1B READ GetHeaderH1B CONSTANT);
  Q_PROPERTY(QFont HeaderH2 READ GetHeaderH2 CONSTANT);
  Q_PROPERTY(QFont HeaderH2B READ GetHeaderH2B CONSTANT);
  Q_PROPERTY(QFont HeaderH3 READ GetHeaderH3 CONSTANT);
  Q_PROPERTY(QFont HeaderH3B READ GetHeaderH3B CONSTANT);
  Q_PROPERTY(QFont HeaderH4 READ GetHeaderH4 CONSTANT);
  Q_PROPERTY(QFont HeaderH4B READ GetHeaderH4B CONSTANT);
  Q_PROPERTY(QFont HeaderH5 READ GetHeaderH5 CONSTANT);
  Q_PROPERTY(QFont HeaderH5B READ GetHeaderH5B CONSTANT);
  Q_PROPERTY(QFont TextL READ GetTextL CONSTANT);
  Q_PROPERTY(QFont TextLB READ GetTextLB CONSTANT);
  Q_PROPERTY(QFont TextM READ GetTextM CONSTANT);
  Q_PROPERTY(QFont TextMB READ GetTextMB CONSTANT);
  Q_PROPERTY(QFont TextS READ GetTextS CONSTANT);
  Q_PROPERTY(QFont TextSB READ GetTextSB CONSTANT);
  Q_PROPERTY(QFont TextXs READ GetTextXs CONSTANT);
  Q_PROPERTY(QFont TextXsB READ GetTextXsB CONSTANT);

// C++ interface
  QFont GetBodyL();
  QFont GetBodyLB();
  QFont GetBodyM();
  QFont GetBodyMB();
  QFont GetBodyS();
  QFont GetBodySB();
  QFont GetBodyXs();
  QFont GetBodyXsB();
  QFont GetBodyXxs();
  QFont GetBodyXxsB();
  QFont GetDisplayL();
  QFont GetDisplayLB();
  QFont GetDisplayM();
  QFont GetDisplayMB();
  QFont GetDisplayS();
  QFont GetDisplaySB();
  QFont GetHeaderH1();
  QFont GetHeaderH1B();
  QFont GetHeaderH2();
  QFont GetHeaderH2B();
  QFont GetHeaderH3();
  QFont GetHeaderH3B();
  QFont GetHeaderH4();
  QFont GetHeaderH4B();
  QFont GetHeaderH5();
  QFont GetHeaderH5B();
  QFont GetTextL();
  QFont GetTextLB();
  QFont GetTextM();
  QFont GetTextMB();
  QFont GetTextS();
  QFont GetTextSB();
  QFont GetTextXs();
  QFont GetTextXsB();
};
Q_DECLARE_METATYPE(FontsBase*)
Q_DECLARE_METATYPE(const FontsBase*)
Q_DECLARE_METATYPE(FontsBase)
Q_DECLARE_METATYPE(const FontsBase)

