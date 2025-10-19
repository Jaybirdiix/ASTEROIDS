module gameapplication;

import std.stdio;
import std.string;
import std.random;
import bindbc.sdl;
import std.string : toStringz;
import components;
import gameobject;
import engine.resource_manager;
import scripts.playerscript;
import scripts.alienscript;
import scripts.player_projectilescript;   
// import scripts.alien_projectilescript;    

import engine.camera;
// import engine.scene; 


import scenes.flags : gMenuStart, gLevelDone, gGameOverBackToMenu, gWon;


import vec2 : Vec2f, DegreesToRadians;


enum SceneID { MainMenu, Level1, GameOver }
// struct SceneTree { GameObject*[] nodes; }
import engine.scene_tree; 

import scenes.scene_manager;


struct GameApplication {
    // all  objects in game
    GameObject player;
    GameObject playerProjectile;
    GameObject[0] alienProjectiles;
    GameObject[30] aliens;

    // scene manager + tree
    SceneTree sceneTree;
    SceneManager mScenes;
    

    // camera
    Camera cam;
    int worldWidth  = 6000; 
    int worldHeight = 4400; 
    // scenes
    // IScene currentScene = null;  
    

    ResourceManager resources = null;

    // screen etc
    SDL_Window* mWindow = null;
    SDL_Renderer* mRenderer = null;
    bool mGameIsRunning = true;

    int windowWidth = 1920;
    int windowHeight = 1480;

    bool aHeld;
    bool dHeld;
    bool wHeld;
    bool sHeld;
    bool leftArrowHeld, rightArrowHeld;
    ulong lastTick;

    // audio
    SDL_AudioStream* sfxStream = null;
    SDL_AudioSpec shootSpec;
    ubyte* shootWav = null;
    uint shootLen = 0;


    SDL_Texture* background_texture = null;
    SDL_Texture* parallax1_texture = null;
    SDL_Texture* parallax2_texture = null;

    SDL_Texture* foreground_texture = null;
    SDL_FRect background_rect;
    SDL_FRect foreground_rect;

    size_t aliensKilled = 0;

    this(string title) {
        mWindow = SDL_CreateWindow(title.toStringz, windowWidth, windowHeight, SDL_WINDOW_ALWAYS_ON_TOP);
        mRenderer = SDL_CreateRenderer(mWindow, null);

        // audio
        SDL_InitSubSystem(SDL_INIT_AUDIO);
        SDL_LoadWAV("./assets/images/shoot.wav".toStringz, &shootSpec, &shootWav, &shootLen);

        sfxStream = SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, &shootSpec, null, null);
        SDL_ResumeAudioStreamDevice(sfxStream);


        // resources
        resources = new ResourceManager();
        resources.init(mRenderer);
        resources.preloadFromJSON("resources.json");

        // scenes
        mScenes.init(&this, SceneID.MainMenu, mRenderer);

        // camera
        cam = Camera(
            0, 0,
            windowWidth, windowHeight,
            worldWidth, worldHeight,
            0.15f, true
        );

        // bg and foreground
        background_texture = resources.getTextureById("bg");
        parallax1_texture = resources.getTextureById("par1"); // farther foreground
        parallax2_texture = resources.getTextureById("par2");

        foreground_texture = resources.getTextureById("fg");
        // background_rect = SDL_FRect(0, 0, windowWidth, windowHeight);
        background_rect = SDL_FRect(0, 0, worldWidth, worldHeight);
        foreground_rect = SDL_FRect(0, 0, windowWidth, windowHeight);

        // player
        playerInit(&player, resources, "player");
        playerSetPosition(&player, 960, 1000);
        playerSetSize(&player, 700, 0);
        playerScale(&player, .4f);
        player.animation.frameWidth = 663;
        player.animation.frameHeight = 700;
        player.animation.numberOfFrames = 11;
        player.animation.timePerFrame = 100;

        // player projectile
        playerProjectileInit(&playerProjectile, resources, "player_proj");
    }

    ~this() {
        // audio
        if (sfxStream !is null) {
            SDL_DestroyAudioStream(sfxStream);
            sfxStream = null;
        }
        if (shootWav !is null) {
            SDL_free(cast(void*) shootWav);
            shootWav = null;
        }

        resources.destroy();
        SDL_DestroyRenderer(mRenderer);
        SDL_DestroyWindow(mWindow);
    }

    void Input() {
        SDL_Event event;

        while (SDL_PollEvent(&event)) {

            // for scenes
            if (event.type == SDL_EVENT_QUIT) mGameIsRunning = false;
            mScenes.handleEvent(&event);  // forward input to scene

            // adding this to quit early
            if (event.type == SDL_EVENT_QUIT) {
                mGameIsRunning = false;
            }
            // a and d and space
            if (event.type == SDL_EVENT_KEY_DOWN) {

                // KEY DOWN
                if (event.type == SDL_EVENT_KEY_DOWN) {
                    switch (event.key.scancode) {
                        case SDL_SCANCODE_LEFT: aHeld = true;  break;
                        case SDL_SCANCODE_RIGHT: dHeld = true;  break;
                        case SDL_SCANCODE_UP: wHeld = true;  break;
                        case SDL_SCANCODE_DOWN: sHeld = true;  break;
                        case SDL_SCANCODE_A: leftArrowHeld = true; break;
                        case SDL_SCANCODE_D: rightArrowHeld = true; break;
                        default: break;
                    }
                }
                
                if (event.key.key == SDLK_SPACE) {
                    if (!playerProjectile.projectileState.active) {
                        // play sound
                        if (sfxStream !is null && shootWav !is null && shootLen > 0) {
                            SDL_PutAudioStreamData(sfxStream, shootWav, cast(int) shootLen);
                        }
                        // fire
                        playerProjectileFire(&playerProjectile, &player);
                    }
                }
            }
            

            // KEY UP
            if (event.type == SDL_EVENT_KEY_UP) {
                switch (event.key.scancode) {
                    case SDL_SCANCODE_LEFT: aHeld = false; break;
                    case SDL_SCANCODE_RIGHT: dHeld = false; break;
                    case SDL_SCANCODE_UP: wHeld = false; break;
                    case SDL_SCANCODE_DOWN: sHeld = false; break;
                    case SDL_SCANCODE_A: leftArrowHeld = false; break;
                    case SDL_SCANCODE_D: rightArrowHeld = false; break;
                    default: break;
                }
            }


        }

        // move player
        if (aHeld && !dHeld) {
            playerMoveLeft(&player);
        } else if (dHeld && !aHeld) {
            playerMoveRight(&player);
        }

        if (sHeld && !wHeld) {
            playerMoveDown(&player);
        } else if (!sHeld && wHeld) {
            playerMoveUp(&player);
        }


        int dir = 0;
        if (leftArrowHeld  && !rightArrowHeld) {
            playerRotateLeft(&player);
        } else if (rightArrowHeld && !leftArrowHeld ) {
            playerRotateRight(&player);
        }



    }

    // old colliosion
    bool original_collision(SDL_FRect a, SDL_FRect b) {
        if (a.x + a.w <= b.x) return false;
        if (a.x >= b.x + b.w) return false;
        if (a.y + a.h <= b.y) return false;
        if (a.y >= b.y + b.h) return false;
        return true;
    }

    // allow a little tiny bit of overlap
    SDL_FRect littleRect(SDL_FRect r, float frac) {
        if (frac <= 0) return r;
        float fx = r.w * frac;
        float fy = r.h * frac;
        float nw = r.w - 2*fx;
        float nh = r.h - 2*fy;
        if (nw < 1) nw = 1; // avoid negatives or zero
        if (nh < 1) nh = 1;
        return SDL_FRect(r.x + fx, r.y + fy, nw, nh);
    }

    // padded collision
    bool collision(SDL_FRect a, SDL_FRect b, float padA = 0.15f, float padB = 0.15f) {
        a = littleRect(a, padA);
        b = littleRect(b, padB);
        if (a.x + a.w <= b.x) return false;
        if (a.x >= b.x + b.w) return false;
        if (a.y + a.h <= b.y) return false;
        if (a.y >= b.y + b.h) return false;
        return true;
    }

    void Update() {
        ulong now = SDL_GetTicks();
        int deltaTime = cast(int) (now - lastTick);
        lastTick = now;

        mScenes.update(deltaTime / 1000.0f, mRenderer);

        if (mScenes.current == SceneID.MainMenu || mScenes.current == SceneID.GameOver) {
            return;
        }

        float dtSec = deltaTime / 1000.0f;

        // use scene tree for object updates
        sceneTree.update(dtSec);

        // move camera after updates so the player pos is updated before
        cameraFollowLerp(cam, player.transform.rect);

        // collision checks
        foreach (ref a; aliens) {
            alienUpdate(&a, worldWidth, worldHeight);
            if (!alienAlive(&a)) continue;
            if (collision(player.transform.rect, a.transform.rect)) {
                gWon = false;
                gLevelDone = true;
                break;
            }
        }

        

        if (playerProjectile.projectileState.active) {
            // alien death counter
            foreach (ref a; aliens) {
                if (!alienAlive(&a)) continue;
                if (original_collision(playerProjectile.transform.rect, a.transform.rect)) {
                    alienDestroy(&a);
                    aliensKilled += 1;
                    playerProjectileReset(&playerProjectile);
                }
            }
        }

        playerUpdateAnimation(&player, deltaTime);
        playerMove_X(&player);
        playerMove_Y(&player);
        playerCheckEdges(&player, worldWidth, worldHeight);

        // move camera
        cameraFollowLerp(cam, player.transform.rect);

        // player seed update INCLUDING timer i think
        playerProjectileUpdate(&playerProjectile, deltaTime);

        // if all the strawberries have been eaten, you win
        bool allDead = true;
        foreach (ref a; aliens) {
            if (alienAlive(&a)) { allDead = false; break; }
        }
    }

    private void renderParallax(SDL_Texture* tex, float factor, float scale = 1.2f) {
        if (tex is null) return;

        const float drawW = windowWidth  * scale;
        const float drawH = windowHeight * scale;

        SDL_FRect dst = SDL_FRect(
            -cam.x * factor - (drawW - windowWidth) * 0.5f,
            -cam.y * factor - (drawH - windowHeight) * 0.5f,
            drawW, drawH
        );
        SDL_RenderTexture(mRenderer, tex, null, &dst);
    }


    void Render() {

        SDL_SetRenderScale(mRenderer, 1.0f, 1.0f);
        SDL_SetRenderDrawColor(mRenderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
        SDL_RenderClear(mRenderer);

        // render scenes
        mScenes.render(mRenderer);

        // If we are in the Main Menu, draw only the menu and present.
        if (mScenes.current == SceneID.MainMenu) {
            SDL_RenderPresent(mRenderer);
            return; // don't draw the world behind the menu
        }

        // background
        SDL_FRect bgDst = SDL_FRect(-cam.x, -cam.y, background_rect.w, background_rect.h);
        if (background_texture !is null) {
            SDL_RenderTexture(mRenderer, background_texture, null, &bgDst);
        }

        renderParallax(parallax1_texture, 0.35f, 1.3f);
        renderParallax(parallax2_texture, 0.65f, 1.15f);

        auto scrRec = worldToScreen(playerProjectile.transform.rect, cam);
        // despawn when it leaves window
        if (scrRec.x + scrRec.w < 0 || scrRec.x > windowWidth ||
            scrRec.y + scrRec.h < 0 || scrRec.y > windowHeight) {
            playerProjectileReset(&playerProjectile);
        }
        playerProjectileRenderAt(&playerProjectile, mRenderer, scrRec, &player);

        // aliens
        foreach (ref a; aliens) {
            auto sr = worldToScreen(a.transform.rect, cam);
            alienRenderAt(&a, mRenderer, sr);
        }

        // player
        auto sr = worldToScreen(player.transform.rect, cam);
        playerRenderAt(&player, mRenderer, sr);



        // text
        SDL_SetRenderScale(mRenderer, 3.0f, 3.0f);
        SDL_SetRenderDrawColor(mRenderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
        string hud = format("Asteroids Destroyed: %s / %d", aliensKilled, aliens.length);
        SDL_RenderDebugText(mRenderer, 3.0f, 3.0f, hud.toStringz);
        SDL_SetRenderScale(mRenderer, 1.0f, 1.0f);

        // if in the GameOver scene, add text
        if (mScenes.current == SceneID.GameOver) {
            SDL_SetRenderScale(mRenderer, 3.0f, 3.0f);
            SDL_RenderDebugText(mRenderer, 3.0f, 50.0f, "GAME OVER — press SPACE for Main Menu".toStringz);
            if (gWon) {
                SDL_RenderDebugText(mRenderer, 3.0f, 30.0f, "YOU WIN!".toStringz);
            } else {
                SDL_RenderDebugText(mRenderer, 3.0f, 30.0f, "YOU LOSE!".toStringz);
            }
            SDL_SetRenderScale(mRenderer, 1.0f, 1.0f);
        }

        SDL_RenderPresent(mRenderer);
    }

    void AdvanceFrame() {
        Input();
        Update();
        Render();
    }

    void RunLoop() {
        enum TARGET = 60;
        enum FRAME_MILLI = 1000 / TARGET;

        uint frames = 0;
        ulong timer = SDL_GetTicks();

        while (mGameIsRunning) {
            ulong frameStart = SDL_GetTicks();

            AdvanceFrame();
            frames++;

            ulong now = SDL_GetTicks();
            if (now - timer >= 1000) {
                double fps = frames * 1000.0 / (now - timer);
                SDL_SetWindowTitle(mWindow, format("%.1f FPS", fps).toStringz);
                timer = now;
                frames = 0;
            }

            ulong frameTime = SDL_GetTicks() - frameStart;
            if (frameTime < FRAME_MILLI) {
                SDL_Delay(cast(uint) (FRAME_MILLI - frameTime));
            }

            // slow player
            player.transform.xv *= .6f;
            player.transform.yv *= .6f;
        }
    }


}
