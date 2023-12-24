package;

import ceramic.Scene;
import keyson.Keyson.Keyboard;

class Viewport extends Scene {
	var keyboard: Keyboard;
	var labelOffsetX: Float;
	var labelOffsetY: Float;
	var keyLabelOffsetX: Float;
	var keyLabelOffsetY: Float;

	inline static final unit = 100;

	override public function new(keyboard: Keyboard) {
		super();
		this.keyboard = keyboard;
	}

	override function create() {
		var gapX = Std.int((this.keyboard.keyStep[Axis.X] - this.keyboard.capSize[Axis.X]) / this.keyboard.keyStep[Axis.X] * unit);
		var gapY = Std.int((this.keyboard.keyStep[Axis.Y] - this.keyboard.capSize[Axis.Y]) / this.keyboard.keyStep[Axis.Y] * unit);
		var labelUnit = this.keyboard.labelSizeUnits;

		for (k in this.keyboard.keys) {
			var key: KeyRenderer;
			var keyLabel: LabelRenderer;

			// TODO: Create some form of syntax that can define this information without this switch case creature
			// if nothing is given it defaults to 1U
			switch k.shape {
				case "0.75U":
					final width = unit * 0.75 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "1.25U":
					final width = unit * 1.25 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "1.5U":
					final width = unit * 1.5 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "1.75U":
					final width = unit * 1.75 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "2U":
					final width = unit * 2 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "2.25U":
					final width = unit * 2.25 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "2.5U":
					final width = unit * 2.5 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "2.75U":
					final width = unit * 2.75 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "3U":
					final width = unit * 3 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "3U Vertical":
					final width = unit - gapX;
					final height = unit * 3 - gapY;
					key = new keys.RectangularKey(width, height);
				case "6.25U":
					final width = unit * 6.25 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "6.5U":
					final width = unit * 6.5 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "7U":
					final width = unit * 7 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "9U":
					final width = unit * 9 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "10U":
					final width = unit * 10 - gapX;
					final height = unit - gapY;
					key = new keys.RectangularKey(width, height);
				case "2U Vertical":
					final width = unit - gapX;
					final height = unit * 2 - gapY;
					key = new keys.RectangularKey(width, height);
				case "ISO":
					// Normal ISO
					final widthNorth = 150 - gapX;
					final heightNorth = 100 - gapY;
					final widthSouth = 125 - gapX;
					final heightSouth = 200 - gapY;
					final offsetSouthX = 25 + Std.int(gapX / 2);
					final offsetSouthY = 0 + Std.int(gapY / 2);
					key = new keys.LShapeKey(widthNorth, heightNorth, widthSouth, heightSouth, offsetSouthX, offsetSouthY);
				case "ISO Inverted":
					// Inverted ISO
					// This is an ISO enter but with the top of the keycap reversed
					final widthNorth = 125 - gapX;
					final heightNorth = 200 - gapY;
					final widthSouth = 150 - gapX;
					final heightSouth = 100 - gapY;
					final offsetSouthX = 0 + Std.int(gapX / 2);
					final offsetSouthY = 100 + Std.int(gapY / 2);
					key = new keys.LShapeKey(widthNorth, heightNorth, widthSouth, heightSouth, offsetSouthX, offsetSouthY);
				case "BAE":
					// Normal BAE
					final widthNorth = 150 - gapX;
					final heightNorth = 200 - gapY;
					final widthSouth = 225 - gapX;
					final heightSouth = 100 - gapY;
					final offsetSouthX = -75 - Std.int(gapX / 2);
					final offsetSouthY = 100 + Std.int(gapY / 2);
					key = new keys.LShapeKey(widthNorth, heightNorth, widthSouth, heightSouth, offsetSouthX, offsetSouthY);
				case "BAE Inverted":
					// Inverted BAE
					final widthNorth = 225 - gapX;
					final heightNorth = 100 - gapY;
					final widthSouth = 150 - gapX;
					final heightSouth = 200 - gapY;
					final offsetSouthX = 0 - Std.int(gapX / 2);
					final offsetSouthY = 0 + Std.int(gapY / 2);
					key = new keys.LShapeKey(widthNorth, heightNorth, widthSouth, heightSouth, offsetSouthX, offsetSouthY);
				case "XT 2U":
					final widthNorth = 100 - gapX;
					final heightNorth = 200 - gapY;
					final widthSouth = 200 - gapX;
					final heightSouth = 100 - gapY;
					final offsetSouthX = -100 - Std.int(gapX / 2);
					final offsetSouthY = 100 + Std.int(gapY / 2);
					key = new keys.LShapeKey(widthNorth, heightNorth, widthSouth, heightSouth, offsetSouthX, offsetSouthY);
				case "AEK":
					final widthNorth = 125 - gapX;
					final heightNorth = 100 - gapY;
					final widthSouth = 100 - gapX;
					final heightSouth = 200 - gapY;
					final offsetSouthX = 25 + Std.int(gapX / 2);
					final offsetSouthY = 0 + Std.int(gapY / 2);
					key = new keys.LShapeKey(widthNorth, heightNorth, widthSouth, heightSouth, offsetSouthX, offsetSouthY);
				default:
					// 1U
					var width = unit - gapX;
					var height = unit - gapY;
					key = new keys.RectangularKey(width, height);
			}

			key.pos(unit * k.position[Axis.X] + 500, unit * k.position[Axis.Y] + 100);
			this.add(key.create());

			for (l in k.labels) {
				keyLabel = new LabelRenderer(l.glyph);
				keyLabel.labelColor = 0xFF00000F;
				// is the label position set specifically?
				if (l.labelPosition != null) { // yes we adjust specifically
					labelOffsetX = l.labelPosition[Axis.X];
					labelOffsetY = l.labelPosition[Axis.Y];
				} else { // no we use the global coordinates
					labelOffsetX = this.keyboard.labelPosition[Axis.X];
					labelOffsetY = this.keyboard.labelPosition[Axis.Y];
				}
				// is the fontsize set specifically?
				if (l.labelFontSize != 0) { // TODO make this detect per key font change
					keyLabel.labelFontSize = l.labelFontSize;
				} else {
					keyLabel.labelFontSize = this.keyboard.keyboardFontSize;
				}

				keyLabel.depth = 4; // mae sure labels render on top

				keyLabel.pos(labelOffsetX
					+ keyLabel.topX
					+ unit * k.position[Axis.X]
					+ 500,
					labelOffsetY
					+ keyLabel.topY
					+ unit * k.position[Axis.Y]
					+ 100);
				this.add(keyLabel.create());
			}
		}
	}
}

/**
 * We define the X and Y axes exclusively for convenience here
 * It will compile down to just X = 0, Y = 1
 */
enum abstract Axis(Int) to Int {
	var X;
	var Y;
}
