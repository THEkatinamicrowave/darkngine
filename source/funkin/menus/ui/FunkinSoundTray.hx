package funkin.menus.ui;

import flixel.system.ui.FlxSoundTray;
import lime.utils.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import funkin.backend.scripting.Script;
import funkin.backend.scripting.events.CancellableEvent;
import funkin.backend.scripting.events.soundtray.*;
import funkin.backend.utils.CoolUtil;

class FunkinSoundTray extends FlxSoundTray
{
	public var soundtrayScript:Script;
	public static var script:String = Flags.DEFAULT_SOUNDTRAY_SCRIPT;

	var targetY:Float = 0;
	var targetAlpha:Float = 0;
	var targetScale:Float = 0.30;

	public function new()
	{
		soundtrayScript = Script.create(Paths.script(script));
		soundtrayScript.setParent(this);
		soundtrayScript.load();

		soundtrayScript.call("create");

		super();
		removeChildren();

		var box:Bitmap = new Bitmap(BitmapData.fromImage(Assets.getImage(Paths.image('menus/soundtray/box'))));
		box.scaleX = targetScale;
		box.scaleY = targetScale;
		box.smoothing = true;

		y = -height;
		visible = false;

		var translucentBars:Bitmap = new Bitmap(BitmapData.fromImage(Assets.getImage(Paths.image('menus/soundtray/bar10'))));
		translucentBars.x = 9;
		translucentBars.y = 5;
		translucentBars.alpha = 0.4;
		translucentBars.scaleX = targetScale;
		translucentBars.scaleY = targetScale;
		translucentBars.smoothing = true;

		addChild(box);
		addChild(translucentBars);

		_bars = [];
		for (i in 0...10)
		{
			var bar:Bitmap = new Bitmap(BitmapData.fromImage(Assets.getImage(Paths.image('menus/soundtray/bar${i + 1}'))));
			bar.x = 9;
			bar.y = 5;
			bar.scaleX = targetScale;
			bar.scaleY = targetScale;
			bar.smoothing = true;
			
			addChild(bar);
			_bars.push(bar);
		}

		screenCenter();
		y = -height - 10;

		FlxSoundTray.volumeUpChangeSFX = Paths.sound('soundtray/increase');
		FlxSoundTray.volumeDownChangeSFX = Paths.sound('soundtray/decrease');
		FlxSoundTray.volumeMaxChangeSFX = Paths.sound('soundtray/max');
		
		soundtrayScript.call("postCreate");
	}

	override public function reloadDtf():Void
	{
		var event = new CancellableEvent();
		soundtrayScript.call("reloadDtf", [event]);
		if (event.cancelled) return;

		super.reloadDtf();
		soundtrayScript.call("postReloadDtf");
	}

	override public function regenerateBarsArray():Void
	{
		var event = new CancellableEvent();
		soundtrayScript.call("regenerateBarsArray", [event]);
		if (event.cancelled) return;

		super.regenerateBarsArray();
		soundtrayScript.call("postRegenerateBarsArray");
	}

	override public function regenerateBars():Void
	{
		var event = new CancellableEvent();
		soundtrayScript.call("regenerateBars", [event]);
		if (event.cancelled) return;

		super.regenerateBars();
		soundtrayScript.call("postRegenerateBars");
	}

	override public function update(ms:Float):Void
	{
		var elapsed:Float = ms / 1000;

		soundtrayScript.call("update", [elapsed]);

		var hasVolume:Bool = (!FlxG.sound.muted && FlxG.sound.volume > 0);
		if (hasVolume)
		{
			if (_timer > 0)
			{
				_timer -= elapsed;
				if (_timer <= 0)
				{
					targetY = -height - 10;
					targetAlpha = 0;
				}
			}
			else if (y <= -height)
				visible = active = false;
		}
		else if (!visible)
			showTray();

		screenCenter();
		y = CoolUtil.fpsLerp(y, targetY, 0.3);
		alpha = CoolUtil.fpsLerp(alpha, targetAlpha, 0.2);

		soundtrayScript.call("postUpdate", [elapsed]);
	}

	override public function saveSoundPreferences():Void
	{
		var event = new CancellableEvent();
		soundtrayScript.call("saveSoundPreferences", [event]);
		if (event.cancelled) return;

		super.saveSoundPreferences();
		soundtrayScript.call("postSaveSoundPreferences");
	}

	override public function show(up:Bool = false):Void
	{
		var event = EventManager.get(SoundTrayShowEvent).recycle(up);
		soundtrayScript.call("show", [event]);
		if (event.cancelled) return;

		moveTrayMakeVisible(up);
		saveSoundPreferences();

		soundtrayScript.call("postShow", [event]);
	}

	public function moveTrayMakeVisible(up:Bool = false):Void
	{
		showTray();

		if (!FlxSoundTray.silent)
		{
			var sound:Null<String> = (FlxG.sound.volume == 1) ? FlxSoundTray.volumeMaxChangeSFX : (up ? FlxSoundTray.volumeUpChangeSFX : FlxSoundTray.volumeDownChangeSFX);
			if (sound != null)
				FlxG.sound.play(sound);
		}
	}

	public function showTray():Void
	{
		soundtrayScript.call("onShowTray");

		_timer = 1;
		targetY = 10;
		targetAlpha = 1;

		visible = active = true;
		updateBars();
		
		soundtrayScript.call("onPostShowTray");
	}

	public function updateBars():Void
	{
		var globalVolume:Int = (FlxG.sound.muted || FlxG.sound.volume == 0) ? 0 : Math.round(FlxG.sound.volume * 10);

		for (i in 0..._bars.length)
			_bars[i].visible = (i < globalVolume);
	}

	override public function screenCenter():Void
	{
		var event = new CancellableEvent();
		soundtrayScript.call("screenCenter", [event]);
		if (event.cancelled) return;

		super.screenCenter();
		soundtrayScript.call("postScreenCenter");
	}

	private override function __cleanup():Void
	{
		soundtrayScript.call("destroy");
		soundtrayScript.destroy();
		super.__cleanup();
	}
}
