//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>


class BorderRadiusClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("BorderRadius is for C++ instantiation only")

public:
  BorderRadiusClass(QObject* parent = nullptr);
  BorderRadiusClass(const QJsonObject& json, QObject* parent = nullptr);
  virtual ~BorderRadiusClass() = default;
  
// QML interface
  Q_PROPERTY(int L MEMBER L CONSTANT);
  Q_PROPERTY(int M MEMBER M CONSTANT);
  Q_PROPERTY(int S MEMBER S CONSTANT);
  Q_PROPERTY(int Xl MEMBER Xl CONSTANT);
  Q_PROPERTY(int Xs MEMBER Xs CONSTANT);
  Q_PROPERTY(int Xxl MEMBER Xxl CONSTANT);
  Q_PROPERTY(int Xxs MEMBER Xxs CONSTANT);

// Members
  const int L;
  const int M;
  const int S;
  const int Xl;
  const int Xs;
  const int Xxl;
  const int Xxs;
};
Q_DECLARE_METATYPE(BorderRadiusClass*)
Q_DECLARE_METATYPE(BorderRadiusClass)

