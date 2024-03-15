# this is a wrapper around ndk.cmake
# internally it includes the ndk toolchain file
# but does some setup for finding ndk and required
# tools needed for building an apk

# NOTE: this is not generic and should be tweeked to suit
# the project you're making.
# this file mainly exists because ndk is lacking in support
# for building C/C++ only android apps.

# api versions: https://apilevels.com/
# old versions from here: https://github.com/android/ndk/wiki/Unsupported-Downloads

if (DEFINED ANDROID_SDK_HOME AND EXISTS ${ANDROID_SDK_HOME})
    # already defined
elseif (DEFINED ENV{ANDROID_HOME} AND EXISTS $ENV{ANDROID_HOME})
    set(ANDROID_SDK_HOME $ENV{ANDROID_HOME})
elseif (DEFINED ENV{ANDROID_SDK_ROOT} AND EXISTS $ENV{ANDROID_SDK_ROOT})
    set(ANDROID_SDK_HOME $ENV{ANDROID_SDK_ROOT})
elseif (EXISTS $ENV{HOME}/Android/Sdk)
    set(ANDROID_SDK_HOME $ENV{HOME}/Android/Sdk)
elseif (EXISTS $ENV{HOME}/Library/Android/sdk)
    set(ANDROID_SDK_HOME $ENV{HOME}/Library/Android/sdk)
else ()
    message(FATAL_ERROR "unable to find ANDROID_SDK_HOME!")
endif()


if (DEFINED ANDROID_NDK_SDK AND EXISTS ${ANDROID_SDK_HOME}/ndk/${ANDROID_NDK_SDK}/build/cmake/android.toolchain.cmake)
    set(ANDROID_NDK_TOOLCHAIN_FILE ${ANDROID_SDK_HOME}/ndk/${ANDROID_NDK_SDK}/build/cmake/android.toolchain.cmake)
    message(STATUS "ANDROID_NDK_TOOLCHAIN_FILE: ${ANDROID_NDK_TOOLCHAIN_FILE}")
    include(${ANDROID_NDK_TOOLCHAIN_FILE})
endif()

message(STATUS "ANDROID_NDK_SDK: ${ANDROID_NDK_SDK}")
message(STATUS "ANDROID_COMPILE_SDK: ${ANDROID_COMPILE_SDK}")
message(STATUS "ANDROID_NATIVE_API_LEVEL: ${ANDROID_NATIVE_API_LEVEL}")
message(STATUS "ANDROID_TARGET_SDK: ${ANDROID_TARGET_SDK}")
message(STATUS "ANDROID_PLATFORM_LEVEL: ${ANDROID_PLATFORM_LEVEL}")
message(STATUS "ANDROID_TOOLCHAIN: ${ANDROID_TOOLCHAIN}")
message(STATUS "ANDROID_API: ${ANDROID_API}")
message(STATUS "ANDROID_ABI: ${ANDROID_ABI}")
message(STATUS "ANDROID_API_MIN: ${ANDROID_API_MIN}")
message(STATUS "ANDROID_PLATFORM: ${ANDROID_PLATFORM}")
message(STATUS "ANDROID_STL: ${ANDROID_STL}")
message(STATUS "ANDROID_PIE: ${ANDROID_PIE}")
message(STATUS "ANDROID_CPP_FEATURES: ${ANDROID_CPP_FEATURES}")
message(STATUS "ANDROID_ALLOW_UNDEFINED_SYMBOLS: ${ANDROID_ALLOW_UNDEFINED_SYMBOLS}")
message(STATUS "ANDROID_ARM_MODE: ${ANDROID_ARM_MODE}")
message(STATUS "ANDROID_ARM_NEON: ${ANDROID_ARM_NEON}")
message(STATUS "ANDROID_DISABLE_NO_EXECUTE: ${ANDROID_DISABLE_NO_EXECUTE}")
message(STATUS "ANDROID_DISABLE_RELRO: ${ANDROID_DISABLE_RELRO}")
message(STATUS "ANDROID_DISABLE_FORMAT_STRING_CHECKS: ${ANDROID_DISABLE_FORMAT_STRING_CHECKS}")
message(STATUS "ANDROID_CCACHE: ${ANDROID_CCACHE}")

# i am not sure which path this will find if multiple build-tools are installed
find_program(AAPT NAMES aapt HINTS ${ANDROID_SDK_HOME}/build-tools/*/ REQUIRED)
find_program(ZIPALIGN NAMES zipalign HINTS ${ANDROID_SDK_HOME}/build-tools/*/ REQUIRED)
find_program(APKSIGNER NAMES apksigner HINTS ${ANDROID_SDK_HOME}/build-tools/*/ REQUIRED)
# d8 may not be found in old build-tools, todo: fallback to dx instead
find_program(D8 NAMES d8 HINTS ${ANDROID_SDK_HOME}/build-tools/*/ REQUIRED)

# if jarsigner is not installed, sudo dnf install java-latest-openjdk-devel
find_program(JARSIGNER NAMES jarsigner REQUIRED)
find_program(KEYTOOL NAMES keytool REQUIRED)
find_program(JAVAC NAMES javac REQUIRED)
find_program(KOTLINC NAMES kotlinc REQUIRED)

find_program(ZIP NAMES zip REQUIRED)
find_program(UNZIP NAMES unzip REQUIRED)

message(STATUS "found ANDROID_SDK_HOME at ${ANDROID_SDK_HOME}")
message(STATUS "AAPT found in: ${AAPT}")
message(STATUS "ZIPALIGN found in: ${ZIPALIGN}")
message(STATUS "APKSIGNER found in: ${APKSIGNER}")
message(STATUS "D8 found in: ${D8}")
message(STATUS "JARSIGNER found in: ${JARSIGNER}")
message(STATUS "KEYTOOL found in: ${KEYTOOL}")
message(STATUS "JAVAC found in: ${JAVAC}")
message(STATUS "ZIP found in: ${ZIP}")
message(STATUS "UNZIP found in: ${UNZIP}")

# this produces a far smaller binary (almost half size)
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O2 -flto -fvisibility=hidden")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O2 -flto -fvisibility=hidden -fvisibility-inlines-hidden -fno-exceptions -fno-rtti")
# this is needed in older ndk versions
set(CMAKE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS} -u ANativeActivity_onCreate")

function(android_create_apk target)
    cmake_parse_arguments(APK
        ""
        "NAME;ASSETS;RESOURCES;MANIFEST"
        "SHARED_LIBS;JAVA_CLASSPATH;JAVA_FILES;KOTLIN_CLASSPATH;KOTLIN_FILES"
        ${ARGN}
    )

    set(ANDROID_JAR_PATH ${ANDROID_SDK_HOME}/platforms/android-${ANDROID_COMPILE_SDK}/android.jar)
    set(APK_JAVA_CLASSPATH ${ANDROID_JAR_PATH} ${APK_JAVA_CLASSPATH})
    set(APK_KOTLIN_CLASSPATH ${ANDROID_JAR_PATH} ${APK_KOTLIN_CLASSPATH})

    # add main target to list of shared libs
    list(APPEND APK_SHARED_LIBS ${CMAKE_CURRENT_BINARY_DIR}/lib${target}.so)

    # copy over manifest, filling in min/target sdk
    configure_file(${APK_MANIFEST} ${CMAKE_CURRENT_BINARY_DIR}/AndroidManifest.xml)

    if (NOT DEFINED APK_NAME)
        set(APK_NAME ${target})
    endif()

    if (DEFINED APK_JAVA_FILES)
        set(JAVAC_COMMAND ${JAVAC} -source 1.8 -target 1.8 -d bin -classpath ${ANDROID_JAR_PATH} -sourcepath java ${APK_JAVA_FILES})
    endif()

    if (DEFINED APK_KOTLIN_FILES)
        set(KOTLINC_COMMAND ${KOTLINC} -no-jdk -classpath ${APK_KOTLIN_CLASSPATH} -d bin ${APK_KOTLIN_FILES})
    endif()

    if (DEFINED APK_JAVA_FILES OR DEFINED APK_KOTLIN_FILES)
        set(D8_COMMAND ${D8} --release --output makecapk --lib ${ANDROID_JAR_PATH} bin/*/*/*/*.class)
    endif()

    set(DEPENDS ${target} ${APK_SHARED_LIBS})

    add_custom_command(OUTPUT ${APK_NAME}.apk
        COMMAND ${CMAKE_COMMAND} -E rm -rf makecapk
        COMMAND ${CMAKE_COMMAND} -E make_directory makecapk/lib/${ANDROID_ABI}
        COMMAND ${CMAKE_COMMAND} -E copy ${APK_SHARED_LIBS} makecapk/lib/${ANDROID_ABI}

        # compile java / kotlin
        COMMAND ${CMAKE_COMMAND} -E rm -rf bin
        COMMAND ${JAVAC_COMMAND}
        COMMAND ${KOTLINC_COMMAND}
        COMMAND ${D8_COMMAND}

        COMMAND ${CMAKE_COMMAND} -E make_directory makecapk/assets
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${APK_ASSETS} makecapk/assets/
        COMMAND ${CMAKE_COMMAND} -E rm -rf temp.apk
        COMMAND ${AAPT} package -f -F temp.apk -I ${ANDROID_JAR_PATH} -M AndroidManifest.xml -S ${APK_RESOURCES} -A makecapk/assets -v --target-sdk-version ${ANDROID_COMPILE_SDK}
        COMMAND ${UNZIP} -o temp.apk -d makecapk
        COMMAND ${CMAKE_COMMAND} -E rm -rf makecapk.apk
        COMMAND ${CMAKE_COMMAND} -E chdir makecapk ${ZIP} -D9r ../makecapk.apk .
        COMMAND ${CMAKE_COMMAND} -E chdir makecapk ${ZIP} -D0r ../makecapk.apk ./resources.arsc ./AndroidManifest.xml

        # align and sign apk
        COMMAND ${CMAKE_COMMAND} -E rm -rf ${APK_NAME}.apk
        COMMAND ${ZIPALIGN} -v 4 makecapk.apk ${APK_NAME}.apk
        COMMAND ${APKSIGNER} sign --ks-key-alias ${ALIASNAME} --key-pass pass:${KEYPASS} --ks-pass pass:${STOREPASS} --ks ${KEYSTORE} ${APK_NAME}.apk

        # remove left over files
        COMMAND ${CMAKE_COMMAND} -E rm -rf makecapk
        COMMAND ${CMAKE_COMMAND} -E rm -rf temp.apk
        COMMAND ${CMAKE_COMMAND} -E rm -rf makecapk.apk
        DEPENDS ${DEPENDS}
    )

    add_custom_target(${APK_NAME}_apk ALL DEPENDS ${APK_NAME}.apk)
endfunction()
