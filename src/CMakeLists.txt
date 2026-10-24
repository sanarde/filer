qt_add_executable(sanar-filer main.cpp)

target_compile_definitions(sanar-filer PRIVATE
    PROJECT_VERSION="${PROJECT_VERSION}"
    LOCALEDIR="${SANAR_FILER_LOCALEDIR}"
)

qt_add_qml_module(sanar-filer
    URI Sanar.Filer
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/Icon.qml
        qml/IconButton.qml
        qml/NavigationButtons.qml
        qml/ResizeHandles.qml
        qml/SearchField.qml
        qml/TopBar.qml
        qml/WindowControls.qml
    SOURCES
        fs/DirectoryModel.h
        fs/DirectoryModel.cpp
        fs/FileKind.h
        fs/FileKind.cpp
        fs/SizeFormat.h
        fs/SizeFormat.cpp
        i18n/Translator.h
        i18n/Translator.cpp
        theme/ColorSet.h
        theme/ColorSets.cpp
        theme/Theme.h
        theme/Theme.cpp
        theme/Icons.h
        theme/Icons.cpp
)

qt_add_resources(sanar-filer resources
    PREFIX /
    BASE ${PROJECT_SOURCE_DIR}/resources
    FILES
        ${PROJECT_SOURCE_DIR}/resources/icons.txt
        ${PROJECT_SOURCE_DIR}/resources/fonts/RobotoFlex.ttf
        ${PROJECT_SOURCE_DIR}/resources/fonts/MaterialSymbolsRounded.ttf
)

target_include_directories(sanar-filer PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/theme ${CMAKE_CURRENT_SOURCE_DIR}/i18n ${CMAKE_CURRENT_SOURCE_DIR}/fs)

target_link_libraries(sanar-filer PRIVATE Qt6::Core Qt6::Gui Qt6::Quick)

install(TARGETS sanar-filer RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
