// android
#include <android/input.h>
#include <android/log.h>
#include <android_native_app_glue.h>
#include <jni.h>

// stl
#include <stdint.h>
#include <stdbool.h>

#define APP_API "TOTALJUSTICE"
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, APP_API, __VA_ARGS__))
#define LOGW(...) ((void)__android_log_print(ANDROID_LOG_WARN, APP_API, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, APP_API, __VA_ARGS__))

static void android_handle_cmd(struct android_app* app, int32_t cmd)
{
}

static int32_t android_handle_input(struct android_app* app, AInputEvent* event)
{
    return 0;
}

static void Init(struct android_app* app)
{
    LOGI("internalDataPath: %s\n", app->activity->internalDataPath);
    LOGI("externalDataPath: %s\n", app->activity->externalDataPath);
    LOGI("sdkVersion: %d\n", app->activity->sdkVersion);

    app->userData = NULL;
    app->onAppCmd = android_handle_cmd;
    app->onInputEvent = android_handle_input;
}

static void Loop(struct android_app* app)
{
    while (1)
    {
        int ident;
        int events;
        struct android_poll_source* source;

        while ((ident = ALooper_pollAll(0, NULL, &events, (void**)&source)) >= 0)
        {
            // process event
            if (source)
            {
                source->process(app, source);
            }

            // Check if we are exiting.
            if (app->destroyRequested != 0)
            {
                return;
            }
        }

        // draw stuff here
    }
}

static void Quit(struct android_app* app)
{

}

void JNIEXPORT android_main(struct android_app* app)
{
    // do NOT remove this, it is needed on older ndk versions as the main
    // entry point will be stripped away otherwise!
    app_dummy();

    LOGI("hello world\n");
    Init(app);
    Loop(app);
    Quit(app);
    LOGI("leaving main...\n");
}
