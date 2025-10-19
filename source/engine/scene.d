module scene;

import bindbc.sdl;

interface IScene {
    void onEnter(SDL_Renderer* renderer);
    void onExit();
    void handleEvent(in SDL_Event* ev);
    void update(float dt);
    void render(SDL_Renderer* renderer);
    bool isFinished();
    IScene nextScene();
}