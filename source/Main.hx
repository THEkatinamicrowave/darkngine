package;

import flixel.FlxGame;
class Main extends Sprite
{
	public function new()
	{
		super();

		var game:FlxGame = new FlxGame(1280, 720, MainState);
		addChild(game);
	}
}
