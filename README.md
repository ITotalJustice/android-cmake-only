# android-cmake-only

this repo contains a few examples of using only cmake to build your android app.

you can build your app with or without java/kotlin code, there are examples for all.

## examples

currently the examples are:

- no_java: build a pure native app with no java.
- java: build a native app with java code.
- sdl2: build a native app with both java and kotlin code.

## limitations

- no androidx (unsure how to "link" against it).
- compiles the java/kotlin files on each run, no caching (yet).
- android studio gets very confused.

## building

you will need sdkmanager to download the required files:

- `sdkmanager --install "ndk;26.2.11394342"`
- `sdkmanager --install "platforms;android-34"`
- `sdkmanager --install "build-tools;34.0.0"`

adb uninstall org.libsdl.app; adb install -r -g -d build/android-arm64-v8a/src/sdl2/example.apk;

you will also need a keystore file. If you don't have one, you can create one using `keytool -genkey -v -keystore debug.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias androiddebugkey -storepass android -keypass android -dname "CN=example.com, OU=ID, O=Example, L=Doe, S=John, C=GB"`.

__NOTE:__ the versions above are listed for convinience, you can use any version ndk,platform,build-tools you like. Use `sdkmanager --list` to get the full list, and `sdkmanager --list | grep ndk` to limit the list.

run `cmake --list-presets` to get a list of presets available. After chosing a preset, run `cmake --preset SELECTED_PRESET -DKEYSTORE=debug.keystore -DKEYPASS=android -DSTOREPASS=android -DALIASNAME=androiddebugkey` and then `cmake --build --preset SELECTED_PRESET`.

## credit

- [rawdrawandroid](https://github.com/cnlohr/rawdrawandroid). the repo that started it all :)
