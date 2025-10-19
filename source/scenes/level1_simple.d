module scenes.level1_simple;

import bindbc.sdl;
import std.random : Random, uniform;
import gameapplication;
import scripts.playerscript;
import scripts.player_projectilescript;
import scenes.flags;

import engine.scene_tree;
import engine.camera;
import scripts.alienscript;

import gameobject;



void sceneLevel1Enter(GameApplication* app, SDL_Renderer* r) {
    gLevelDone = false;
    app.aliensKilled = 0;
    gWon = false;

    // reset player and player projectile
    playerSetPosition(&app.player, 960, 1000);
    app.player.transform.angle = 0;
    playerProjectileReset(&app.playerProjectile);

    // // build the level
    auto rnd = Random(42);
    initAndScatterAliens(
        app.aliens,
        app.resources,
        "alien",
        app.worldWidth,
        app.worldHeight,
        app.player.transform.rect,
        rnd,
        ScatterConfig(edgePad: 80, sepPad: 120, playerPad: 200, maxTries: 200)
    );

    // scene tree
    app.sceneTree.clear();

    // pointer list of stuff in scene
    // player
    app.sceneTree.nodes ~= &app.player;
    // aliens
    foreach (ref a; app.aliens) {
        app.sceneTree.nodes ~= &a;
    }

    // add player
    app.sceneTree.add(
        &app.player, SceneLayer.World,
        // update
        (dt) {
            playerUpdateAnimation(&app.player, cast(int)(dt * 1000));
            playerMove_X(&app.player);
            playerMove_Y(&app.player);
            playerCheckEdges(&app.player, app.worldWidth, app.worldHeight);
        },
        // render
        (ren) {
            auto sr = worldToScreen(app.player.transform.rect, app.cam);
            playerRenderAt(&app.player, ren, sr);
        }
    );

    // aliens
    foreach (ref a; app.aliens) {
        GameObject* ap = &a;
        app.sceneTree.add(
            ap, SceneLayer.World,
            (dt) {
                if (!alienAlive(ap)) return;
                // this causes errors
                // alienUpdate(ap, app.worldWidth, app.worldHeight);
            },
            (ren) {
                if (!alienAlive(ap)) return;
                auto sr = worldToScreen(ap.transform.rect, app.cam);
                alienRenderAt(ap, ren, sr);
            }
        );
    }

    // player projectile
    app.sceneTree.add(
        &app.playerProjectile, SceneLayer.World,
        (dt) {
            playerProjectileUpdate(&app.playerProjectile, cast(int)(dt * 1000));

            // reset if out of bounds
            auto sr = worldToScreen(app.playerProjectile.transform.rect, app.cam);
            if (sr.x + sr.w < 0 || sr.x > app.windowWidth ||
                sr.y + sr.h < 0 || sr.y > app.windowHeight) {
                playerProjectileReset(&app.playerProjectile);
            }
        },
        (ren) {
            auto sr = worldToScreen(app.playerProjectile.transform.rect, app.cam);
            playerProjectileRenderAt(&app.playerProjectile, ren, sr, &app.player);
        }
    );
}


void sceneLevel1Exit(GameApplication* app) {
    // clear tree
    app.sceneTree.clear();

}

void sceneLevel1Event(GameApplication* app, in SDL_Event* ev) {
    // hit m to go to menu, mostly for testing
    if (ev.type == SDL_EVENT_KEY_DOWN && ev.key.scancode == SDL_SCANCODE_M) {
        gLevelDone = true;
    }
}

void sceneLevel1Update(GameApplication* app, float dt) {

    if (app.aliensKilled >= app.aliens.length) {
        gLevelDone = true;
        gWon = true;
    }
}

void sceneLevel1Render(GameApplication* app, SDL_Renderer* r) {
    // nothing right now

}

bool sceneLevel1Finished(GameApplication* app) { return gLevelDone; }
SceneID sceneLevel1Next(GameApplication* app) { return SceneID.GameOver; }
