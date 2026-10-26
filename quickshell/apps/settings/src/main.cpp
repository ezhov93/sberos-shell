#include "PowerSettings.h"
#include "CacheMaintenance.h"
#include "SettingsBridge.h"
#include "SettingsRuntime.h"
#include "WindowSettings.h"

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>

int main(int argc, char* argv[])
{
    for (int i = 1; i < argc; ++i) {
        const QByteArray argument(argv[i]);
        if (argument == "--install-window-defaults" || argument == "--restore-window-defaults") {
            QCoreApplication application(argc, argv);
            WindowSettings settings;
            const bool accepted = argument == "--install-window-defaults"
                ? settings.installDefaults()
                : settings.setTakeover(false);
            if (!accepted)
                qWarning().noquote() << settings.error();
            return accepted ? 0 : 1;
        }
    }
    QGuiApplication application(argc, argv);
    // Keep this window out of the Shell's KWin rules. This must match the
    // installed desktop entry basename: kos-settings.desktop.
    application.setApplicationName(QStringLiteral("kos-settings"));
    application.setApplicationDisplayName(QStringLiteral(""));
    application.setDesktopFileName(QStringLiteral("kos-settings"));
    application.setOrganizationName(QStringLiteral("Quickshell"));

    SettingsBridge bridge;
    WindowSettings windowSettings;
    PowerSettings powerSettings;
    QQmlApplicationEngine engine;
    // The standalone Settings process does not inherit the import paths of the
    // Quickshell process that opened it. KOS_PREFIX installs QML modules beside
    // the executable under lib/qt6/qml; add that path explicitly for desktop
    // entry launches as well as shell-launched sessions.
    engine.addImportPath(QDir::cleanPath(
        QCoreApplication::applicationDirPath() + QStringLiteral("/../lib/qt6/qml")));
    const QString installedRuntime = QDir::cleanPath(
        QCoreApplication::applicationDirPath() + QStringLiteral("/../share/kos"));
    const QString installedModules = QDir(installedRuntime).filePath(QStringLiteral("qml"));
    if (QDir(installedModules).exists())
        engine.addImportPath(installedModules);
    const QString installedResources = QDir(installedRuntime).filePath(
        QStringLiteral("SberComponents"));
    if (QDir(installedResources).exists()
        && !qEnvironmentVariableIsSet("SBER_COMPONENTS_DATA_DIR")) {
        qputenv("SBER_COMPONENTS_DATA_DIR", QFile::encodeName(installedResources));
    }
    engine.rootContext()->setContextProperty(QStringLiteral("settingsBridge"), &bridge);
    engine.rootContext()->setContextProperty(QStringLiteral("windowSettings"), &windowSettings);
    engine.rootContext()->setContextProperty(QStringLiteral("powerSettings"), &powerSettings);

    const SettingsEntry entry
        = chooseSettingsEntry(bridge.isDevelopmentSession(), bridge.sessionShellDir());
    // Recorded before the engine loads anything, so the banner and the reloader
    // cannot disagree about which tree the window is running.
    bridge.setSourceTreeEntry(!entry.checkoutRoot.isEmpty());
    if (entry.qmlPath.isEmpty()) {
        qWarning() << "kos-settings: no QML entry point found; looked beside the binary"
                      " and in"
                   << QStringLiteral(SETTINGS_QML_DIR);
        return 1;
    }
    qInfo().noquote() << "kos-settings: loading QML from" << entry.qmlPath
                      << QStringLiteral("(%1%2)").arg(entry.source,
                             entry.checkoutRoot.isEmpty() ? QString()
                                                          : QStringLiteral(", reloads on change"));
    const QUrl entrypoint = QUrl::fromLocalFile(entry.qmlPath);
    engine.load(entrypoint);
    if (engine.rootObjects().isEmpty())
        return 1;
    // Generic page selector for probes and manual debugging: --page=N opens
    // contentByPage index N directly (integration status is 6). --page=windows
    // keeps its named form for the existing window-install test.
    for (const QString& argument : application.arguments()) {
        if (argument == QStringLiteral("--page=windows")) {
            engine.rootObjects().constFirst()->setProperty("currentPage", 10);
        } else if (argument.startsWith(QStringLiteral("--page="))) {
            bool ok = false;
            const int page = argument.mid(7).toInt(&ok);
            if (ok)
                engine.rootObjects().constFirst()->setProperty("currentPage", page);
        }
    }
    if (application.arguments().contains(QStringLiteral("--smoke-test-windows"))) {
        engine.rootObjects().constFirst()->setProperty("currentPage", 10);
        QTimer::singleShot(1000, &application, [&engine, &application]() {
            auto* loader = engine.rootObjects().constFirst()->findChild<QObject*>(
                QStringLiteral("windowPageLoader"));
            if (!loader || loader->property("status").toInt() != 1
                || !engine.rootObjects().constFirst()->findChild<QObject*>(
                    QStringLiteral("windowAppearancePage"))) {
                qWarning() << "Window settings page did not instantiate";
                application.exit(1);
                return;
            }
            application.quit();
        });
    }

    // Inert unless the QML came from a checkout, which is the only case where
    // there is something to watch.
    SettingsQmlReloader reloader(&engine, entrypoint, entry.checkoutRoot);
    reloader.start();

    // 缓存维护:启动时调度一次(线程池内执行,阈值内零开销)。以后新增缓存
    // 目录都从这里追加 schedule 调用。
    CacheMaintenance::schedule(WallpaperLibrary::thumbnailCacheDirectory(), 64 * 1024 * 1024, 500);

    // --smoke-test is the build-side check that the settings window loads:
    // run one event loop turn (as ApplicationRunner does for the apps) and
    // exit, so CI can prove main.qml instantiates without a display.
    if (application.arguments().contains(QStringLiteral("--smoke-test")))
        QTimer::singleShot(250, &application, &QCoreApplication::quit);
    return application.exec();
}
