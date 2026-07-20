package funkin.menus.ui.effects;

import flixel.util.FlxColor;
import flixel.util.helpers.FlxRange;

class AlphabetRenderData { 
	public var parent:Alphabet;
	public var letter:String;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var color(get, set):FlxColor;
	public var red:Float = 0;
	public var green:Float = 0;
	public var blue:Float = 0;
	public var alpha:Float = 1;

	public function new(parent:Alphabet) {
		this.parent = parent;
	}

	public function reset(parent:Alphabet, red:Float, green:Float, blue:Float, alpha:Float, letter:String) {
		this.parent = parent;
		this.letter = letter;
		this.offsetX = 0;
		this.offsetY = 0;
		this.red = red;
		this.green = green;
		this.blue = blue;
		this.alpha = alpha;
	}

	function get_color():FlxColor {
		return FlxColor.fromRGBFloat(red, green, blue);
	}
	function set_color(value:FlxColor):FlxColor {
		red = value.redFloat;
		green = value.greenFloat;
		blue = value.blueFloat;
		return value;
	}
}

class RegionEffect {
	public var effectTime:Float = 0;
	public var speed:Float = 1;
	public var enabled:Bool = true;
	public var regionMin:Array<Int> = [];
	public var regionMax:Array<Int> = [];

	public function new() {}

	public function resetRegions() {
		regionMin.splice(0, regionMin.length);
		regionMax.splice(0, regionMax.length);
	}

	public function addRegion(min:Int, max:Int) {
		regionMin.push(min);
		regionMax.push(max);
	}

	public function willModify(index:Int, lineIndex:Int, renderData:AlphabetRenderData):Bool {
		if (!enabled) return false;

		if (regionMin.length == 0) regionMin.push(0);
		if (regionMax.length == 0) regionMax.push(-1);

		for (i in 0...Std.int(Math.min(regionMin.length, regionMax.length))) {
			var min = (regionMin[i] < 0) ? renderData.parent.text.length - regionMin[i] : regionMin[i];
			var max = (regionMax[i] < 0) ? renderData.parent.text.length - regionMax[i] : regionMax[i];
			if (index >= min && index <= max)
				return true;
		}
		return false;
	}

	public function modify(index:Int, lineIndex:Int, renderData:AlphabetRenderData):Void {}
}

class MarkupEffect extends RegionEffect
{
	public var char:UnicodeString;
    public var color:FlxColor;
    public var borderColor:FlxColor;

    public function new(char:UnicodeString, color:FlxColor = 0xFFFFFFFF, borderColor:FlxColor = 0xFF000000)
	{
        super();

		this.char = char;
        this.color = color;
        this.borderColor = borderColor;
    }

	public function getMarkRanges(text:String):Array<FlxRange<Int>>
	{
		var ranges:Array<FlxRange<Int>> = [];
		var first:Int = -1;

		for (i in 0...text.length) {
			if (text.charAt(i) == char) {
				if (first == -1) {
					first = i;
				} else {
					var second = i;
					ranges.push(new FlxRange<Int>(first, second));
					first = -1;
				}
			}
		}

		return ranges;
	}

	override public function willModify(index:Int, lineIndex:Int, renderData:AlphabetRenderData):Bool
	{
		if (!enabled) return false;

		for (r in getMarkRanges(renderData.parent.text)) {
			if (index >= r.start && index <= r.end)
				return true;
		}

		return false;
	}

	override public function modify(index:Int, lineIndex:Int, renderData:AlphabetRenderData):Void
	{
		if (renderData.letter == char) {
			renderData.letter = "字";
			return;
		}

		for (r in getMarkRanges(renderData.parent.text)) {
			if (index >= r.start && index <= r.end) {
				renderData.red   = color.redFloat;
				renderData.green = color.greenFloat;
				renderData.blue  = color.blueFloat;
				renderData.alpha = color.alphaFloat;
				break;
			}
		}
	}
}
