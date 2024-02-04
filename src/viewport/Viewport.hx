package viewport;

import ceramic.Visual;
import ceramic.Scene;
import ceramic.TouchInfo;
import ceramic.KeyBindings;
import ceramic.KeyCode;
import keyson.Axis;
import keyson.Keyson;
import keyson.Keyson.Keyboard;
import keyson.Keyson.Key;

class Viewport extends Scene {
	/**
	 * The keyson being renderered
	 */
	public var keyson: keyson.Keyson;
	public var screenX: Float = 0;
	public var screenY: Float = 0;

	public final queue = new ActionQueue();

	/**
	 * This is where we map all of the different events to specific keys
	 * See Input.hx file for more details
	 */
	final inputMap = new Input();

	/**
	 * Ceramic elements
	 */
	var workSurface: Visual;
	var placer: Placer;

	// Movement variables

	/**
	 * For dragging of the viewport
	 */
	var viewportStartX: Float = 0.0;
	var viewportStartY: Float = 0.0;

	var pointerStartX: Float = 0.0;
	var pointerStartY: Float = 0.0;

	/**
	 * For dragging keys around
	 */
	var keyPosStartX: Float = 0.0;
	var keyPosStartY: Float = 0.0;

	var placerMismatchX: Float = 0.0;
	var placerMismatchY: Float = 0.0;

	/**
	 * Stuff that upsets logo but fire-h0und refuses to remove
	 */
	var selectedKey: KeyRenderer; // still needed across few functions -.-'
	var selectedKeys: Array<KeyRenderer> = []; // still needed across few functions -.-'

	// Constants
	// Size of a key
	public var unit: Float = 100;

	inline static final placingStep: Float = Std.int(100 / 4);

	// GLOBAL SCENE

	/**
	 * Dispatches keyboard and mouse inputs to the seperate functions
	 */
	public function inputDispatch() {}

	/**
	 * Initializes the scene
	 */
	override public function create() {
		var grid = new Grid();
		grid.primaryStep(unit);
		grid.subStep(placingStep);
		grid.depth = -1;
		this.add(grid);

		workSurface = parseInKeyboard(keyson);
		this.add(workSurface);

		placer = new Placer();
		placer.piecesSize = unit; // the pieces are not scaled
		placer.size(unit, unit);
		placer.anchor(.5, .5);
		placer.depth = 10;
		this.add(placer);
	}

	/**
	 * Runs every frame
	 */
	override public function update(delta: Float) {
		placerUpdate();
		queue.act();
	}
	// PLACER

	/**
	 * Cogify the movement to step edges
	 */
	final inline function coggify(x: Float, cogs: Float): Float {
		return x - x % cogs;
	}

	/**
	 * Runs every frame, used to position the placer
	 */
	function placerUpdate() {
		placer.x = coggify(screen.pointerX - screenX - this.x + placerMismatchX, placingStep);
		placer.y = coggify(screen.pointerY - screenY - this.y + placerMismatchY, placingStep);
		StatusBar.pos(placer.x / unit, placer.y / unit);
	}

	/**
	 * Called only once to parse in the keyboard into the workSurface
	 */
	function parseInKeyboard(keyboard: Keyson): Visual {
		final workKeyboard = new Visual();
		for (keyboardUnit in keyboard.units) {
			final gapX = Std.int((keyboardUnit.keyStep[Axis.X] - keyboardUnit.capSize[Axis.X]) / keyboardUnit.keyStep[Axis.X] * unit);
			final gapY = Std.int((keyboardUnit.keyStep[Axis.Y] - keyboardUnit.capSize[Axis.Y]) / keyboardUnit.keyStep[Axis.Y] * unit);

			for (key in keyboardUnit.keys) {
				final keycap: KeyRenderer = KeyMaker.createKey(keyboardUnit, key, unit, gapX, gapY, keyboardUnit.keysColor);
				keycap.pos(unit * key.position[Axis.X], unit * key.position[Axis.Y]);
				keycap.onPointerDown(keycap, (t: TouchInfo) -> {
					keyMouseDown(t, keycap);
				});
				workKeyboard.add(keycap);
			}
		}
		return workKeyboard;
	}
	// MOVEMENT

	/**
	 * Called from any viewport and any click on the start of the drag
	 */
	function viewportMouseDown(info: TouchInfo) {
		// TODO: Check for maximum amount of movement before drag is declared
		this.viewportStartX = this.x;
		this.viewportStartY = this.y;

		// Store current mouse position
		this.pointerStartX = screen.pointerX;
		this.pointerStartY = screen.pointerY;

		placerMismatchX = 0;
		placerMismatchY = 0;

		// Move along as we pan the touch
		screen.onPointerMove(this, viewportMouseMove);

		// Stop dragging when pointer is released
		screen.oncePointerUp(this, viewportMouseUp);
	}

	/**
	 * Ran during and at the very end of the pan of the viewport
	 */
	function viewportMouseMove(info: TouchInfo) {
		this.x = this.viewportStartX + screen.pointerX - this.pointerStartX;
		this.y = this.viewportStartY + screen.pointerY - this.pointerStartY;
		StatusBar.inform('Pan view:[${screen.pointerX - this.pointerStartX}x${screen.pointerY - this.pointerStartY}]');
	}

	/**
	 * Called after the pan of the viewport
	 */
	function viewportMouseUp(info: TouchInfo) {
		screen.offPointerMove(viewportMouseMove);
	}

	/**
	 * This gets called only if clicked on a key on the worksurface!
	 */
	function keyMouseDown(info: TouchInfo, keycap: KeyRenderer) {
		keyPosStartX = keycap.x;
		keyPosStartY = keycap.y;
		this.selectedKey = keycap;

		if (selectedKey.border.visible) {
			// is selected: (by using select we take care of pivot too!)
			selectedKey.select();
			selectedKeys.remove(selectedKey);
		} else {
			// wasn't selected:
			selectedKey.select();
			// by using .unshift() instead of .push() the last added member is on index 0
			selectedKeys.unshift(selectedKey);
		}

		// TODO infer the selection size and apply it to the placer:
		if (selectedKeys.length > 0) {
			placer.size(selectedKeys[0].width, selectedKeys[0].height);
		} else {
			placer.size(selectedKey.width, selectedKey.height);
		}

		// store current mouse position
		this.pointerStartX = screen.pointerX;
		this.pointerStartY = screen.pointerY;

		// placer is usually referenced to mouse cursor, but while we move that's off
		placerMismatchX = keyPosStartX - pointerStartX + screenX + this.x + selectedKey.width / 2;
		placerMismatchY = keyPosStartY - pointerStartY + screenY + this.y + selectedKey.height / 2;

		placerMismatchX += switch (selectedKey.sourceKey.shape) {
			case "BAE": -75
			case "XT_2U": -100
			default: 0
		}

		// Try move along as we pan the touch
		screen.onPointerMove(this, keyMouseMove);

		// Stop dragging when the pointer is released
		screen.oncePointerUp(this, keyMouseUp);
	}

	/**
	 * Called during key movement
	 */
	function keyMouseMove(info: TouchInfo) {
		if (selectedKeys.length > 0) {
			final xStep = coggify(keyPosStartX + screen.pointerX - pointerStartX, placingStep) - selectedKeys[0].x;
			final yStep = coggify(keyPosStartY + screen.pointerY - pointerStartY, placingStep) - selectedKeys[0].y;

			for (key in selectedKeys) {
				key.x += xStep;
				key.y += yStep;
			}
		}
	}

	/**
	 * Called after the drag
	 */
	function keyMouseUp(info: TouchInfo) {
		// Restore placer to default size
		placer.size(unit, unit);
		placerMismatchX = 0;
		placerMismatchY = 0;

		// Move selection
		if (selectedKeys.length > 0) {
			/**
			 * If the previous first member gets deselected the array will change pos()
			 * TODO: how can we know which remaining key will not move the array's position?
			 */
			final x = (selectedKeys[0].x - keyPosStartX) / unit;
			final y = (selectedKeys[0].y - keyPosStartY) / unit;
			if (x != 0 || y != 0) {
				queue.push(new actions.MoveKeys(this, selectedKeys, x, y));
			}
		}

		// The touch is already over, now cleanup
		screen.offPointerMove(keyMouseMove);
	}
}
