cmake_minimum_required(VERSION 3.13)
project(SDL2Android LANGUAGES C CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if (NOT DEFINED KEYSTORE)
    message(FATAL_ERROR "KEYSTORE path not set")
endif()

if (NOT DEFINED KEYPASS)
    message(FATAL_ERROR "KEYPASS variable not set")
endif()

if (NOT DEFINED STOREPASS)
    message(FATAL_ERROR "STOREPASS variable not set")
endif()

if (NOT DEFINED ALIASNAME)
    message(FATAL_ERROR "ALIASNAME variable not set")
endif()

# store absolute path to keystore file
cmake_path(ABSOLUTE_PATH KEYSTORE NORMALIZE OUTPUT_VARIABLE KEYSTORE)

if (NO_JAVA)
    add_subdirectory(src/no_java)
endif()

if (JAVA)
    add_subdirectory(src/java)
endif()

if (SDL2)
    add_subdirectory(src/sdl2)
endif()
