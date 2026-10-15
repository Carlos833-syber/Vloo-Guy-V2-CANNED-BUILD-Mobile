package backend;

#if android
import flixel.FlxG;
import haxe.ds.IntMap;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;
import states.PlayState;

/** Android overlay: send the same key events used by menus and note judgement. */
class MobileControls extends Sprite
{
	static var instance:MobileControls;

	final targetStage:Stage;
	final buttons:Array<Sprite> = [];
	final bounds:Array<Rectangle> = [];
	final actions:Array<String> = ['left', 'down', 'up', 'right', 'back', 'pause', 'accept'];
	final labels:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'BACK', 'PAUSE', 'OK'];
	final touches:IntMap<Int> = new IntMap<Int>();
	final touchKeys:IntMap<Int> = new IntMap<Int>();
	final keyHolds:IntMap<Int> = new IntMap<Int>();

	public static function install():Void
	{
		if (instance == null)
		{
			instance = new MobileControls(FlxG.stage);
			FlxG.stage.addChild(instance);
		}
	}

	function new(targetStage:Stage)
	{
		super();
		this.targetStage = targetStage;
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		for (label in labels)
		{
			var button = new Sprite();
			var text = new TextField();
			text.text = label;
			text.selectable = false;
			text.mouseEnabled = false;
			button.addChild(text);
			buttons.push(button);
			bounds.push(new Rectangle());
			addChild(button);
		}
		targetStage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouch);
		targetStage.addEventListener(TouchEvent.TOUCH_MOVE, onTouch);
		targetStage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		targetStage.addEventListener(Event.DEACTIVATE, onDeactivate);
		targetStage.addEventListener(Event.RESIZE, resize);
		FlxG.signals.preStateSwitch.add(releaseAll);
		resize();
	}

	function resize(?event:Event):Void
	{
		releaseAll();
		var width = targetStage.stageWidth;
		var height = targetStage.stageHeight;
		var gap = Math.max(4, height * 0.015);
		var noteWidth = (width - gap * 5) / 4;
		var noteHeight = height * 0.19;
		var menuWidth = width * 0.15;
		var menuHeight = height * 0.10;
		for (i in 0...buttons.length)
		{
			var rect = bounds[i];
			if (i < 4)
				rect.setTo(gap + i * (noteWidth + gap), height - noteHeight - gap, noteWidth, noteHeight);
			else
				rect.setTo(width - (7 - i) * (menuWidth + gap), gap, menuWidth, menuHeight);
			var button = buttons[i];
			button.x = rect.x;
			button.y = rect.y;
			button.graphics.clear();
			button.graphics.lineStyle(2, 0xFFFFFF, 0.65);
			button.graphics.beginFill(0x101020, 0.55);
			button.graphics.drawRoundRect(0, 0, rect.width, rect.height, 12, 12);
			button.graphics.endFill();
			var text:TextField = cast button.getChildAt(0);
			text.defaultTextFormat = new TextFormat('_sans', Std.int(Math.max(12, height * 0.028)), 0xFFFFFF, true, null, null, null, null, 'center');
			text.width = rect.width;
			text.height = height * 0.05;
			text.y = (rect.height - text.height) / 2;
			text.text = labels[i];
		}
	}

	function onTouch(event:TouchEvent):Void
	{
		var next = -1;
		for (i in 0...bounds.length)
		{
			if (bounds[i].contains(event.stageX, event.stageY))
			{
				next = i;
				break;
			}
		}
		// Sliding between lanes releases the old key before pressing the new one.
		if (touches.exists(event.touchPointID) && touches.get(event.touchPointID) == next)
			return;
		releaseTouch(event.touchPointID);
		if (next < 0)
			return;
		var action = actions[next];
		if (next < 4)
		{
			var playing = Std.isOfType(FlxG.state, PlayState) && FlxG.state.subState == null;
			action = (playing ? 'note_' : 'ui_') + action;
		}
		var keys = Controls.instance.keyboardBinds.get(action);
		if (keys == null)
			return;
		for (key in keys)
		{
			if (key != flixel.input.keyboard.FlxKey.NONE)
			{
				touches.set(event.touchPointID, next);
				touchKeys.set(event.touchPointID, key);
				var count = keyHolds.exists(key) ? keyHolds.get(key) : 0;
				keyHolds.set(key, count + 1);
				buttons[next].alpha = 1;
				if (count == 0)
					sendKey(KeyboardEvent.KEY_DOWN, key);
				break;
			}
		}
	}

	function onTouchEnd(event:TouchEvent):Void
	{
		releaseTouch(event.touchPointID);
	}

	function releaseTouch(id:Int):Void
	{
		if (!touchKeys.exists(id))
			return;
		var button = touches.get(id);
		var key = touchKeys.get(id);
		touches.remove(id);
		touchKeys.remove(id);
		var count = keyHolds.get(key) - 1;
		if (count == 0)
		{
			keyHolds.remove(key);
			sendKey(KeyboardEvent.KEY_UP, key);
		}
		else
			keyHolds.set(key, count);
		var stillHeld = false;
		for (heldButton in touches)
			if (heldButton == button)
				stillHeld = true;
		buttons[button].alpha = stillHeld ? 1 : 0.65;
	}

	function sendKey(type:String, key:Int):Void
	{
		Controls.instance.controllerMode = false;
		// A nonzero charCode avoids Flixel's legacy native remapping (0 + A becomes END).
		targetStage.dispatchEvent(new KeyboardEvent(type, true, false, key, key));
	}

	function onDeactivate(event:Event):Void
	{
		releaseAll();
	}

	function releaseAll():Void
	{
		var ids = [for (id in touchKeys.keys()) id];
		for (id in ids)
			releaseTouch(id);
		for (button in buttons)
			button.alpha = 0.65;
	}
}
#end
