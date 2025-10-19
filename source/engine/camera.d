module engine.camera;

import bindbc.sdl;

struct Camera {
    float x, y;
    int viewportW, viewportH;
    int worldW, worldH;
    float lerp = 0.15f; //smoothing
    bool limitEdges = true;
}

// limit camera bounds
float limit(float v, float low, float high) {
    if (v<low) {
        return low;
    } else if (v > high) {
        return high;
    }
    return v;
}

// rly important function used everywhere
// world coords to screen coords
SDL_FRect worldToScreen(in SDL_FRect r, in Camera c) {
    auto x = r.x - c.x;
    auto y = r.y - c.y;
    return SDL_FRect(x, y, r.w, r.h);
}

// rly important function used everywhere
// screen coords to world coords
SDL_FPoint screenToWorld(float sx, float sy, in Camera c) {
    auto x = sx + c.x;
    auto y = sy + c.y;
    return SDL_FPoint(x, y);
}

void cameraFollowLerp(ref Camera c, in SDL_FRect target) {
    // this is the x and y
    auto targetX = target.x + target.w * 0.5f - c.viewportW * 0.5f;
    auto targetY = target.y + target.h * 0.5f - c.viewportH * 0.5f;

    // add this awesome little drag
    c.x += (targetX - c.x) * c.lerp;
    c.y += (targetY - c.y) * c.lerp;

    if (c.limitEdges) {
        c.x = limit(c.x, 0, cast(float)(c.worldW  - c.viewportW));
        c.y = limit(c.y, 0, cast(float)(c.worldH - c.viewportH));
    }
}
