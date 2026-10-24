#include <QFont>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <libintl.h>

#include "ThumbnailProvider.h"

#include <clocale>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("sanar-filer");
    app.setApplicationVersion(PROJECT_VERSION);
    app.setDesktopFileName("org.nuros.sanar.filer");

    setlocale(LC_MESSAGES, "");
    bindtextdomain("sanar-filer", LOCALEDIR);
    bind_textdomain_codeset("sanar-filer", "UTF-8");

    QFontDatabase::addApplicationFont(":/fonts/MaterialSymbolsRounded.ttf");
    const int textFont = QFontDatabase::addApplicationFont(":/fonts/RobotoFlex.ttf");
    app.setFont(QFont(QFontDatabase::applicationFontFamilies(textFont).value(0)));

    QQmlApplicationEngine engine;
    engine.addImageProvider("thumb", new ThumbnailProvider);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.loadFromModule("Sanar.Filer", "Main");

    return app.exec();
}
