package funkin.menus.ui;

import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.typeLimit.OneOfTwo;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;

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
        var src = BitmapData.fromImage(LimeAssets.getImage(Paths.image("menus/bg")));
        var out = src.clone();

		var red1:Float = color1.redFloat, green1:Float = color1.greenFloat, blue1:Float = color1.blueFloat, alpha1:Float = color1.alphaFloat;
		var red2:Float = color2.redFloat, green2:Float = color2.greenFloat, blue2:Float = color2.blueFloat, alpha2:Float = color2.alphaFloat;

        var transform = new ColorTransform(
            red1 - red2, green1 - green2, blue1 - blue2, alpha1 - alpha2,
            red2 * 255, green2 * 255, blue2 * 255, alpha2 * 255
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
