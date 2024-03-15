package org.yourorg.example;

import android.app.NativeActivity;

public class exampleJavaActivity extends android.app.NativeActivity {
    static {
        System.loadLibrary("example");
    }
}
