cmake_minimum_required(VERSION 3.21)
project(sanar-filer VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Quick DBus)
qt_standard_project_setup(REQUIRES 6.8)

include(GNUInstallDirs)
set(SANAR_FILER_LOCALEDIR "${CMAKE_INSTALL_FULL_LOCALEDIR}" CACHE PATH "Directory searched for message catalogs")

add_subdirectory(src)
add_subdirectory(po)
