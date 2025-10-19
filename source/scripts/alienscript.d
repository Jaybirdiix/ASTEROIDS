module scripts.alienscript;

import bindbc.sdl;
import std.string : toStringz;
import components;
import gameobject;
import engine.resource_manager;
import std.random : Random, uniform;
import std.math : PI, cos, sin;


void alienInit(GameObject* go, ResourceManager resource_manager, string texture_id) {
    go.texture.texture = resource_manager.getTextureById(texture_id);

    // transform stuff
    go.transform.rect = SDL_FRect(0, 0, 40, 40);
    go.transform.xv = 0;
    go.transform.yv = 0;
    go.transform.speed = 0;
    go.transform.angle = 0;

    // animation stuff
    go.animation.frameWidth = cast(int) go.transform.rect.w;
    go.animation.frameHeight = cast(int) go.transform.rect.h;
    go.animation.currentFrame = 0;
    go.animation.numberOfFrames = 1;
    go.animation.timePerFrame = 100;
    go.animation.timeSinceLastFrame = 0;

    // state
    go.alienState.destroyed = false;
}

void alienUpdate(GameObject * go, int worldWidth, int worldHeight) {
    if (go.alienState.destroyed) return;

    float dt = .016f;

    static Random rng = Random(42);

    alienFloatUpdate(go, worldWidth, worldHeight, dt, rng);

    
    // spin !
    go.transform.angle += uniform(.1, .5);
}

void alienSetPosition(GameObject* go, int x, int y) {
    go.transform.rect.x = x;
    go.transform.rect.y = y;
}

// if h is zero use proportions to scale height
void alienSetSize(GameObject* go, int w, int h) {
    if (h == 0) {
        double ratio = cast(double) w / go.transform.rect.w;
        go.transform.rect.w = w;
        go.transform.rect.h = cast(int) (go.transform.rect.h * ratio);
    } else {
        go.transform.rect.w = w;
        go.transform.rect.h = h;
    }
}

void alienRender(GameObject* go, SDL_Renderer* renderer) {
    if (go.alienState.destroyed) return;
    // only render alive ones
    // SDL_RenderTexture(r, go.texture.texture, null, &go.transform.rect);
    SDL_FPoint pivot = SDL_FPoint(go.transform.rect.w * 0.5f, go.transform.rect.h * 0.5f);
    SDL_RenderTextureRotated(renderer, go.texture.texture, null, &go.transform.rect, go.transform.angle, &pivot, SDL_FLIP_NONE);
}

void alienRenderAt(GameObject* go, SDL_Renderer* renderer, in SDL_FRect screenRect) {
    if (go.alienState.destroyed) return;
    // only render alive ones
    SDL_FPoint pivot = SDL_FPoint(screenRect.w * 0.5f, screenRect.h * 0.5f);
    SDL_RenderTextureRotated(renderer, go.texture.texture, null, &screenRect, go.transform.angle, &pivot, SDL_FLIP_NONE);
    // SDL_RenderTexture(r, go.texture.texture, null, &screenRect);
}

void alienDestroy(GameObject* go) {
    go.alienState.destroyed = true;
}

bool alienAlive(GameObject* go) {
    return !go.alienState.destroyed;
}


struct ScatterConfig {
    float edgePad = 80; // stay away from edges
    float sepPad = 120; // minimum separation between astreoids
    float playerPad = 200; // give space from player
    int maxTries = 200; // try amount max per asteroid
}

// initialize aliens
void initAliens(GameObject[] aliens, ResourceManager resources, string texId) {
    foreach (ref a; aliens) {
        // mani values
        alienInit(&a, resources, texId);
        auto rnd = Random(42);
        // floating locations
        alienFloatInit(&a, rnd);
        // size
        alienSetSize(&a, 250, 0);
    }
}

// scatter asteroids
void scatterAliens(GameObject[] aliens, int worldW, int worldH,
    SDL_FRect playerStartRect, ref Random rnd, ScatterConfig cfg = ScatterConfig.init){

    // helpers
    // standard collision
    static bool collision(in SDL_FRect a, in SDL_FRect b) @safe @nogc nothrow {
        if (a.x + a.w <= b.x) return false;
        if (a.x >= b.x + b.w) return false;
        if (a.y + a.h <= b.y) return false;
        if (a.y >= b.y + b.h) return false;
        return true;
    }

    static bool overlapsWithPad(in SDL_FRect a, in SDL_FRect b, float pad) @safe @nogc nothrow {
        SDL_FRect bp = SDL_FRect(b.x - pad, b.y - pad, b.w + 2*pad, b.h + 2*pad);
        return collision(a, bp);
    }

    // area around player
    const SDL_FRect playerArea = SDL_FRect(
        playerStartRect.x - cfg.playerPad,
        playerStartRect.y - cfg.playerPad,
        playerStartRect.w + 2*cfg.playerPad,
        playerStartRect.h + 2*cfg.playerPad
    );

    foreach (i, ref a; aliens) {
        // temporary rect for testing
        SDL_FRect r;
        r.w = a.transform.rect.w;
        r.h = a.transform.rect.h;

        bool placed = false;
        int tries = 0;

        while (!placed && tries++ < cfg.maxTries) {
            // get random x and y within bounds
            r.x = cast(float) uniform(
                cast(int) cfg.edgePad,
                cast(int) (worldW - cfg.edgePad - r.w),
                rnd
            );
            r.y = cast(float) uniform(
                cast(int) cfg.edgePad,
                cast(int) (worldH - cfg.edgePad - r.h),
                rnd
            );

            // try again if in player space
            if (collision(r, playerArea)) continue;

            // set the position if it's okay
            alienSetPosition(&a, cast(int) r.x, cast(int) r.y);
            placed = true;
        }

    }
}

// put both in one
void initAndScatterAliens(GameObject[] aliens, ResourceManager resources, string texId,
int worldW, int worldH, SDL_FRect playerStartRect, ref Random rnd, ScatterConfig cfg = ScatterConfig.init) {
    initAliens(aliens, resources, texId);
    scatterAliens(aliens, worldW, worldH, playerStartRect, rnd, cfg);
}


// move aliens 
// rotate 
void rotate(ref float x, ref float y, float radians) {
    import std.math : cos, sin;
    const c = cos(radians), s = sin(radians);
    const nx = x*c - y*s;
    const ny = x*s + y*c;
    x = nx; y = ny;
}

// normalize (protect against tiny length)
void normalize(ref float x, ref float y) {
    import std.math : sqrt;
    const len = sqrt(x*x + y*y);
    if (len > 1e-6f) { x /= len; y /= len; }
    else { x = 1; y = 0; }
}


void alienFloatInit(GameObject* go, ref Random rng) {
    const theta = uniform(0.0f, 2.0f*cast(float)PI, rng);
    go.transform.xv = cos(theta);
    go.transform.yv = sin(theta);
    go.transform.speed = uniform(30.0f, 80.0f, rng);
}

void alienFloatUpdate(GameObject* go, int worldW, int worldH, float dt, ref Random rng) {
    if (go.alienState.destroyed) return;

    // turn a little bit all the time so they go in random directions
    const turn = uniform(-0.8f, 0.8f, rng) * dt;
    rotate(go.transform.xv, go.transform.yv, turn);
    normalize(go.transform.xv, go.transform.yv);

    // move
    const vx = go.transform.xv * go.transform.speed * dt;
    const vy = go.transform.yv * go.transform.speed * dt;
    go.transform.rect.x += vx;
    go.transform.rect.y += vy;

    // incorporate wrapping if they cross the screen
    if (go.transform.rect.x + go.transform.rect.w < 0) go.transform.rect.x = worldW - 1;
    if (go.transform.rect.x > worldW) go.transform.rect.x = -go.transform.rect.w + 1;
    if (go.transform.rect.y + go.transform.rect.h < 0) go.transform.rect.y = worldH - 1;
    if (go.transform.rect.y > worldH) go.transform.rect.y = -go.transform.rect.h + 1;

    // SPINNNNNNNNN
    go.transform.angle += uniform(30.0f, 90.0f, rng) * dt;
}
