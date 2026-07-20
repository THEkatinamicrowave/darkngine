package funkin.menus.ui.effects;

import flixel.util.FlxColor;
import flixel.util.helpers.FlxRange;
import funkin.menus.ui.effects.RegionEffect;

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

		if (borderColor != 0xFF000000) trace('MarkupEffects do not yet support borderColors for Alphabet');
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
		for (r in getMarkRanges(renderData.parent.text)) {
			if (index >= r.start && index <= r.end)
				return (true && super.willModify(index, lineIndex, renderData));
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
