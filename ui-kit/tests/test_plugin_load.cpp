#include <dlfcn.h>
#include <QtTest/QTest>
#include <string>

struct PluginEntry {
  const char *relativePath;
  const char *displayName;
};

static const PluginEntry kPlugins[] = {
    {"Sber/Core/libSberCorePlugin.so", "Sber.Core"},
    {"Sber/Theme/libSberThemePlugin.so", "Sber.Theme"},
    {"Sber/Controls/libSberControlsPlugin.so", "Sber.Controls"},
    {"Sber/Widgets/libSberWidgetsPlugin.so", "Sber.Widgets"},
    {"Sber/Utils/libSberUtilsPlugin.so", "Sber.Utils"},
};

class PluginLoadTest : public QObject {
  Q_OBJECT

 private slots:
  void loadsAllPluginsSuccessfully() {
    for (const auto &entry : kPlugins) {
      const std::string fullPath = std::string(TEST_PLUGIN_DIR) + "/" + entry.relativePath;

      // Clear any previous dlerror, then attempt load
      dlerror();
      void *handle = dlopen(fullPath.c_str(), RTLD_NOW | RTLD_LOCAL);
      const char *loadErr = dlerror();

      if (!handle) {
        const std::string message = std::string("Failed to load ") + entry.displayName +
            " (" + fullPath + "): " + (loadErr ? loadErr : "unknown error");
        QTest::qFail(message.c_str(), __FILE__, __LINE__);
      } else {
        dlclose(handle);
      }
    }
  }
};

QTEST_GUILESS_MAIN(PluginLoadTest)
#include "test_plugin_load.moc"
