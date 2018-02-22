CMAKE_MINIMUM_REQUIRED(VERSION 3.8)
PROJECT(graphics-lab-1)

INCLUDE(ginseng/ginseng.cmake)

SET(SOURCES
    AppDelegate.h
    AppDelegate.mm

    LabeledPoint.hpp
    LabeledPoint.cpp

    math.hpp
    math.cpp

    main.mm

    MainMenu.xib
)

GINSENG_APPLICATION(${CMAKE_PROJECT_NAME} SOURCES)

SET_SOURCE_FILES_PROPERTIES(
    MainMenu.xib
    PROPERTIES
    MACOSX_PACKAGE_LOCATION
    Resources
)

set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY CXX_STANDARD 17)
