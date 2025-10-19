# Asteroids!

> "The year was 1979!"

# Resources to help

Provided below are a list of curated resources to help you complete the task(s) below. Consult them (read them, or do ctrl+f for keywords) if you get stuck.

| D Programming Related Links                         | Description                       |
| --------------------------------------------------  | --------------------------------- |
| [My D Youtube Series](https://www.youtube.com/playlist?list=PLvv0ScY6vfd9Fso-3cB4CGnSlW0E4btJV) | My video series playlist for learning D Lang. |
| [DLang Phobos Standard Library Index](https://dlang.org/phobos/index.html)  | The Phobos Runtime Library (i.e. standard library of code.)
| [D Language Tour](https://tour.dlang.org/)           | Nice introduction to the D Language with samples you can run in the browser. |
| [Programming in D](https://ddili.org/ders/d.en/)     | Freely available D language programming book |
| [My SDL 3 D Playlist](https://www.youtube.com/playlist?list=PLvv0ScY6vfd-5hY-sFyttTjfuUxG5c7OA) | My SDL 3 Playlist in D | 
| [My SDL 3 C++ Playlist](https://www.youtube.com/playlist?list=PLvv0ScY6vfd-RZSmGbLkZvkgec6lJ0BfX) | My SDL 3 Playlist in C++ (Also relevant for this course) |
| [My SDL 2 C++ Playlist](https://www.youtube.com/playlist?list=PLvv0ScY6vfd-p1gSnbQhY7vMe2rng0IL0)     | My SDL 2 Playlist (Older but some different lessons) |

## Description

<img width="400px" src="./media/romeros.jpg">

You've taken your game to PAX East (or PAX Prime if you're on the West coast) and [Brenda](https://en.wikipedia.org/wiki/Brenda_Romero) and [John](https://en.wikipedia.org/wiki/John_Romero) Romero have been playing your game! John and Brenda are two of the greats in the game industry. Each Brenda and John had their own individual success as game developers and game designers, and then joined forces later in life. They see real potential in you, and want to work on remake of another classic game with you -- "bring back Asteroids!", they exclaim! And maybe, just maybe if you do a great job, they may even offer you some venture capital money to publish your game (or at the least -- provide a testimonial in your Kick Starter/GoFundMe/IndiGoGo/etc campaign). Okay maybe I cannot as your instructor make any financial guarantees in this PSET, but it's an inspiring thought!

Alright -- with that excitement, let's figure out the work we need to do to put together Asteroids!

## Asteroids

Asteroids [wiki](https://en.wikipedia.org/wiki/Asteroids_(video_game)) is a classic game first appearing in the year 1979. I'd encourage you to otherwise take a few moments to play the game here: https://freeasteroids.org/

<img width="400px" src="./media/asteroids1.gif">

## Reusing previous code 

For this PSET you are allowed to use any of your previous PSETs or code from the instructor otherwise. You may copy any code into this directory otherwise if you would like to use your previous code, such that we can run your complete PSET from within this directory.

## This PSET

Your goal is to build something 'asteroid-like' with these requirements.

You must incorporate the following features:

- Game Engine
    1. Your engines game loop **must** be frame capped to 60 FPS
       - Note: It may be a good idea to start using a 'deltaTime' for frame independent movement as well.
	2. You **must** implement a ResourceManager such that any resource (e.g. an image, sprite sheet, etc.) is loaded through the resource manager
    3. You **must** implement sprite animation using a .json file for your animation (You can use the same format from the previous portion of this PSET if you like).
    4. You **must** create a 'scene tree' in which all of your GameObjects/GameEntities/GameActors are a part of.
    5. You **must** have at least two 'scenes' in your game.
        - I should be able to find a 'Scene', 'Level', or 'GameView' abstraction which contains the 'SceneTree'
        - I should be able to see some sort of 'SceneTree' or 'SceneGraph' structure (either in the 'Scene' or 'GameApplication' type.)
        	- In theory, you will know if this is working, if I can simply swap a 'scene' at any time during run-time and start playing a new level with the loaded data.
        		- e.g. One scene would be the game (level 1).
        		- e.g. One scene could be the main menu or more levels in the game.
  	        		- e.g. At the completion of one scene, you should be able to 'load' another scene (perhaps a different number of enemies in different orientations to proceed forward.
    6. Resource Loading
		- You **must** provide some mechanism to load resources (whether sprites, sounds, or otherwise) into your engine.
			- In an ideal world, we'll just run dub and a file called 'game.json' or 'resources.json' found in the root directory would otherwise provide all the paths to the sprite sheets and sounds your engine should load.
			- You have some flexibility here, but make it trivial and otherwise note the directions in the 'how to compile and run your program' section
- Core Game
	1. You **must** display the score (Bitmap font, debug text, SDL_TTF, etc.).
	2. You **must** have at least one 'sound' in your game
    3. You **must** have a 'ship' that you navigate.
        - The ship should be able to 'rotate'.
        - You should be able to fire projectiles either where the ship is pointed, or where the mouse is clicked.
    4. You **must** have 'asteroids' (i.e. a GameObject with a transform and SDL_Texture).
        - Asteroids should 'move' or float freely
        - You should be able to 'attack' the asteroids to destroy/remove them.
    5. You **must** be able to move off the screen into a bigger world.
        - i.e. Your window size may be 640x480 pixels, but your world should be large enough that you can 'move' the world with a camera (e.g. 1000x1000 pixels)
        - i.e. You otherwise should have a camera that follows your ship.

## Example solution

Below are some examples of what a solution could look like. Feel free otherwise to be creative (e.g. the shapeship can be replaced with a 'flying cat' attacking 'balls of yarn' if you prefer).

<img width="400px" src="./media/asteroids2.gif">
This example does a nice job showing firing projectiles (in this case a laser) and the ship rotating.

<img width="400px" src="./media/asteroids3.gif">
This example does a nice job showing a ship moving in a larger world (i.e. there are objects off the screen). However -- the asteroids should be moving freely to fully meet requirements of this PSET. This will make you otherwise think about 'screen space coordinates' and 'world space coordinates'
   
## How to compile and run your program

1. You can use simply run `dub` file to build and run the project.
   - Note: `dub` by default does a debug build.
   - Don't forget to use [gdb](https://www.youtube.com/watch?v=NWsZrN7gXYg) or [lldb](https://www.youtube.com/watch?v=drzvDkU-H54) if you run into errors!

### Special instructions

- **Note**: If there are any arguments that we should run (e.g. `dub -- game.json`, `dub -- start.json` , `dub -- level1.json`, etc.) please note that here.
	- *Edit and provide how we should run your PSET here if there is something more than `dub` to run. Please keep this trivial. Ideally your game should just run with 'dub' and search for a default path to find a game.json file.* 

# Submission/Deliverables

### Submission

- Commit all of your files to github, including any additional files you create.
- Do not commit any binary files unless told to do so.
- Do not commit any 'data' files generated when executing a binary.

### Deliverables

- A demo of an asteroids game that meets the above requirements.

# Going Further

An optional task(if any) that will reinforce your learning throughout the semester--this is not graded.

1. Add a way to 'save' and 'load' a game that is in progress.
	- i.e. Serialize and deserialize your 'scene'.

# F.A.Q. (Instructor Anticipated Questions)

0. Q: I'm lost.
   - A: How so? In some cases you might have to throw away your previous PSETs and start from scratch. Learning to throw away code is okay -- you'll probably be able to rebuild faster and with a better design too.
	- A: Something else? Come talk about it at office hours.
1. Q: How do I get nice physics?
    - A: It can be nice to add acceleration and deceleration to objects in your world. Consider using a vector that increments or decrements over time.
2. Q: Can I forget everything we did previously?
	- A: Probably not. :) It's a good idea to have game objects, script components, etc. even though I have not explicitly written out every single requirement from the previous PSETs. I can imagine scripts attached the main ship and asteroids to make the game more dynamic and easier to program anyway.
3. Q: Can I do something 'asteroids like' but that doesn't take place in space?
   	- A: Sure. As long as you have the core mechanics of asteroids (moving around a world bigger than the screen, shooting asteroids that move around, and ending the game if you crash) I'm fine with that.
   	- For example, a game where you are a hot air balloon throwing food at birds to help feed them would be equivalent.
   	  	- The 'hot air balloon' is your ship that navigates and points in different directions.
   	  	- You throw bird food at the birds and then they disappear happily on their journey.
   	  	- Birds move around.
   	  	- Hot air balloon navigates a larger area (i.e. the world is bigger than the number of pixels in your window)
   	  	- I think you get the idea that this is in the spirit of the PSET and meets the requirements as far as the game goes (and it's again a peaceful interpretation of the game idea utilizing your game engine).
