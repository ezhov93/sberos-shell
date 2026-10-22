#pragma once

#include <QObject>
#include <QtQmlIntegration>

#include <clicktracker.h>
#include <notifier.h>
#include <settings.h>

class Core : public QObject {
  Q_OBJECT
  QML_SINGLETON
  QML_ELEMENT
  QML_UNCREATABLE("Core is for C++ instantiation only")

public:
  Q_PROPERTY(Settings *Settings READ GetSettings CONSTANT)
  Q_PROPERTY(Notifier *Notifier READ GetNotifier CONSTANT)
  Q_PROPERTY(ClickTracker *ClickTracker READ GetClickTracker CONSTANT)

public:
  static Core *Get();
  static Settings *GetSettings();
  static Notifier *GetNotifier();
  static ClickTracker *GetClickTracker();

private:
  Core();
  ~Core() = default;

  void setTranslation();

  Settings *SettingsInst;
  Notifier *NotifierInst;
  ClickTracker *ClickTrackerInst;
};
Q_DECLARE_METATYPE(Core *)
Q_DECLARE_METATYPE(Core)
