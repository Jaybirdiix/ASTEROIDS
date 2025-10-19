module scenes.game_over_simple;

import bindbc.sdl;
import gameapplication : GameApplication, SceneID;
import scenes.flags;

void sceneGameOverEnter(GameApplication* app, SDL_Renderer* r) { gGameOverBackToMenu = false; }
void sceneGameOverExit(GameApplication* app) {}

void sceneGameOverEvent(GameApplication* app, in SDL_Event* ev) {
    if (ev.type == SDL_EVENT_KEY_DOWN && ev.key.scancode == SDL_SCANCODE_SPACE) {
        gGameOverBackToMenu = true;
    }
}
void sceneGameOverUpdate(GameApplication* app, float dt) {}
void sceneGameOverRender(GameApplication* app, SDL_Renderer* r) {}

bool sceneGameOverFinished(GameApplication* app) { return gGameOverBackToMenu; }
SceneID sceneGameOverNext(GameApplication* app)  { return SceneID.MainMenu; }
