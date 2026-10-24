qt_add_executable(sanar-filer main.cpp)

target_compile_definitions(sanar-filer PRIVATE PROJECT_VERSION="${PROJECT_VERSION}")

qt_add_qml_module(sanar-filer
    URI Sanar.Filer
    VERSION 1.0
    QML_FILES
        qml/Main.qml
)

target_link_libraries(sanar-filer PRIVATE Qt6::Core Qt6::Gui Qt6::Quick)

install(TARGETS sanar-filer RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
