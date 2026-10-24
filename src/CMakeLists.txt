qt_add_executable(sanar-filer main.cpp thumbs/ThumbnailProvider.h thumbs/ThumbnailProvider.cpp)

target_compile_definitions(sanar-filer PRIVATE
    PROJECT_VERSION="${PROJECT_VERSION}"
    LOCALEDIR="${SANAR_FILER_LOCALEDIR}"
)

qt_add_qml_module(sanar-filer
    URI Sanar.Filer
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/ThemeModeSelector.qml
        qml/SettingsSwitch.qml
        qml/SettingsDialog.qml
        qml/AccentPicker.qml
        qml/AboutPage.qml
        qml/Breadcrumbs.qml
        qml/Icon.qml
        qml/IconButton.qml
        qml/DetailsPanel.qml
        qml/DeviceCard.qml
        qml/DirectoryHeader.qml
        qml/DirectoryPage.qml
        qml/DirectoryView.qml
        qml/EntryInput.qml
        qml/EntryThumb.qml
        qml/FileRow.qml
        qml/FileTile.qml
        qml/FilterChip.qml
        qml/FilterChips.qml
        qml/FolderTile.qml
        qml/SelectionBar.qml
        qml/SortMenu.qml
        qml/ViewSwitcher.qml
        qml/NavItem.qml
        qml/NavigationButtons.qml
        qml/ResizeHandles.qml
        qml/SearchField.qml
        qml/SectionTitle.qml
        qml/Sidebar.qml
        qml/TopBar.qml
        qml/WaveProgress.qml
        qml/WindowControls.qml
    SOURCES
        settings/Settings.h
        settings/Settings.cpp
        places/DevicesModel.h
        places/DevicesModel.cpp
        places/PlacesModel.h
        places/PlacesModel.cpp
        nav/Navigator.h
        nav/Navigator.cpp
        fs/DirectoryModel.h
        fs/DirectoryModel.cpp
        fs/EntrySectionModel.h
        fs/EntrySectionModel.cpp
        fs/FileDetails.h
        fs/FileDetails.cpp
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

target_include_directories(sanar-filer PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/theme ${CMAKE_CURRENT_SOURCE_DIR}/i18n ${CMAKE_CURRENT_SOURCE_DIR}/fs ${CMAKE_CURRENT_SOURCE_DIR}/nav ${CMAKE_CURRENT_SOURCE_DIR}/settings ${CMAKE_CURRENT_SOURCE_DIR}/places ${CMAKE_CURRENT_SOURCE_DIR}/thumbs)

target_link_libraries(sanar-filer PRIVATE Qt6::Core Qt6::Gui Qt6::Quick)

install(TARGETS sanar-filer RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
