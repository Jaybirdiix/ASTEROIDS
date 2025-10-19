/// Run with: 'dub'

// Entry point to program
// DYLD_LIBRARY_PATH=/usr/local/lib dub run
import gameapplication;

void main()
{
    GameApplication app = GameApplication("Space Invaders Deux");
	app.RunLoop();
}
