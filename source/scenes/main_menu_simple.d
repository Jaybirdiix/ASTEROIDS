module scenes.main_menu_simple;

import bindbc.sdl;
import std.string : toStringz;
import gameapplication : GameApplication, SceneID;
import scenes.flags;

void sceneMainMenuEnter(GameApplication* app, SDL_Renderer* r) { gMenuStart = false; }
void sceneMainMenuExit(GameApplication* app) {}

void sceneMainMenuEvent(GameApplication* app, in SDL_Event* ev) {
    if (ev.type == SDL_EVENT_KEY_DOWN && ev.key.scancode == SDL_SCANCODE_SPACE) {
        gMenuStart = true;
    }
}
void sceneMainMenuUpdate(GameApplication* app, float dt) {}

void sceneMainMenuRender(GameApplication* app, SDL_Renderer* r) {
    SDL_FRect dst = SDL_FRect(0, 0, app.windowWidth, app.windowHeight);
    if (app.background_texture !is null) SDL_RenderTexture(r, app.background_texture, null, &dst);

    // text
    SDL_SetRenderScale(r, 4.0f, 4.0f);
    SDL_RenderDebugText(r, 40.0f, 40.0f, "ASTEROIDS".toStringz);
    SDL_SetRenderScale(r, 1.0f, 1.0f);
    SDL_SetRenderScale(r, 2.0f, 2.0f);
    SDL_RenderDebugText(r, 40.0f, 120.0f, "Arrows: move   A/D: rotate   SPACE: shoot".toStringz);
    SDL_SetRenderScale(r, 1.0f, 1.0f);

    // blink
    ulong t = SDL_GetTicks();
    if (((t / 500) % 2) == 0) {
        SDL_SetRenderScale(r, 3.0f, 3.0f);
        SDL_RenderDebugText(r, 40.0f, 200.0f, "Press SPACE to start".toStringz);
        SDL_SetRenderScale(r, 1.0f, 1.0f);
    }
}

bool sceneMainMenuFinished(GameApplication* app) { return gMenuStart; }
SceneID sceneMainMenuNext(GameApplication* app)  { return SceneID.Level1; }
