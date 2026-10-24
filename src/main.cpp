#include <QFont>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("sanar-filer");
    app.setApplicationVersion(PROJECT_VERSION);
    app.setDesktopFileName("org.nuros.sanar.filer");

    QFontDatabase::addApplicationFont(":/fonts/MaterialSymbolsRounded.ttf");
    const int textFont = QFontDatabase::addApplicationFont(":/fonts/RobotoFlex.ttf");
    app.setFont(QFont(QFontDatabase::applicationFontFamilies(textFont).value(0)));

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.loadFromModule("Sanar.Filer", "Main");

    return app.exec();
}
