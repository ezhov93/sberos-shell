//////////////////////////////////////
// ATTENTION
// THIS IS GENERATED FILE, DON'T TOUCH
//////////////////////////////////////


#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlApplicationEngine>


class LineHeightClass : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("LineHeight is for C++ instantiation only")

public:
  LineHeightClass(QObject* parent = nullptr);
  LineHeightClass(const QJsonObject& json, QObject* parent = nullptr);
  virtual ~LineHeightClass() = default;
  
// QML interface
  Q_PROPERTY(int L MEMBER L CONSTANT);
  Q_PROPERTY(int M MEMBER M CONSTANT);
  Q_PROPERTY(int S MEMBER S CONSTANT);
  Q_PROPERTY(int Xs MEMBER Xs CONSTANT);
  Q_PROPERTY(int Xxs MEMBER Xxs CONSTANT);

// Members
  const int L;
  const int M;
  const int S;
  const int Xs;
  const int Xxs;
};
Q_DECLARE_METATYPE(LineHeightClass*)
Q_DECLARE_METATYPE(LineHeightClass)

