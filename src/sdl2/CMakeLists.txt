cmake_minimum_required(VERSION 3.21)

project(example
    LANGUAGES C
    VERSION 0.0.1
)

add_library(${PROJECT_NAME} SHARED
    main.c
)

# add common android libraries
find_library(android-lib android REQUIRED)
find_library(log-lib log REQUIRED)

target_link_libraries(${PROJECT_NAME} PRIVATE
    ${android-lib}
    ${log-lib}
)

# set your language standards here
set_target_properties(${PROJECT_NAME} PROPERTIES
    C_STANDARD 99
    C_EXTENSIONS ON
    CXX_STANDARD 11
    CXX_EXTENSIONS ON
)

include(FetchContent)
Set(FETCHCONTENT_QUIET FALSE)

# configure to only include what you need to reduce bloat.
set(SDL_DISKAUDIO OFF)
set(SDL_DUMMYAUDIO OFF)
set(SDL_DUMMYVIDEO OFF)

FetchContent_Declare(sdl
    GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
    GIT_TAG        release-2.30.1
    GIT_PROGRESS   TRUE
)
FetchContent_MakeAvailable(sdl)

# configure to only include what you need to reduce bloat.
set(SDL2IMAGE_AVIF OFF)
set(SDL2IMAGE_BMP OFF)
set(SDL2IMAGE_GIF OFF)
set(SDL2IMAGE_JPG OFF)
set(SDL2IMAGE_JXL OFF)
set(SDL2IMAGE_LBM OFF)
set(SDL2IMAGE_PCX OFF)
set(SDL2IMAGE_PNG OFF)
set(SDL2IMAGE_PNM OFF)
set(SDL2IMAGE_QOI OFF)
set(SDL2IMAGE_SVG OFF)
set(SDL2IMAGE_TGA OFF)
set(SDL2IMAGE_TIF OFF)
set(SDL2IMAGE_WEBP OFF)
set(SDL2IMAGE_XCF OFF)
set(SDL2IMAGE_XPM ON)
set(SDL2IMAGE_XV OFF)

FetchContent_Declare(sdl_image
    GIT_REPOSITORY https://github.com/libsdl-org/SDL_image.git
    GIT_TAG        release-2.8.2
    GIT_PROGRESS   TRUE
)
FetchContent_MakeAvailable(sdl_image)

target_link_libraries(${PROJECT_NAME} PRIVATE SDL2::SDL2main SDL2::SDL2 SDL2_image::SDL2_image)

# add all your shared libs here
list(APPEND shared_libs
    ${sdl_BINARY_DIR}/libSDL2.so
    ${sdl_image_BINARY_DIR}/libSDL2_image.so
)

# add all your java files here
list(APPEND java_files
    ${sdl_SOURCE_DIR}/android-project/app/src/main/java/org/libsdl/app/*.java
)

# add your kotlin files here
list(APPEND kotlin_files
    ${CMAKE_CURRENT_SOURCE_DIR}/kotlin/*.kt
)

android_create_apk(${PROJECT_NAME}
    NAME ${PROJECT_NAME}
    # list of shared libs to be included in the apk
    SHARED_LIBS ${shared_libs}
    # list of java files
    JAVA_FILES ${java_files}
    # list of classpaths
    KOTLIN_CLASSPATH ${sdl_SOURCE_DIR}/android-project/app/src/main/java/
    # list of kotlin files
    KOTLIN_FILES ${kotlin_files}
    # fullpath to assets folder
    ASSETS ${CMAKE_SOURCE_DIR}/assets
    # fullpath to resourses folder
    RESOURCES ${sdl_SOURCE_DIR}/android-project/app/src/main/res
    # fullpath to manifest file
    MANIFEST ${CMAKE_CURRENT_SOURCE_DIR}/AndroidManifest.xml
)
