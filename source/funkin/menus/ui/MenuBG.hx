package funkin.menus.ui;

import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.Assets;

class MenuBG extends FlxGraphic
{
    public function new(color1:FlxColor, color2:FlxColor)
    {
        var bmp = generateBitmap(color1, color2);
        super("MenuBG_" + color1 + "_" + color2, bmp);
    }

	public static function makeSprite(color1:FlxColor, color2:FlxColor, funkin:Bool = false, x:Float = 0, y:Float = 0):FlxSprite
	{
		var spr:FlxSprite = funkin ? new FunkinSprite(x, y) : new FlxSprite(x, y);
		spr.loadGraphic(new MenuBG(color1, color2));

		return spr;
	}

    private function generateBitmap(color1:FlxColor, color2:FlxColor):BitmapData
	{
		var src = Assets.getBitmapData(Paths.image("menus/menuBG-outline"));
		var w = src.width;
		var h = src.height;

		var out = new BitmapData(w, h, true, 0x00000000);

		for (y in 0...h) for (x in 0...w)
		{
			var px = src.getPixel32(x, y);

			var r = (px >> 16) & 0xFF;
			var g = (px >> 8) & 0xFF;
			var b = px & 0xFF;

			var brightness = (r + g + b) / (3 * 255);

			var r1 = (color1 >> 16) & 0xFF;
			var g1 = (color1 >> 8) & 0xFF;
			var b1 = color1 & 0xFF;

			var r2 = (color2 >> 16) & 0xFF;
			var g2 = (color2 >> 8) & 0xFF;
			var b2 = color2 & 0xFF;

			var rf = Std.int(r1 + (r2 - r1) * brightness);
			var gf = Std.int(g1 + (g2 - g1) * brightness);
			var bf = Std.int(b1 + (b2 - b1) * brightness);

			out.setPixel32(x, y, 0xFF000000 | (rf << 16) | (gf << 8) | bf);
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