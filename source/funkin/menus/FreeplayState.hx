package funkin.menus;

import haxe.xml.Access;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.chart.Chart;
import funkin.backend.chart.ChartData.ChartMetaData;
import funkin.backend.scripting.events.menu.MenuChangeEvent;
import funkin.backend.scripting.events.menu.freeplay.*;
import funkin.backend.system.Conductor;
import funkin.game.HealthIcon;
import funkin.savedata.FunkinSave;

using StringTools;

class FreeplayState extends MusicBeatState
{
	/**
	 * Array containing all of the songs' metadata.
	 */
	public var songs:Array<ChartMetaData> = [];

	/**
	 * Current song metadata
	 */
	public var curSong:Null<ChartMetaData>;

	/**
	 * Current song difficulties
	 */
	public var curDifficulties:Array<String>;

	/**
	 * songs[curSelected].metas.get(curDiffMetaIndices[curDifficulty])
	 */
	public var curDiffMetaKeys:Array<String> = [];

	/**
	 * Currently selected song
	 */
	public var curSelected:Int = 0;
	/**
	 * Currently selected difficulty
	 */
	public var curDifficulty:Int = 1;
	/**
	 * Currently selected coop/opponent mode
	 */
	public var curCoopMode:Int = 0;

	/**
	 * Text containing the score info (PERSONAL BEST: 0)
	 */
	public var scoreText:FlxText;

	/**
	 * Text containing the current difficulty (< HARD >)
	 */
	public var diffText:FlxText;

	/**
	 * Text containing the current coop/opponent mode ([KEYBINDS] Co-Op mode)
	 */
	public var coopText:FlxText;

	/**
	 * Currently lerped score. Is updated to go towards `intendedScore`.
	 */
	public var lerpScore:Float = 0;
	/**
	 * Destination for the currently lerped score.
	 */
	public var intendedScore:Int = 0;

	/**
	 * Assigned FreeplaySonglist item.
	 */
	public var songList:FreeplaySonglist;
	/**
	 * Black background around the score, the difficulty text and the co-op text.
	 */
	public var scoreBG:FlxSprite;

	/**
	 * Background.
	 */
	public var bg:FlxSprite;

	/**
	 * Whenever the player can navigate and select
	 */
	public var canSelect:Bool = true;

	/**
	 * Group containing all of the alphabets
	 */
	public var grpSongs:FlxTypedGroup<Alphabet>;

	/**
	 * Whenever the currently selected song is playing.
	 */
	public var curPlaying:Bool = false;

	/**
	 * Array containing all of the icons.
	 */
	public var iconArray:Array<HealthIcon> = [];

	/**
	 * FlxInterpolateColor object for smooth transition between Freeplay colors.
	 */
	public var interpColor:FlxInterpolateColor;


	override function create()
	{
		CoolUtil.playMenuSong();
		songList = FreeplaySonglist.get();
		songs = songList.songs;

		for(k=>s in songs) {
			if (s.name == Options.freeplayLastSong) {
				curSelected = k;
			}
		}

		updateCurDifficulties();
		for(i=>diff in curDifficulties) {
			if (curDiffMetaKeys[i] == Options.freeplayLastVariation && diff == Options.freeplayLastDifficulty)
				curDifficulty = i;
		}

		updateCurSong();

		DiscordUtil.call("onMenuLoaded", ["Freeplay"]);

		super.create();

		// LOAD CHARACTERS

		bg = new FlxSprite(0, 0).loadAnimatedGraphic(Paths.image('menus/menuDesat'));
		if (songs.length > 0)
			bg.color = songs[0].color;
		bg.antialiasing = true;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].displayName, "bold");
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].icon);
			icon.sprTracker = songText;
			if (Math.max(icon.width, icon.height) > 150) icon.setUnstretchedGraphicSize(150, 150);

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DON'T PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 1, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		coopText = new FlxText(diffText.x, diffText.y + diffText.height + 2, 0, "", 24);
		coopText.font = scoreText.font;
		add(coopText);

		add(scoreText);

		changeSelection(0, true);
		changeCoopMode(0, true);

		interpColor = new FlxInterpolateColor(bg.color);
	}

	private var TEXT_FREEPLAY_SCORE = TU.getRaw("freeplay.score");

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

		lerpScore = lerp(lerpScore, intendedScore, 0.4);

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		if (canSelect) {
			changeSelection((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0) - FlxG.mouse.wheel);
			changeDiff((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
			changeCoopMode((controls.CHANGE_MODE ? 1 : 0)); // TODO: make this configurable
			// putting it before so that its actually smooth

			if (FlxG.mouse.justPressed && grpSongs != null) {
				for (index => sprite in grpSongs.members) {
					if (curSelected != index && FlxG.mouse.overlaps(sprite)) {
						changeSelection(index - curSelected);
						break;
					}
				}
			}

			updateOptionsAlpha();
		}

		scoreText.text = TEXT_FREEPLAY_SCORE.format([Math.round(lerpScore)]);
		scoreBG.scale.set(MathUtil.maxSmart(diffText.width, scoreText.width, coopText.width) + 8, (coopText.visible ? coopText.y + coopText.height : 66));
		scoreBG.updateHitbox();
		scoreBG.x = FlxG.width - scoreBG.width;

		scoreText.x = coopText.x = scoreBG.x + 4;
		diffText.x = Std.int(scoreBG.x + ((scoreBG.width - diffText.width) / 2));

		interpColor.fpsLerpTo(curSong.color, 0.0625);
		bg.color = interpColor.color;

		if (controls.BACK || FlxG.mouse.justPressedRight)
		{
			CoolUtil.playMenuSFX(CANCEL, 0.7);
			FlxG.switchState(new MainMenuState());
		}

		#if sys
		if (FlxG.keys.justPressed.EIGHT && Sys.args().contains("-livereload"))
			convertChart();
		#end

		if ((controls.ACCEPT || (FlxG.mouse.justPressed && grpSongs?.members[curSelected] != null
			&& FlxG.mouse.overlaps(grpSongs.members[curSelected]))))
		{
			select();
		}
	}

	var __opponentMode:Bool = false;
	var __coopMode:Bool = false;

	function updateCoopModes() {
		__opponentMode = false;
		__coopMode = false;
		if (curSong.coopAllowed && curSong.opponentModeAllowed) {
			__opponentMode = curCoopMode % 2 == 1;
			__coopMode = curCoopMode >= 2;
		} else if (curSong.coopAllowed) {
			__coopMode = curCoopMode == 1;
		} else if (curSong.opponentModeAllowed) {
			__opponentMode = curCoopMode == 1;
		}
	}

	/**
	 * Selects the current song.
	 */
	public function select() {
		updateCoopModes();

		if (curDifficulties.length == 0) return;

		var event = event("onSelect", EventManager.get(FreeplaySongSelectEvent).recycle(curSong.name, curDifficulties[curDifficulty], curSong.variant, __opponentMode, __coopMode));

		if (event.cancelled) return;

		Options.freeplayLastSong = curSong.name;
		Options.freeplayLastDifficulty = curDifficulties[curDifficulty];
		Options.freeplayLastVariation = curSong.variant;

		PlayState.loadSong(event.song, event.difficulty, event.variant, event.opponentMode, event.coopMode);
		FlxG.switchState(new PlayState());
	}

	public function convertChart() {
		trace('Converting ${curSong.name} ${curDifficulties[curDifficulty]} ${curSong.variant} to Codename format...');
		var chart = Chart.parse(curSong.name, curDifficulties[curDifficulty], curSong.variant);
		Chart.save(chart, curDifficulties[curDifficulty], curSong.variant);
	}

	/**
	 * Changes the current difficulty
	 * @param change How much to change.
	 * @param force Force the change if `change` is equal to 0
	 */
	public function changeDiff(change:Int = 0, force:Bool = false) {
		if (change == 0 && !force) return;

		var validDifficulties = curDifficulties.length > 0;
		var event = event("onChangeDiff", EventManager.get(MenuChangeEvent).recycle(curDifficulty, validDifficulties ? FlxMath.wrap(curDifficulty + change, 0, curDifficulties.length-1) : 0, change));

		if (event.cancelled) {
			if (force) updateCurSong();
			return;
		}

		var prevSong = curSong;
		curDifficulty = event.value;
		updateCurSong();
		updateScore();

		var text = validDifficulties ? curDifficulties[curDifficulty].toUpperCase() + (curSong != songs[curSelected] ? ' (${curSong.variant.toUpperCase()})' : '') : '-';
		diffText.text = curDifficulties.length > 1 ? '< $text >' : text;
	}

	function updateScore() {
		if (curDifficulties.length == 0) {
			intendedScore = 0;
			return;
		}
		updateCoopModes();
		var changes:Array<HighscoreChange> = [];
		if (__coopMode) changes.push(CCoopMode);
		if (__opponentMode) changes.push(COpponentMode);
		var saveData = FunkinSave.getSongHighscore(curSong.name, curDifficulties[curDifficulty], curSong.variant, changes);
		intendedScore = saveData.score;
	}

	/**
	 * Array containing all labels for Co-Op / Opponent modes.
	 */
	public var coopLabels:Array<String> = [
		TU.translate("freeplay.solo"),
		TU.translate("freeplay.opponentMode"),
		TU.translate("freeplay.coopMode"),
		TU.translate("freeplay.coopModeSwitched")
	];

	/**
	 * Change the current coop mode context.
	 * @param change How much to change
	 * @param force Force the change, even if `change` is equal to 0.
	 */
	public function changeCoopMode(change:Int = 0, force:Bool = false) {
		if (change == 0 && !force) return;
		if (!curSong.coopAllowed && !curSong.opponentModeAllowed) return;

		var bothEnabled = curSong.coopAllowed && curSong.opponentModeAllowed;
		var event = event("onChangeCoopMode", EventManager.get(MenuChangeEvent).recycle(curCoopMode, FlxMath.wrap(curCoopMode + change, 0, bothEnabled ? 3 : 1), change));

		if (event.cancelled) return;

		curCoopMode = event.value;

		updateScore();

		var coopBinds = [CoolUtil.keyToString(Options.P1_CHANGE_MODE[0]), CoolUtil.keyToString(Options.P2_CHANGE_MODE[0])].filter(x -> x != "---");
		if (coopBinds.length == 2 && coopBinds[1] == coopBinds[0]) coopBinds.pop();
		else if (coopBinds.length == 0) coopBinds.push("---");

		var key = '[${coopBinds.join(" / ")}] ';

		if (bothEnabled) {
			coopText.text = key + coopLabels[curCoopMode];
		} else {
			coopText.text = key + coopLabels[curCoopMode * (curSong.coopAllowed ? 2 : 1)];
		}
	}

	/**
	 * Change the current selection.
	 * @param change How much to change
	 * @param force Force the change, even if `change` is equal to 0.
	 */
	public function changeSelection(change:Int = 0, force:Bool = false) {
		if (change == 0 && !force) return;

		var event = event("onChangeSelection", EventManager.get(MenuChangeEvent).recycle(curSelected, FlxMath.wrap(curSelected + change, 0, songs.length-1), change));
		if (event.cancelled) return;

		curSelected = event.value;
		if (event.playMenuSFX) CoolUtil.playMenuSFX(SCROLL, 0.7);

		var prevDiff = curDifficulties[curDifficulty], prevVariant = curDiffMetaKeys[curDifficulty];
		updateCurDifficulties();

		for (i => diff in curDifficulties) if (diff == prevDiff && curDiffMetaKeys[i] == prevVariant) {
			curDifficulty = i;
			break;
		}

		changeDiff(0, true);

		coopText.visible = curSong.coopAllowed || curSong.opponentModeAllowed;
	}

	function updateOptionsAlpha() {
		var event = event("onUpdateOptionsAlpha", EventManager.get(FreeplayAlphaUpdateEvent).recycle(0.6, 0.45, 1, 1, 0.25));
		if (event.cancelled) return;

		final idleAlpha = event.idleAlpha;
		final selectedAlpha = event.selectedAlpha;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = lerp(iconArray[i].alpha, idleAlpha, event.lerp);

		iconArray[curSelected].alpha = selectedAlpha;

		for (i=>item in grpSongs.members)
		{
			item.targetY = i - curSelected;

			item.alpha = lerp(item.alpha, idleAlpha, event.lerp);

			if (item.targetY == 0)
				item.alpha = selectedAlpha;
		}
	}

	function updateCurDifficulties() {
		curDiffMetaKeys.resize(0);
		curDifficulties = songs[curSelected].difficulties.copy();
		for (i in 0...curDifficulties.length) curDiffMetaKeys.push(null);
		
		if (songs[curSelected].variants != null) {
			var meta:ChartMetaData;
			for (variant in songs[curSelected].variants) if ((meta = songs[curSelected].metas.get(variant)) != null) {
				curDifficulties = curDifficulties.concat(meta.difficulties);
				for (i in 0...meta.difficulties.length) curDiffMetaKeys.push(variant);
			}
		}
	}

	function updateCurSong() {
		var song = songs[curSelected];
		if (song == null) curSong = null;
		else if ((curSong = song.metas.get(curDiffMetaKeys[curDifficulty])) == null)
			curSong = song;
	}
}

class FreeplaySonglist {
	public var songs:Array<ChartMetaData> = [];
	public static final EXCLUDE_SUBFOLDERS:Array<String> = ['charts', 'scripts', 'song'];

	public function new() {}

	public static function isSubSongDirectory(subs:Array<String>):Bool {
		for (i in EXCLUDE_SUBFOLDERS) {
			if (subs.contains(i)) return false;
		}
		return true;
	}

	public function getSongsFromSource(source:funkin.backend.assets.AssetSource, useTxt:Bool = true, unlockAll:Bool = false, ?startDir:String = 'songs/', ?flatten:Bool = true) {
        var xmlPath = Paths.xml("config/freeplaySonglist");
        var txtPath = Paths.txt("config/freeplaySonglist");
        var legacyTxtPath = Paths.txt("freeplaySonglist");

		var songsFound:Array<String> = null;

        if (Paths.assetsTree.existsSpecific(xmlPath, "TEXT", source)) {
			var xml:Access = new Access(Xml.parse(Assets.getText(xmlPath)).firstElement());
            if (xml != null) {
                loadFromXML(xml, source, unlockAll);
                return false;
            }
        }

		if (useTxt) {
			if (Paths.assetsTree.existsSpecific(txtPath, "TEXT", source)) songsFound = CoolUtil.coolTextFile(txtPath);
			else if (Paths.assetsTree.existsSpecific(legacyTxtPath, "TEXT", source)) {
				Logs.warn("data/freeplaySonglist.txt is deprecated and will be removed in the future. Please move the file to data/config/", DARKYELLOW, "FreeplaySonglist");
				songsFound = CoolUtil.coolTextFile(legacyTxtPath);
			}
		}

		// todo: make this better
		if (songsFound == null) {
			songsFound = [];
			var songDirs = Paths.getFolderDirectories(startDir, false, source);
			if (!flatten) {
				for (i in songDirs) {
					var subs = Paths.getFolderDirectories('$startDir$i', false, source);
					songsFound.push(isSubSongDirectory(subs) ? '$i/' : i);
				}
			} else {
				function poop(a:Array<Dynamic>, startDir:String) {
					for (i in a) {
						var subs = Paths.getFolderDirectories('$startDir$i', false, source);
						if (isSubSongDirectory(subs)) poop(subs, '$startDir$i/');
						else songsFound.push(startDir.substr('songs/'.length) + i);
					}
				}
				poop(songDirs, startDir);
			}
			// put folders at the top
			songsFound = songsFound.filter(a -> a.endsWith('/'))
				.concat(songsFound.filter(a -> !a.endsWith('/')));
		}
		if (songsFound.length > 0) {
			for (s in songsFound) songs.push(Chart.loadChartMeta(startDir.substr('songs/'.length) + s, source == MODS));
			return false;
		}
		return true;
	}

    private function loadFromXML(xml:Access, source:AssetSource, unlockAll:Bool = false) {
		var songList:Array<ChartMetaData> = [];

		var evaluate = function(target:String, value:String):Bool {
			switch (target) {
				case "Week":
					var week = Week.loadWeek(value, false);
					if (week == null) {
						Logs.trace('Could not load week "$value"; is this spelled correctly?', ERROR);
						return true;
					}
					var highscores = [
						for (diff in week.difficulties)
							FunkinSave.getWeekHighscore(value, diff).score
					];
					return Lambda.exists(highscores, score -> score > 0);

				case "Song":
					var song = Chart.loadChartMeta(value);
					if (song == null) {
						Logs.trace('Could not load song "$value"; is this spelled correctly?', ERROR);
						return true;
					}
					var highscores = [
						for (diff in song.difficulties)
							FunkinSave.getSongHighscore(value, diff).score
					];
					return Lambda.exists(highscores, score -> score > 0);

				case "Save":
					var savedata = Reflect.field(FlxG.save.data, value);
					if (savedata == null) {
						Logs.trace('Invalid savedata "$value": null', ERROR);
						return true;
					}
					if (!Std.isOfType(savedata, Bool)) {
						Logs.trace('Invalid savedata "$value": only Bool supported', WARNING);
						return true;
					}
					return savedata;

				default:
					return true;
			}
		}

		var checkConditions = function(element:Access):Bool {
			for (att in cast(element, Xml).attributes()) {
				var name = att;
				var value = element.getAtt(name).trim();

				var isIf = name.startsWith("if");
				var isUnless = name.startsWith("unless");
				if (!isIf && !isUnless) continue;

				var target = name.substr(isIf ? 2 : 6);
				var result = evaluate(target, value);

				if (isIf && !result) return false;
				if (isUnless && result) return false;
			}

			return true;
		};

		var attemptAddSong = function(songName:String) {
			if (songName == null || songName == "") return;

			var chartMeta = Chart.loadChartMeta(songName, null, null, source == MODS);
			if (chartMeta == null) {
				Logs.trace('Song loading for "$songName" failed', ERROR);
			} else
				songList.push(chartMeta);
		}

		for (data in xml.elements) {
			var nodeName:String = data.name.toLowerCase();
			switch (nodeName) {
				case "song":
					if (checkConditions(data) || unlockAll) attemptAddSong(data.getAtt('name').trim());

				case "week":
					var weekName = data.getAtt('name').trim();
					var week:WeekData = Week.loadWeek(weekName, false);
					if (week == null) continue;

					var exclusions:Map<String, Access> = [];

					if (!unlockAll)
						for (child in data.elements) {
							if (child.name == "exclude") {
								var songName = child.getAtt("name").trim();
								exclusions.set(songName, child);
							}
						}

					for (song in week.songs) {
						var songName:String = song.name.toLowerCase();
						
						if (exclusions.exists(songName)) {
							var excludeNode = exclusions.get(songName);

							if (checkConditions(excludeNode)) continue;
						}

						if (checkConditions(data) || unlockAll)
							attemptAddSong(song.name);
					}

				default: continue;
			}
		}

		songs = songList;
    }

	public static function get(useTxt:Bool = true, ?startDir:String = 'songs/', ?flatten:Bool = true) {
		var songList = new FreeplaySonglist();

		switch(Flags.SONGS_LIST_MOD_MODE) {
			case 'prepend':
				songList.getSongsFromSource(MODS, useTxt, startDir, flatten);
				songList.getSongsFromSource(SOURCE, useTxt, startDir, flatten);
			case 'append':
				songList.getSongsFromSource(SOURCE, useTxt, startDir, flatten);
				songList.getSongsFromSource(MODS, useTxt, startDir, flatten);
			default /*case 'override'*/:
				if (songList.getSongsFromSource(MODS, useTxt, startDir, flatten))
					songList.getSongsFromSource(SOURCE, useTxt, startDir, flatten);
		}

		return songList;
	}
}
