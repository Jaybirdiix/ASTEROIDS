module scenes.scene_manager;

import bindbc.sdl;

import gameapplication : GameApplication, SceneID;

import scenes.main_menu_simple;
import scenes.level1_simple;
import scenes.game_over_simple;

struct SceneManager {
    SceneID current;
    GameApplication* app;

    void init(GameApplication* app, SceneID start, SDL_Renderer* r) {
        this.app = app;
        current = start;
        onEnter(r);
    }

    void onEnter(SDL_Renderer* r) {
        final switch(current) {
            case SceneID.MainMenu: sceneMainMenuEnter(app, r); break;
            case SceneID.Level1: sceneLevel1Enter(app, r); break;
            case SceneID.GameOver: sceneGameOverEnter(app, r); break;
        }
    }
    void onExit() {
        final switch(current) {
            case SceneID.MainMenu: sceneMainMenuExit(app); break;
            case SceneID.Level1: sceneLevel1Exit(app); break;
            case SceneID.GameOver: sceneGameOverExit(app); break;
        }
    }
    void handleEvent(in SDL_Event* ev) {
        final switch(current) {
            case SceneID.MainMenu: sceneMainMenuEvent(app, ev); break;
            case SceneID.Level1: sceneLevel1Event(app, ev); break;
            case SceneID.GameOver: sceneGameOverEvent(app, ev); break;
        }
    }
    void update(float dt, SDL_Renderer* r) {
        final switch(current) {
            case SceneID.MainMenu: sceneMainMenuUpdate(app, dt); break;
            case SceneID.Level1: sceneLevel1Update(app, dt); break;
            case SceneID.GameOver: sceneGameOverUpdate(app, dt); break;
        }
        if (isFinished()) {
            onExit();
            current = nextScene();
            onEnter(r);
        }
    }
    void render(SDL_Renderer* r) {
        final switch(current) {
            case SceneID.MainMenu: sceneMainMenuRender(app, r); break;
            case SceneID.Level1: sceneLevel1Render(app, r); break;
            case SceneID.GameOver: sceneGameOverRender(app, r); break;
        }
    }
    bool isFinished() {
        final switch(current) {
            case SceneID.MainMenu: return sceneMainMenuFinished(app);
            case SceneID.Level1: return sceneLevel1Finished(app);
            case SceneID.GameOver: return sceneGameOverFinished(app);
        }
        assert(0);
    }
    SceneID nextScene() {
        final switch(current) {
            case SceneID.MainMenu: return sceneMainMenuNext(app);
            case SceneID.Level1: return sceneLevel1Next(app);
            case SceneID.GameOver: return sceneGameOverNext(app);
        }
        assert(0);
    }
}
