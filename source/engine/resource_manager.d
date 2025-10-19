module engine.resource_manager;

import bindbc.sdl;
import std.string : toStringz;
import std.exception : enforce;
import std.file : readText, exists, getcwd;
import std.json : parseJSON, JSONValue;
import std.stdio : writeln;

// so i can exit on error
import core.stdc.stdlib : exit, abort;

/// texture manager for loading and caching SDL_Textures
class ResourceManager {
private:
    SDL_Renderer * renderer;
    SDL_Texture * [string] through_path; // get the texture from the path
    SDL_Texture * [string] through_id; // or get the texture from id

public:
    // constructor
    this() {}

    // initialize renderer
    void init(SDL_Renderer* r) {
        renderer = r;
    }

    // load the bmp once. then save the texture so that it's accessible
    // by just the pathname and then return the SDL_Texture*
    SDL_Texture* loadTexture(string path) {
        auto hit = path in through_path;
        if (hit !is null) return *hit;

        // load bmp file
        SDL_Surface* surface = SDL_LoadBMP(path.toStringz);

        // checksssss
        if (surface is null) {
            writeln("failed to load this path: ", path);
            exit(1);
        }

        // create the texture from the surface
        SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
        // checks again
        if (texture is null) {
            writeln("failed to load this path: ", path);
            exit(1);
        }

        // allows accessing the texture by giving the path
        through_path[path] = texture;
        return texture;
    }

    // add an id to a texture
    void registerTexture(string id, string path) {
        // get the texture by path and add an id
        SDL_Texture* texture = loadTexture(path);
        through_id[id] = texture;
    }

    // get texture by id
    SDL_Texture* getTextureById(string id) {
        if (!(id in through_id)) {
            writeln("id not recognized: " ~ id);
            exit(1);
        }
        return through_id[id];
    }

    // use json file
    void preloadFromJSON(string json_path) {
        string text = readText(json_path);
        JSONValue json_file = parseJSON(text);

        // load all textures
        foreach (texture; json_file["textures"].array) {
            string id = texture["id"].str;
            string path = texture["path"].str;
            bool fileOk = exists(path);
            registerTexture(id, path);
        }
    }

    // destroy everything
    void destroy() {
        foreach (id, texture; through_path) {
            if (texture !is null) SDL_DestroyTexture(texture);
        }
        through_path.destroy();
        through_id.destroy();
    }
}
