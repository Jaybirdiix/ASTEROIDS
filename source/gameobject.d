module gameobject;

import components;

struct GameObject {
    Transform transform;
    Texture texture;
    Animation animation;
    Script script;

    PlayerState playerState;
    AlienState alienState;
    ProjectileState projectileState;
}
