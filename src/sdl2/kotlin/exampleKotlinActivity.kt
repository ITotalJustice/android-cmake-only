package org.libsdl.app;

import org.libsdl.app.SDLActivity;

class exampleKotlinActivity : SDLActivity() {
    // add shared libs here
    override fun getLibraries(): Array<String> {
        return arrayOf(
            "SDL2",
            "SDL2_image",
            "example"
        )
    }
}
