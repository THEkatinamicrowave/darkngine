package funkin.backend.system;

import flixel.FlxGame;

class FunkinGame extends FlxGame
{
	var skipNextTickUpdate:Bool = false;

	public override function switchState():Void
	{
		super.switchState();

		draw();
		_total = ticks = getTicks();

		skipNextTickUpdate = true;
	}

	public override function onEnterFrame(_)
	{
		if (skipNextTickUpdate != (skipNextTickUpdate = false))
			_total = ticks = getTicks();

		super.onEnterFrame(t);
	}
}