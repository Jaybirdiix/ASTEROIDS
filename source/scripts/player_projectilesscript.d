module scripts.player_projectilescript;

import bindbc.sdl;
import components;
import gameobject;
import engine.resource_manager;

import vec2 : Vec2f, DegreesToRadians;
import std.math : cos, sin;


void playerProjectileInit(GameObject* go, ResourceManager resource_manager, string texture_id) {
    go.texture.texture = resource_manager.getTextureById(texture_id);

    // setup
    go.transform.rect = SDL_FRect(0, 0, 20, 80);
    go.transform.xv = 0;
    go.transform.yv = 0;
    go.transform.speed = 20;
    go.transform.angle = 0;

    go.animation.frameWidth = cast(int) go.transform.rect.w;
    go.animation.frameHeight = cast(int) go.transform.rect.h;
    go.animation.currentFrame = 0;
    go.animation.numberOfFrames = 1;
    go.animation.timePerFrame = 100;
    go.animation.timeSinceLastFrame = 0;

    go.projectileState.active = false;
    go.projectileState.enemy = false;
    go.projectileState.speedCap = 24;



}

// void playerProjectileFire(GameObject* proj, const GameObject* player) {
//     if (proj.projectileState.active) return;
//     // move projectile to player and then mark as active / fire it
//     proj.transform.rect.x = player.transform.rect.x + player.transform.rect.w / 2 - proj.transform.rect.w / 2;
//     proj.transform.rect.y = player.transform.rect.y - 2;
//     proj.transform.yv = -proj.transform.speed;
//     proj.projectileState.active = true;
// }

void playerProjectileFire(GameObject* proj, const GameObject* player) {

    proj.projectileState.timeToDespawn = 0;

    // if not active ignore
    if (proj.projectileState.active) return;

    // take player angle --> radians
    // then turn it into the unit vector for the direction
    float angRad = DegreesToRadians(cast(float) player.transform.angle - 90);
    Vec2f unit_vector = Vec2f(cos(angRad), sin(angRad)).Normalize();

    // get the center of the ship
    auto player_rect = player.transform.rect;
    // player width / 2 + x location
    // player height / 2 + y location
    Vec2f player_center = Vec2f(player_rect.x + player_rect.w * 0.5f, player_rect.y + player_rect.h * 0.5f);

    Vec2f spawn = player_center + unit_vector;

    // place it at the spawn point
    auto r = proj.transform.rect;
    r.x = spawn.x - r.w * 0.5f;
    r.y = spawn.y - r.h * 0.5f;
    proj.transform.rect = r;

    // set the velocity
    float speed = 1200.0f;
    Vec2f vel = unit_vector * speed;
    proj.transform.xv = vel.x;
    proj.transform.yv = vel.y;

    // rotate to match player angle
    proj.transform.angle = player.transform.angle;

    proj.projectileState.active = true;
}


// move projectile & spin
void playerProjectileUpdate(GameObject* proj, int deltaMs) {
    // if (!proj.projectileState.active) return;
    // proj.transform.rect.y += proj.transform.yv;
    // proj.transform.angle += 10.0f;


    if (!proj.projectileState.active) return;

    // timer
    proj.projectileState.timeToDespawn += deltaMs;
    if (proj.projectileState.timeToDespawn >= proj.projectileState.despawnTime) {
        playerProjectileReset(proj);
    }

    float dt = .05f;
    proj.transform.rect.x += proj.transform.xv * dt;
    proj.transform.rect.y += proj.transform.yv * dt;
    // proj.transform.angle += 360.0f * dt; // cosmetic spin

}

void playerProjectileRender(GameObject* proj, SDL_Renderer* r) {
    if (r is null || proj is null || proj.texture.texture is null) return;
    if (!proj.projectileState.active) return;

    // only render active ones
    // rotation
    SDL_FPoint pivot = SDL_FPoint(proj.transform.rect.w * 0.5f, proj.transform.rect.h * 0.5f);
    SDL_RenderTextureRotated(r, proj.texture.texture, null, &proj.transform.rect, proj.transform.angle, &pivot, SDL_FLIP_NONE);

}

void playerProjectileRenderAt(GameObject* go, SDL_Renderer* r, SDL_FRect screenRect, GameObject* player) {
    if (!go.projectileState.active) return;

    // only render active ones
    // SDL_RenderTexture(r, go.texture.texture, null, &screenRect);
    SDL_FPoint pivot = SDL_FPoint(screenRect.w * 0.5f, screenRect.h * 0.5f);
    SDL_RenderTextureRotated(r, go.texture.texture, null, &screenRect, player.transform.angle, &pivot, SDL_FLIP_NONE);
}

void playerProjectileReset(GameObject* proj) {
    proj.projectileState.active = false;
    proj.transform.yv = 0;
}

bool playerProjectileHitBounds(GameObject* proj, int windowHeight) {
    bool hit = proj.transform.rect.y < 0 || proj.transform.rect.y > windowHeight;
    return hit;
}
