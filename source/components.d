module components;

import bindbc.sdl;

struct Transform {
    SDL_FRect rect;
    float xv, yv;
    float speed;
    float angle;
    float rotateVelocity;
}

struct Texture {
    SDL_Texture* texture;
}

struct Animation {
    int frameWidth, frameHeight;
    int currentFrame, numberOfFrames;
    int timePerFrame, timeSinceLastFrame;
}

alias UpdateFunc = void delegate(int deltaMs);
struct Script {
    UpdateFunc onUpdate;
}

struct PlayerState {
    bool facingLeft = true;
    bool destroyed = false;
    bool projAvailable = false;
    ulong nextShotTime = 0;
}

struct AlienState{
    bool destroyed = false;
}

struct ProjectileState {
    bool active = false;
    bool enemy = false;
    ulong nextShotTime = 0;
    int speedCap = 20;
    int timeToDespawn = 0;
    int despawnTime = 1250;
}
