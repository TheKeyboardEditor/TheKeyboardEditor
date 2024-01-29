package viewport;

import ceramic.Quad;
import ceramic.Visual;
import ceramic.Scene;
import ceramic.TouchInfo;
import keyson.Axis;
import keyson.Keyson;
import keyson.Keyson.Keyboard;
import keyson.Keyson.Key;
import Type;

class Viewport extends Scene {
	/**
	 * The keyson being renderered
	 */
	public var keyson: keyson.Keyson;

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

	var touchType: String = "";
	var activeProjectName: Keyson;

	// Constants
	var viewportStartX: Float = 0.0;
	var viewportStartY: Float = 0.0;
	var pointerStartX: Float = 0.0;
	var pointerStartY: Float = 0.0;

	public var screenX: Float = 0;
	public var screenY: Float = 0;

	inline static final unit: Float = 100;
	inline static final quarterUnit: Float = Std.int(unit / 4);
	inline static final skipFrames: Float = 10; // how many frames to skip

	var framesSkipped: Float = 0; // current count (kept between skips)

	// GLOBAL SCENE

	/**
	 * Dispatches keyboard and mouse inputs to the seperate functions
	 */
	public function inputDispatch() {}

	/**
	 * Initializes the scene
	 */
	override public function create() {
		// we intercept only this.viewport mouse down event:
		this.onPointerDown(workSurface, viewportMouseDown);

		var grid = new Grid();
		grid.primaryStep(unit);
		grid.subStep(quarterUnit);
		grid.depth = -1;
		this.add(grid);

		workSurface = parseInKeyboard(keyson);
		this.add(workSurface);

		placer = new Placer();
		placer.size(100, 100);
		placer.anchor(.5, .5);
		placer.depth = 10;
		this.add(placer);
	}

	/**
	 * Runs every frame
	 */
	override public function update(delta: Float) {
		placerUpdate();
		/*   run a task every ${skipFrames} only:
		 *
		 * (this is primarly intended for odd cases like zooming)
		 */
		if (framesSkipped < skipFrames) {
			framesSkipped++;
		} else {
			framesSkipped = 0;
			this.onPointerDown(workSurface, (info) -> {
				if (info.buttonId == 0) {
					StatusBar.inform('Placer at: ${placer.x / unit - .5}, ${placer.y / unit - .5}');
				}
			});
			// 0.5 is accounting for the middle of the 1U sized placer
			// StatusBar.pos(placer.x / unit - .5, placer.y / unit - .5);
			StatusBar.pos(viewportStartX, viewportStartY);
		}
	}

	// PLACER

	/**
	 * Runs every frame, used to position the placer
	 */
	function placerUpdate() {
		placer.x = screen.pointerX - screenX - this.x;
		placer.y = screen.pointerY - screenY - this.y;
		placer.pos(placer.x - placer.x % 25, placer.y - placer.y % 25);
	}

	/**
	 *  Called only once to parse in the keyboard into the workSurface
	 */
	function parseInKeyboard(keyboard: Keyson): Visual {
		final workKeyboard = new Visual(); // initialize what we draw onto
		for (keyboardUnit in keyboard.units) { // parse all units (usually just one)
			// Set unit's gap values
			final gapX = Std.int((keyboardUnit.keyStep[Axis.X] - keyboardUnit.capSize[Axis.X]) / keyboardUnit.keyStep[Axis.X] * unit);
			final gapY = Std.int((keyboardUnit.keyStep[Axis.Y] - keyboardUnit.capSize[Axis.Y]) / keyboardUnit.keyStep[Axis.Y] * unit);
			for (key in keyboardUnit.keys) { // parse all keycaps/elements
				if (keyboardUnit.keys.contains(key) == false) {
					throw "Key does not exist inside the Keyson keyboard"; // @Logo is this sanity check actually sane?
				}
				final keycap: KeyRenderer = KeyMaker.createKey(keyboardUnit, key, unit, gapX, gapY, keyboardUnit.keysColor);
				keycap.pos(unit * key.position[Axis.X], unit * key.position[Axis.Y]); // position the unit
				keycap.onPointerDown(keycap, keyMouseDown);
				workKeyboard.add(keycap);
			}
		}
		return workKeyboard;
	}

	function keyMouseDown(info: TouchInfo) {
		// this gets called only if clicked on a key on the worksurface!
		activeProjectName = this.keyson;
		if (Type.getClass(this) == Viewport) {
			StatusBar.inform('Touched [${this.keyson.name}] at: ${info.x / unit - .5}, ${info.y / unit - .5}');
			touchType = "Element";
		}
	}

	// MOVEMENT

	/**
	 * Ran on the start of the drag
	 */
	function viewportMouseDown(info: TouchInfo) {
		if (activeProjectName == this.keyson) {
			if (touchType == "Element") {
				// TODO move keys one day
				StatusBar.inform('Move started: ');
			} else {
				// TODO there should be certain amount of movement before we declare it's a drag at all
				// store current viewport position into ViewportStart
				this.viewportStartX = this.x;
				this.viewportStartY = this.y;
				// store current mouse position
				this.pointerStartX = screen.pointerX;
				this.pointerStartY = screen.pointerY;
				// move along as we pan the touch
				screen.onPointerMove(this, viewportMouseMove);
			}
			touchType = ""; // reset
			trace('type:<none>', this.keyson.name);
			// Stop dragging when releasing pointer
			this.oncePointerUp(this, viewportMouseUp);
		}
	}

	/**
	 * Ran during AND at the very end of the drag
	 */
	function viewportMouseMove(info: TouchInfo) {
		if (touchType == "Element") {
			// TODO move keys one day
		} else {
			this.pos(this.viewportStartX + screen.pointerX - this.pointerStartX, this.viewportStartY + screen.pointerY - this.pointerStartY);
		}
	}

	/**
	 * Called after the drag
	 */
	function viewportMouseUp(info: TouchInfo) {
		// finish the moving to the final position
		screen.offPointerMove(viewportMouseMove);
	}
}
