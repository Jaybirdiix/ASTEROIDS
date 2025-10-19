module scripts.playerscript;

import bindbc.sdl;
import components;
import gameobject;
import engine.resource_manager;


void playerInit(GameObject* go, ResourceManager resource_manager, string texture_id) {
    go.texture.texture = resource_manager.getTextureById(texture_id);

    // setup
    go.transform.rect = SDL_FRect(50, 50, 40, 40);
    go.transform.xv = 0;
    go.transform.yv = 0;
    go.transform.speed = 5;
    go.transform.angle = 0;
    go.transform.rotateVelocity = 0;

    go.animation.frameWidth = cast(int) go.transform.rect.w;
    go.animation.frameHeight = cast(int) go.transform.rect.h;
    go.animation.currentFrame = 0;
    go.animation.numberOfFrames = 1;
    go.animation.timePerFrame = 100;
    go.animation.timeSinceLastFrame = 0;

    go.playerState.facingLeft = true;
}

void playerSetPosition(GameObject* go, int x, int y) {
    go.transform.rect.x = x;
    go.transform.rect.y = y;
}

// set size same as alien
void playerSetSize(GameObject* go, int w, int h) {
    if (h == 0) {
        double ratio = cast(double) w / go.transform.rect.w;
        go.transform.rect.w = w;
        go.transform.rect.h = cast(int) (go.transform.rect.h * ratio);
    } else {
        go.transform.rect.w = w;
        go.transform.rect.h = h;
    }
}

// need this to scale from a specific w and h
void playerScale(GameObject* go, float s) {
    auto scaled_w = cast(int) (cast(float) go.transform.rect.w * s);
    auto scaled_h = cast(int) (cast(float) go.transform.rect.h * s);
    go.transform.rect.w = cast(int) scaled_w;
    go.transform.rect.h = cast(int) scaled_h;
}

// animate
void playerUpdateAnimation(GameObject* go, int ms) {
    go.transform.rotateVelocity *= 0.5f;
    go.transform.angle += go.transform.rotateVelocity;


    go.animation.timeSinceLastFrame += ms;
    if (go.animation.timeSinceLastFrame >= go.animation.timePerFrame) {
        go.animation.timeSinceLastFrame = 0;
        go.animation.currentFrame = (go.animation.currentFrame + 1) % go.animation.numberOfFrames;
    }
}

void playerRender(GameObject* go, SDL_Renderer* renderer) {

    if (go.animation.numberOfFrames > 1) {
        SDL_FRect src;
        src.x = go.animation.frameWidth * go.animation.currentFrame;

        src.y = 0;
        src.w = go.animation.frameWidth;
        src.h = go.animation.frameHeight;

        SDL_FRect dst = go.transform.rect;

        if (!go.playerState.facingLeft) {
            dst.x += dst.w;
            dst.w = -dst.w;
        }
        SDL_FPoint pivot = SDL_FPoint(go.transform.rect.w * 0.5f, go.transform.rect.h * 0.5f);
        SDL_RenderTextureRotated(renderer, go.texture.texture, null, &go.transform.rect, go.transform.angle, &pivot, SDL_FLIP_NONE);
    } else {
        SDL_FPoint pivot = SDL_FPoint(go.transform.rect.w * 0.5f, go.transform.rect.h * 0.5f);
        SDL_RenderTextureRotated(renderer, go.texture.texture, null, &go.transform.rect, go.transform.angle, &pivot, SDL_FLIP_NONE);
    }
}

void playerRenderAt(GameObject* go, SDL_Renderer* renderer, in SDL_FRect screenRect) {
    if (go.animation.numberOfFrames > 1) {
        SDL_FRect src = screenRect;

        src.x = go.animation.frameWidth * go.animation.currentFrame;
        src.y = 0;
        src.w = go.animation.frameWidth;
        src.h = go.animation.frameHeight;

        SDL_FRect dst = screenRect;

        if (!go.playerState.facingLeft) {
            dst.x += dst.w;
            dst.w = -dst.w;
        }
        // SDL_RenderTexture(renderer, go.texture.texture, &src, &dst);
        SDL_FPoint pivot = SDL_FPoint(screenRect.w * 0.5f, screenRect.h * 0.5f);
        SDL_RenderTextureRotated(renderer, go.texture.texture, &src, &screenRect, go.transform.angle, &pivot, SDL_FLIP_NONE);
    } else {
        // SDL_RenderTexture(renderer, go.texture.texture, null, &screenRect);
        SDL_FPoint pivot = SDL_FPoint(screenRect.w * 0.5f, screenRect.h * 0.5f);
        SDL_RenderTextureRotated(renderer, go.texture.texture, null, &screenRect, go.transform.angle, &pivot, SDL_FLIP_NONE);
    }
}

void playerCheckEdges(GameObject* go, int worldWidth, int worldHeight) {
    // width
    if (go.transform.rect.x < 0) {
        go.transform.rect.x = 0;
    } else if (go.transform.rect.x + go.transform.rect.w > worldWidth) {
        go.transform.rect.x = worldWidth - go.transform.rect.w;
    }

    // height
    if (go.transform.rect.y < 0) {
        go.transform.rect.y = 0;
    } else if (go.transform.rect.y + go.transform.rect.h > worldHeight) {
        go.transform.rect.y = worldHeight - go.transform.rect.h;
    }
}

// change velocities
void playerMoveLeft(GameObject* go) {
    go.transform.xv += -go.transform.speed;
    go.playerState.facingLeft = true;
}
void playerMoveRight(GameObject* go) {
    go.transform.xv += go.transform.speed;
    go.playerState.facingLeft = false;
}

void playerMoveUp(GameObject* go) {
    go.transform.yv += -go.transform.speed;
}
void playerMoveDown(GameObject* go) {
    go.transform.yv += go.transform.speed;
}

void playerStop(GameObject* go) {
    go.transform.xv = 0;
    go.transform.yv = 0;
}

void playerRotateLeft(GameObject * go) {

    go.transform.rotateVelocity -= 4;

    // keep the angle within bounds
    if (go.transform.angle >= 360) go.transform.angle -= 360;
    if (go.transform.angle < 0) go.transform.angle += 360;
}

void playerRotateRight(GameObject * go) {
    go.transform.rotateVelocity += 4;

    // keep the angle within bounds
    if (go.transform.angle >= 360) go.transform.angle -= 360;
    if (go.transform.angle < 0) go.transform.angle += 360;
}

// move physically
void playerMove_X(GameObject* go) {
    go.transform.rect.x += go.transform.xv;
}
void playerMove_Y(GameObject* go) {
    go.transform.rect.y += go.transform.yv;
}
