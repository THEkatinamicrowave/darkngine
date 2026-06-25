package flixel.system;

import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.tile.FlxGraphicsShader;
import openfl.display.BitmapData;
import openfl.filters.ShaderFilter;
import openfl.geom.Point;

/**
 * A map-like group of any number of FlxShaders; acts like a Map<String, FlxShader>.
 * Also extends FlxGraphicsShader so it can be used like a normal shader.
 */
class FlxMultiShader extends FlxGraphicsShader
{
    private var _shaderMap:Map<String, FlxShader> = [];

    public function new()
    {
        super();
    }

    public inline function set(key:String, shader:FlxShader):FlxShader
    {
        _shaderMap.set(key, shader);
        return shader;
    }

    public inline function get(key:String):FlxShader
    {
        return _shaderMap.get(key);
    }

    public inline function exists(key:String):Bool
    {
        return _shaderMap.exists(key);
    }

    public inline function remove(key:String):Bool
    {
        return _shaderMap.remove(key);
    }

    public inline function keys():Iterator<String>
    {
        return _shaderMap.keys();
    }

    public inline function iterator():Iterator<FlxShader>
    {
        return _shaderMap.iterator();
    }

    public inline function toArray():Array<FlxShader>
    {
        return [for (s in _shaderMap) s];
    }

    public inline function clear():Void
    {
        _shaderMap = [];
    }

    // chaining the shader shit before draw().
    override public function update():Void
    {
        super.update();

        for (shader in _shaderMap)
        {
            if (shader is FlxGraphicsShader)
            {
                var shaderCast:FlxGraphicsShader = cast shader;
                shaderCast.data.camSize.value = this.data.camSize.value;
            }
        }
    }

	public function renderAll(src:BitmapData):BitmapData
	{
		var bmp:BitmapData = src;

		for (shader in _shaderMap)
			bmp = renderOneShader(bmp, shader);

		return bmp;
	}

	public function renderOneShader(src:BitmapData, shader:FlxShader):BitmapData
	{
		var outBitmap:BitmapData = new BitmapData(src.width, src.height, true, 0x00000000);
		var sFilter:ShaderFilter = new ShaderFilter(shader);
		outBitmap.applyFilter(src, src.rect, new Point(), sFilter);

		return outBitmap;
	}
}
