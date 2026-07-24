//
import flixel.math.FlxAngle;
import flixel.addons.display.FlxTiledSprite;

var clouds:FlxTiledSprite;

var tankMoving:Bool = false;
var tankAngle:Float = FlxG.random.int(-90, 45);
var tankSpeed:Float = FlxG.random.float(5, 7);
var tankX:Float = 400;

function postCreate() {
	clouds = new FlxTiledSprite(Paths.image('stages/tank/tankClouds'), 3200, 235, true, false);
	clouds.setPosition(-1100, 20);
	clouds.scrollFactor.set(0.25, 0.25);
	clouds.velocity.x = 8;
	insert(members.indexOf(buildings), clouds);

	tankAngle = FlxG.random.int(-90, 45);
	tankSpeed = FlxG.random.float(5, 7);

	moveTank(0);

	if (PlayState.isStoryMode)
		GameOverSubstate.script = 'data/scripts/week7-balledLines';
}

function postUpdate(elapsed:Float) {
	moveTank(elapsed);
}

function moveTank(elapsed:Float) {
	var daAngleOffset:Float = 1;
	tankAngle += elapsed * tankSpeed;

	tankRolling.angle = tankAngle - 90 + 15;
	tankRolling.x = tankX + Math.cos(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1500;
	tankRolling.y = 1300 + Math.sin(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1100;
}
