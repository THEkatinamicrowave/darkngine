package funkin.menus.ui;

import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.typeLimit.OneOfTwo;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import lime.utils.Assets;

class MenuBG extends FlxGraphic
{
    public function new(color1:FlxColor, color2:FlxColor)
    {
        var bmp = generateBitmap(color1, color2);
        super("MenuBG_" + color1 + "_" + color2, bmp);
    }

	public static function makeSprite(color1:FlxColor, color2:FlxColor, funkin:Bool = false, x:Float = 0, y:Float = 0):OneOfTwo<FlxSprite, FunkinSprite>
	{
		var spr = funkin ? new FunkinSprite(x, y) : new FlxSprite(x, y);
		spr.loadGraphic(new MenuBG(color1, color2));

		return spr;
	}

    private function generateBitmap(color1:FlxColor, color2:FlxColor):BitmapData
	{
		function getMergedChannel(shift:Int, mixAmount:Float):Int
		{
			var c1 = (color1 >> shift) & 0xFF;
			var c2 = (color2 >> shift) & 0xFF;
			return Std.int(c2 + (c1 - c2) * mixAmount);
		}

		var src = BitmapData.fromImage(Assets.getImage(Paths.image("menus/bg")));
		var w = src.width;
		var h = src.height;

		var out = new BitmapData(w, h, true, 0x00000000);

		for (y in 0...h) for (x in 0...w)
		{
			var px = src.getPixel32(x, y);
			var brightness = (px & 0xFF) / 255; // it's black and white; we don't need rgba shit

			var alpha = getMergedChannel(24, brightness);
			var red = getMergedChannel(16, brightness);
			var green = getMergedChannel(8, brightness);
			var blue = getMergedChannel(0, brightness);

			out.setPixel32(x, y, (alpha << 24) | (red << 16) | (green << 8) | blue);
		}

		return out;
	}
}

enum abstract MenuBGColorPresets(FlxColor) from FlxColor to FlxColor
{
    var DEFAULT_ONE = 0xFFFDE871;
	var DEFAULT_TWO = 0xFFDB7627;
    var BLUE_ONE = 0xFF9271FD;
    var BLUE_TWO = 0xFF2747DB;
    var PINK_ONE = 0xFFFD719B;
    var PINK_TWO = 0xFFDB27A7;
    var MONO_ONE = 0xFFFFFFFF;
    var MONO_TWO = 0xFF000000;
    var DESAT_ONE = 0xFFE1E1E1;
    var DESAT_TWO = 0xFF8B8B8B;
    var EDITORS_ONE = 0xFF0D0D0D;
    var EDITORS_TWO = 0xFF303030;
	var TRANSPARENT_ONE = 0x00000000;
	var TRANSPARENT_TWO = 0xFFFFFFFF;
}