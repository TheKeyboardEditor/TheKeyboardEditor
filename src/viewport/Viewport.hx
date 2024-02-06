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
	//	public var mainScene: MainScene;
	public var guiScene: UI;
	public var barMode: String; // acces to active mode from gui.modeSelector.barMode
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
	var drag: Bool = false; // is a drag or click event hapening flag
	var deselection: Bool = false; // is a deselect event resulting in a drag

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

		var gridFilter = new ceramic.Filter();
		gridFilter.explicitRender = true;
		gridFilter.autoRender = false;
		gridFilter.size(grid.width, grid.height);
		gridFilter.content.add(grid);
		this.add(gridFilter);
		gridFilter.render();

		workSurface = parseInKeyboard(keyson);
		this.add(workSurface);

		placer = new Placer();
		placer.piecesSize = unit; // the pieces are not scaled
		placer.size(unit, unit);
		placer.anchor(.5, .5);
		placer.depth = 10;
		this.add(placer);

		// here we account only for events that happen over this Viewport
		this.onPointerDown(workSurface, viewportMouseDown);
	}

	/**
	 * Runs every frame
	 */
	override public function update(delta: Float) {
		// TODO: make this.pasue effective again
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
	// APPLYING DESIGN

	/**
	 * Called from any viewport and any click on the start of the drag
	 */
	function viewportMouseDown(info: TouchInfo) {
		this.viewportStartX = this.x;
		this.viewportStartY = this.y;
		drag = false;

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
		final xStep = this.viewportStartX + screen.pointerX - this.pointerStartX;
		final yStep = this.viewportStartY + screen.pointerY - this.pointerStartY;
		switch (guiScene.modeSelector.barMode) {
			case "place":
			// just ignore drag
			case "edit":
				// Check for minimum amount of movement before drag is declared
				if (xStep != 0 || yStep != 0) {
					drag = true;
					this.x = xStep;
					this.y = yStep;
				}
			case _:
				// ignore undefined drag
		}
	}

	/**
	 * finished the pan make a return
	 */
	function viewportMouseUp(info: TouchInfo) {
		switch (guiScene.modeSelector.barMode) {
			case "place":
				// TODO final place action
				if (x != 0 || y != 0) {
					// for drag - what do we do?
				} else {
					// TODO determine actually selected keyboard unit:
					final device = 0;
					final keyboardUnit = keyson.units[device];
					final shape = if (CopyBuffer.selectedKey != null) CopyBuffer.selectedKey else "1U";
					// TODO if there is a way to have a saner default legend?
					final legend = shape;
					// TODO calculate proper shaper size and offset:
					final placerMismatchX = 1 / 2;
					final placerMismatchY = 1 / 2;
					final x = placer.x / unit - placerMismatchX;
					final y = placer.y / unit - placerMismatchY;
					final gapX = Std.int((keyboardUnit.keyStep[Axis.X] - keyboardUnit.capSize[Axis.X]) / keyboardUnit.keyStep[Axis.X] * unit);
					final gapY = Std.int((keyboardUnit.keyStep[Axis.Y] - keyboardUnit.capSize[Axis.Y]) / keyboardUnit.keyStep[Axis.Y] * unit);
					final key = keyboardUnit.addKey(shape, [x, y], legend);
					final keycap: KeyRenderer = KeyMaker.createKey(keyboardUnit, key, unit, gapX, gapY, keyboardUnit.keysColor);
					keycap.pos(unit * key.position[Axis.X], unit * key.position[Axis.Y]);
					keycap.onPointerDown(keycap, (t: TouchInfo) -> {
						keyMouseDown(t, keycap);
					});
					this.workSurface.add(keycap);
				}
			case "edit":
				if (!drag) {
					// click on empty should deselect everything

					for (i in 0...selectedKeys.length)
						selectedKeys[i].select();
					// and dump the selection
					selectedKeys = [];
				}
			case _:
				// TODO either pan or start selection RoundedRectangle();
				StatusBar.error('Panning available only in edit mode.');
		}
		// depending on mode
		screen.offPointerMove(viewportMouseMove);
	}

	/**
	 * This gets called only if clicked on a key on the worksurface!
	 */
	function keyMouseDown(info: TouchInfo, keycap: KeyRenderer) {
		keyPosStartX = keycap.x;
		keyPosStartY = keycap.y;
		this.selectedKey = keycap;
		drag = false;

		// store current mouse position
		this.pointerStartX = screen.pointerX;
		this.pointerStartY = screen.pointerY;
		switch (guiScene.modeSelector.barMode) {
			case "edit":
				// move and select keys
				if (selectedKey.border.visible) {
					// is selected: (by using select we take care of pivot too!)
					selectedKey.select();
					selectedKeys.remove(selectedKey);
					// we just had a deselect, allowing drag leads to problems.
					deselection = true;
				} else {
					// wasn't selected:
					selectedKey.select();
					// by using .unshift() instead of .push() the last added member is on index 0
					selectedKeys.unshift(selectedKey);
					deselection = false;
				}

				// TODO infer the selection size and apply it to the placer:
				if (selectedKeys.length > 0) {
					placer.size(selectedKeys[0].width, selectedKeys[0].height);
				} else {
					placer.size(selectedKey.width, selectedKey.height);
				}

				// placer is usually referenced to mouse cursor, but while we move that's offset
				placerMismatchX = keyPosStartX - pointerStartX + screenX + this.x + selectedKey.width / 2;
				placerMismatchY = keyPosStartY - pointerStartY + screenY + this.y + selectedKey.height / 2;

				placerMismatchX += switch (selectedKey.sourceKey.shape) {
					case "BAE": -75;
					case "XT_2U": -100;
					default: 0;
				};
			case _:
				// just ignore undefined actions for now
		}

		// Try move along as we pan the touch
		screen.onPointerMove(this, keyMouseMove);

		// Finish the drag along when the pointer is released
		screen.oncePointerUp(this, keyMouseUp);
	}

	/**
	 * Called during key movement
	 */
	function keyMouseMove(info: TouchInfo) {
		switch (guiScene.modeSelector.barMode) {
			case "place":
			// just ignore drag
			case "edit":
				// there is a special case where the last selected element gets deselected and dragged
				if (selectedKeys.length > 0) {
					final xStep = coggify(keyPosStartX + screen.pointerX - pointerStartX, placingStep) - selectedKeys[0].x;
					final yStep = coggify(keyPosStartY + screen.pointerY - pointerStartY, placingStep) - selectedKeys[0].y;
					if (xStep != 0 || yStep != 0)
						drag = true;
					if (!deselection) {
						if (selectedKeys.length > 0) {
							for (key in selectedKeys) {
								key.x += xStep;
								key.y += yStep;
							}
						}
					}
				}
			case _:
				// just ignore undefined actions
		}
	}

	/**
	 * Called after the drag (touch/press is released)
	 */
	function keyMouseUp(info: TouchInfo) {
		switch (guiScene.modeSelector.barMode) {
			case "edit":
				// Restore placer to default size
				placer.size(unit, unit);
				placerMismatchX = 0;
				placerMismatchY = 0;

				// Actually execute the move of the selection
				if (selectedKeys.length > 0) {
					/**
					 * If the previous first member gets deselected the array will change pos()
					 * TODO: how can we know which remaining key will not move the array's position?
					 */
					final x = (selectedKeys[0].x - keyPosStartX) / unit;
					final y = (selectedKeys[0].y - keyPosStartY) / unit;
					// only if at least x or y is non zero
					// it was a valid drag
					// that didn't result in deselection
					// and we have actual keys to move at all
					if (x != 0 || y != 0 && drag && !deselection && selectedKeys.length > 0) {
						queue.push(new actions.MoveKeys(this, selectedKeys, x, y));
						if (selectedKeys.length == 1) {
							// deselect if single element was just dragged
							selectedKey.select();
							selectedKeys.remove(selectedKey);
						}
					}
				}
			case _:
				// undefined gets ignored
		}

		// The touch is already over, now cleanup and retur from there
		screen.offPointerMove(keyMouseMove);
	}
}
