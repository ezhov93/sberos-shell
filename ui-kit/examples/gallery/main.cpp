#include <QApplication>
#include <QCommandLineParser>
#include <QDir>
#include <QFileInfo>
#include <QImage>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTimer>

int main(int argc, char* argv[]) {
    QApplication app(argc, argv);
    app.setApplicationName("sber-components-gallery");
    QCommandLineParser parser;
    parser.setApplicationDescription("Sber QML components gallery");
    parser.addHelpOption();
    parser.addOption({"dark", "Start with the dark theme."});
    parser.addOption({"screenshot", "Save a PNG and exit (also works with QT_QPA_PLATFORM=offscreen).", "path"});
    parser.process(app);

    for (const auto& file : {"sdds_os.json", "sizes_os.json", "font_styles.json"}) {
        const QString path = QDir(QStringLiteral(SBER_THEME_RESOURCES_PATH)).filePath("theme/" + QString::fromLatin1(file));
        if (!QFileInfo::exists(path)) {
            qCritical().noquote() << "Missing theme resource:" << path
                << "\nSee examples/gallery/README.md for local resource setup.";
            return 1;
        }
    }

    QQmlApplicationEngine engine;
    engine.addImportPath(QStringLiteral(SBER_QML_IMPORT_PATH));
    engine.setInitialProperties({{"darkTheme", parser.isSet("dark")}});
    engine.load(QUrl(QStringLiteral("qrc:/gallery/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return 1;

    if (parser.isSet("screenshot")) {
        auto* window = qobject_cast<QQuickWindow*>(engine.rootObjects().first());
        if (!window)
            return 1;
        const auto path = parser.value("screenshot");
        QTimer::singleShot(1000, window, [window, path, &app]() {
            app.exit(window->grabWindow().save(path) ? 0 : 1);
        });
    }
    return app.exec();
}
