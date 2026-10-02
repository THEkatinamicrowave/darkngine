package funkin.menus.ui;

import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;

class MenuBG extends FlxGraphic
{
    public function new(color1:FlxColor, color2:FlxColor)
    {
        var bmp = generateBitmap(color1, color2);
        super("MenuBG_" + color1 + "_" + color2, bmp);
    }

	public static function makeSprite(color1:FlxColor, color2:FlxColor, funkin:Bool = false, x:Float = 0, y:Float = 0):FlxSprite
	{
		var spr = funkin ? new FunkinSprite(x, y) : new FlxSprite(x, y);
		spr.loadGraphic(new MenuBG(color1, color2));

		return spr;
	}

    private function generateBitmap(color1:FlxColor, color2:FlxColor):BitmapData
	{
        var src = BitmapData.fromImage(LimeAssets.getImage(Paths.image("menus/bg")));
        var out = src.clone();

        var tint1 = colToVec3(color1);
        var tint2 = colToVec3(color2);
        var transform = new ColorTransform(
            (tint1[0] - tint2[0]), (tint1[1] - tint2[1]), (tint1[2] - tint2[2]), 1,
            tint2[0] * 255, tint2[1] * 255, tint2[2] * 255, 0
        );
        out.colorTransform(out.rect, transform);

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