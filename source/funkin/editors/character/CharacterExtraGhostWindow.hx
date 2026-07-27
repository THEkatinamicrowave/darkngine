package funkin.editors.character;

import funkin.backend.system.Flags;
import funkin.editors.ui.UIWindow;
import funkin.game.Character;
import funkin.game.Stage;

class CharacterExtraGhostWindow extends UISliceSprite
{
	static public var objsHeight:Int = /* actual objects */ 32 + 12 + /* text labels */ 32 + 4 + 32 + 4 + /* padding */ 16 + 16; 

	public var extraGhost:Character = null;

	public var ghostNameBox:UITextBox;
	public var alphaSlider:UISlider;

	public var labels:Map<UISprite, UIText> = [];

	inline function translate(id:String, ?args:Array<Dynamic>)
		return TU.translate("characterEditor.ghostStuff." + id, args);

	public function new(x:Float, y:Float, extraGhost:Character) @:privateAccess {
		super(x, y, 200 + 32, objsHeight, "editors/ui/inputbox");

		function addLabel(obj:UISprite, text:String = "???") {
			var textObj:UIText = new UIText(obj.x, obj.y - 24, 0, text);
			members.push(textObj);
			
			labels.set(obj, textObj);
		}

		ghostNameBox = new UITextBox(x + 16, y + 16 + 24, "", 200);
		ghostNameBox.onChange = (text:String) -> {
			this.changeExtraGhost(text);
		};
		members.push(ghostNameBox);

		alphaSlider = new UISlider(x + 16, ghostNameBox.y + 32 + 32 + 4, 200, Flags.DEFAULT_CHARACTER_EXTRAGHOST_ALPHA, [{start: 0, end: 1, size: 1}], false);
		alphaSlider.onFinishChange = (value:Float) -> {
			this.changeGhostAlpha(value);
		}
		members.push(alphaSlider);
		alphaSlider.members.remove(alphaSlider.valueStepper);
		alphaSlider.members.remove(alphaSlider.startText);
		alphaSlider.members.remove(alphaSlider.endText);

		addLabel(ghostNameBox, 'Ghost Character');
		addLabel(alphaSlider, 'Ghost Alpha');

		alpha = Flags.DEFAULT_CHARACTER_EXTRAGHOST_ALPHA;
		this.extraGhost = extraGhost;
	}

	public function changeExtraGhost(ghostName:String):Void
	{
		var cInstance:CharacterEditor = CharacterEditor.instance;
		if (cInstance == null) return;

		var character:CharacterGhost = cInstance.character;
		var stage:Stage = cInstance.stage;
		var stagePosition:String = cInstance.stagePosition;

		if (extraGhost != null) {
			cInstance.remove(extraGhost);
			extraGhost.destroy();
			extraGhost = null;
		}

		if (ghostName == null || ghostName.trim() == "") return;

		var ghostPath = Paths.xml('characters/$ghostName');
		if (!Assets.exists(ghostPath)) {
			trace('Ghost character "$ghostName" does not exist.');
			return;
		}

		extraGhost = new Character(0, 0, ghostName, character.isPlayer, false);
		extraGhost.alpha = alphaSlider.value;
		extraGhost.debugMode = true;
		extraGhost.camera = cInstance.charCamera;
		extraGhost.playAnim(extraGhost.getAnimOrder()[0], true);
		cInstance.add(extraGhost);

		if (stage != null && stage.characterPoses.exists(stagePosition))
			stage.applyCharStuff(extraGhost, stagePosition, 0);

		trace('Ghost character "$ghostName" loaded.');
	}

	public function changeGhostAlpha(value:Float):Void
	{
		if (extraGhost == null) {
			trace('Ghost is null; cannot change alpha.');
			return;
		}
		if (value == extraGhost.alpha) return;

		extraGhost.alpha = alphaSlider.value = value;
		trace('Ghost character alpha set to $value.');
	}
}