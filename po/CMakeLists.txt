find_program(XGETTEXT_EXECUTABLE xgettext REQUIRED)
find_program(MSGMERGE_EXECUTABLE msgmerge REQUIRED)
find_program(MSGFMT_EXECUTABLE msgfmt REQUIRED)

set(LANGUAGES ru)
set(POT_FILE ${CMAKE_CURRENT_SOURCE_DIR}/sanar-filer.pot)

file(GLOB_RECURSE QML_SOURCES RELATIVE ${PROJECT_SOURCE_DIR} CONFIGURE_DEPENDS ${PROJECT_SOURCE_DIR}/src/qml/*.qml)
file(GLOB_RECURSE CPP_SOURCES RELATIVE ${PROJECT_SOURCE_DIR} CONFIGURE_DEPENDS ${PROJECT_SOURCE_DIR}/src/*.cpp)

add_custom_target(update-po
    COMMAND ${XGETTEXT_EXECUTABLE} --language=JavaScript --from-code=UTF-8
            --keyword=t:1 --keyword=n:1,2
            --package-name=sanar-filer --package-version=${PROJECT_VERSION}
            --add-comments --sort-by-file
            -o ${POT_FILE} ${QML_SOURCES}
    COMMAND ${XGETTEXT_EXECUTABLE} --language=C++ --from-code=UTF-8
            --keyword=dgettext:2 --keyword=dngettext:2,3 --add-comments --sort-by-file --join-existing
            -o ${POT_FILE} ${CPP_SOURCES}
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    VERBATIM
)

set(MO_FILES)
foreach(lang ${LANGUAGES})
    set(po ${CMAKE_CURRENT_SOURCE_DIR}/${lang}.po)
    set(mo ${PROJECT_BINARY_DIR}/locale/${lang}/LC_MESSAGES/sanar-filer.mo)
    add_custom_command(OUTPUT ${mo}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_BINARY_DIR}/locale/${lang}/LC_MESSAGES
        COMMAND ${MSGFMT_EXECUTABLE} --check -o ${mo} ${po}
        DEPENDS ${po}
        VERBATIM
    )
    add_custom_command(TARGET update-po POST_BUILD
        COMMAND ${MSGMERGE_EXECUTABLE} --update --backup=none ${po} ${POT_FILE}
        VERBATIM
    )
    list(APPEND MO_FILES ${mo})
endforeach()

add_custom_target(translations ALL DEPENDS ${MO_FILES})

install(DIRECTORY ${PROJECT_BINARY_DIR}/locale/ DESTINATION ${CMAKE_INSTALL_LOCALEDIR})
