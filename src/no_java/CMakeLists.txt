cmake_minimum_required(VERSION 3.21)

project(example
    LANGUAGES C
    VERSION 0.0.1
)

add_library(${PROJECT_NAME} SHARED
    main.cpp
)

# add common android libraries
find_library(android-lib android REQUIRED)
find_library(log-lib log REQUIRED)
find_library(GLESv1_CM-lib GLESv1_CM REQUIRED)
find_library(EGL-lib EGL REQUIRED)

# keytool -genkey -v -keystore debug.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias androiddebugkey -storepass android -keypass android -dname "CN=example.com, OU=ID, O=Example, L=Doe, S=John, C=GB"
# keytool -list -v -keystore "C:\Users\USERNAME\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
target_link_libraries(${PROJECT_NAME} PRIVATE
    ${android-lib}
    ${log-lib}
    ${EGL-lib}
    ${GLESv1_CM-lib}
)

# set your language standards here
set_target_properties(${PROJECT_NAME} PROPERTIES
    C_STANDARD 99
    C_EXTENSIONS ON
    CXX_STANDARD 11
    CXX_EXTENSIONS ON
)

# build android native glue
add_library(android_native STATIC
    ${ANDROID_NDK}/sources/android/native_app_glue/android_native_app_glue.c
)

# on old versions of ndk didn't export the main entry point.
# this fixes the issue by re-defining it.
# this is safe on later versions as well as double export is ignored.
target_compile_options(android_native PRIVATE
    "-DANativeActivity_onCreate=JNIEXPORT ANativeActivity_onCreate"
    "-Dapp_dummy=JNIEXPORT app_dummy"
)

target_include_directories(android_native INTERFACE
    ${ANDROID_NDK}/sources/android/native_app_glue
    ${ANDROID_NDK}/sources/android/ndk_helper
)

target_link_libraries(${PROJECT_NAME} PRIVATE android_native)

android_create_apk(${PROJECT_NAME}
    NAME ${PROJECT_NAME}
    # fullpath to assets folder
    ASSETS ${CMAKE_SOURCE_DIR}/assets
    # fullpath to resourses folder
    RESOURCES ${CMAKE_SOURCE_DIR}/res
    # fullpath to manifest file
    MANIFEST ${CMAKE_CURRENT_SOURCE_DIR}/AndroidManifest.xml
)
