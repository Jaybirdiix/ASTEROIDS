module engine.scene_tree;

import bindbc.sdl;
import gameobject;

enum SceneLayer : int { Background = 0, World = 1, Foreground = 2, UI = 3 }

alias UpdateFunction = void delegate(float dt);
alias RenderFunction = void delegate(SDL_Renderer* renderer);

struct SceneObjects {
    GameObject* obj;
    SceneLayer layer;
    UpdateFunction onUpdate;
    RenderFunction onRender;
    bool enabled = true;
}

struct SceneTree {
    GameObject*[] nodes;
    SceneObjects[] entries;

    void clear() {
        nodes.length = 0;
        entries.length = 0;
    }

    // add things to the scene by adding each object, layer, update function and render function
    size_t add(GameObject* obj, SceneLayer layer, UpdateFunction u, RenderFunction r, bool enabled = true) {
        entries ~= SceneObjects(obj, layer, u, r, enabled);
        return entries.length - 1;
    }

    // update if it's supposed to be there
    void update(float dt) {
        foreach (ref e; entries) {
            if (!e.enabled) continue;
            if (e.onUpdate !is null) e.onUpdate(dt);
        }
    }

    // render using the layer to determine the order
    void render(SDL_Renderer* r) {
        foreach (layer; [SceneLayer.Background, SceneLayer.World, SceneLayer.Foreground, SceneLayer.UI]) {
            foreach (ref e; entries) {
                if (!e.enabled || e.layer != layer) continue;
                if (e.onRender !is null) e.onRender(r);
            }
        }
    }
}
