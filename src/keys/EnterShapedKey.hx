package keys;

import ceramic.Shape;
import ceramic.Color;
import ceramic.Border;
import ceramic.Visual;
import viewport.Pivot;

/**
 * Draws a enter shaped rectangle with nice rounded corners
 */
class EnterShapedKey extends KeyRenderer {
	@content public var shape: String;
	// North is the further away member of the pair
	@content public var widthNorth: Float;
	@content public var heightNorth: Float;
	// South is the closer member of the piar
	@content public var widthSouth: Float;
	@content public var heightSouth: Float;
	// Segments can be 1...many (10 or below is sane)
	@content public var segments: Int = 10;

	public var top: Shape;
	public var bottom: Shape;

	// we are in the 1U = 100 units of scale ratio here:
	// this is the preset for OEM/Cherry profile keycaps (TODO more presets)
	var topX: Float = 100 / 8;

	static inline var topY: Float = (100 / 8) * 0.25;
	static inline var topOffset: Float = (100 / 8) * 2;
	static inline var roundedCorner: Float = (100 / 1 / 8);

	var signumR: Array<Int>;
	var signumT: Array<Int>;
	var signumB: Array<Int>;
	var offsetL: Float;
	var offsetR: Float;
	var offsetT: Float;
	var offsetB: Float;
	var localRadius: Float;
	var localWidth: Float;
	var localHeight: Float;

	override public function computeContent() {
		offsetB = heightSouth - heightNorth;
		offsetL = widthSouth - widthNorth;

		// TODO  There is still some oddity to fix with BEA and XT_2U
		this.border = new Border();

		if (this.shape == 'BAE' || this.shape == 'XT_2U') {
			this.border.pos(-this.offsetL, 0); // negative for BAE and XT_2U
			this.width = widthSouth;
		} else {
			this.border.pos(0, 0);
		}

		if (this.heightNorth > this.heightSouth) { // north element is the narrow one?
			if (this.widthNorth > this.widthSouth) {
				this.border.size(this.widthNorth, this.heightNorth);
			} else {
				this.border.size(this.widthSouth, this.heightNorth);
			}
		} else {
			if (this.widthNorth > this.widthSouth) {
				this.border.size(this.widthNorth, this.heightSouth);
			} else {
				this.border.size(this.widthSouth, this.heightSouth);
			}
		}

		this.border.borderColor = Color.RED;
		this.border.borderPosition = MIDDLE;
		this.border.borderSize = 2;
		this.border.depth = 4;
		this.border.visible = false;
		this.add(this.border);

		this.pivot = new Pivot(0, 0);
		this.pivot.depth = 500; // ueber alles o/
		this.pivot.visible = false;
		this.add(this.pivot);

		this.top = enterShape(widthNorth - topOffset, heightNorth - topOffset, widthSouth - topOffset, heightSouth - topOffset, topColor,
			topX, topY);
		this.top.depth = 5;
		this.add(this.top);

		this.bottom = enterShape(widthNorth, heightNorth, widthSouth, heightSouth, bottomColor, 0.0, 0.0);
		this.bottom.depth = 0;
		this.add(this.bottom);
	}

	function enterShape(widthNorth: Float, heightNorth: Float, widthSouth: Float, heightSouth: Float, color: Int, topX: Float, topY: Float) {
		final sine = [for (angle in 0...segments + 1) Math.sin(Math.PI / 2 * angle / segments)];
		final cosine = [for (angle in 0...segments + 1) Math.cos(Math.PI / 2 * angle / segments)];
		// @formatter:off

		var points = []; // re-clear the array since we are pushing only

		/**
		 * the shape has 4 corner types:
		 * +--------+
		 * |7      F|
		 * |        |
		 * |J      L|
		 * +--------+
		 * the string is picked so its feature points to an corner
		 *    +-----+
		 * 7  |7   F|
		 * +--+L    | <-the BAE case (we start counting from top leftmost corner)
		 * |J      L|
		 * +--------+
		 */

		var recipe: String = "777777"; // default is BAE
		var signumL: Array<Int> = [];
		var signumR: Array<Int> = [];
		var signumT: Array<Int> = [];
		var signumB: Array<Int> = [];

		// clockwise around we go:
		switch shape {
			case 'BAE Inverted':
				localWidth = widthNorth;
				localHeight = heightSouth;
				recipe = "7FLNLJ";
				/**
				 *        012345
				 * 7 #### F
				 *   ### NL
				 * J     L
				 */
				signumL= [ 0, 0, 0, 0, 0, 0];
				signumR= [ 0, 0, 0,-1,-1, 0];
				signumT= [ 0, 0, 0, 0, 0, 0];
				signumB= [ 0, 0,-1,-1, 0, 0];
			case 'BAE' | 'XT_2U':
				localWidth = widthSouth;
				localHeight = heightNorth;
				recipe = "7FLJZV";
				//    7   F
				// ZV  ##
				// J #### L
				signumL= [ 0,-1,-1,-1,-1, 0];
				signumR= [ 0, 0, 0, 0, 0, 0];
				signumT= [ 0, 0, 0, 0, 0, 0];
				signumB= [ 0, 0, 0, 0,-1,-1];
			case 'ISO Inverted':
				localWidth = widthSouth;
				localHeight = heightNorth;
				recipe = "7FDYLJ";
				// 7 ### F
				//   ####DF
				// J     L
				signumL= [ 0, 0, 0, 0, 0, 0];
				signumR= [ 0,-1,-1, 0, 0, 0];
				signumT= [ 0, 0, 0, 0, 0, 0];
				signumB= [ 0, 0,-1,-1, 0, 0];
			case 'AEK' | 'ISO':
				localWidth = widthNorth;
				localHeight = heightSouth;
				recipe = "7FLJIJ";
				// 7 #### F
				// J I###
				//   J   L
				signumL= [ 0, 0, 0, 1, 1, 0];
				signumR= [ 0, 0, 0, 0, 0, 0];
				signumT= [ 0, 0, 0, 0, 0, 0];
				signumB= [ 0, 0, 0, 0,-1,-1];
		}
		// @formatter:on
		this.localRadius = roundedCorner;
		size(localWidth, localHeight);

		if (recipe.length != 6) {
			throw "Recipe must be six characters long";
		}

		for (turn in 0...6) {
			switch shape {
				case 'AEK' | 'ISO' | 'BAE Inverted':
					offsetT = Math.abs(heightNorth - heightSouth) * signumT[turn]; // TODO account for gapX and gapY
					offsetB = Math.abs(heightNorth - heightSouth) * signumB[turn];
				case 'ISO Inverted' | 'BAE' | 'XT_2U': // to draw proper lower member height:
					offsetT = Math.abs(heightSouth) * signumT[turn]; // TODO account for gapX and gapY
					offsetB = Math.abs(heightSouth) * signumB[turn];
			}

			offsetL = Math.abs(widthNorth - widthSouth) * signumL[turn];
			offsetR = Math.abs(widthNorth - widthSouth) * signumR[turn];

			switch (recipe.charAt(turn)) {
				case "7":
					for (pointPairIndex in 0...segments) {
						points.push(topX + offsetL + offsetR + localRadius * (1 - cosine[pointPairIndex]));
						points.push(topY + offsetT + offsetB + localRadius * (1 - sine[pointPairIndex]));
						// trace ('7');
					}
				case "N":
					for (pointPairIndex in 0...segments) {
						points.push(topX + offsetL + offsetR + localWidth + localRadius * (1 - cosine[segments - pointPairIndex]));
						points.push(topY + offsetT + offsetB + localHeight + localRadius * (1 - sine[segments - pointPairIndex]));
						// trace ('N');
					}
				case "Z":
					for (pointPairIndex in 0...segments) {
						points.push(topX + offsetL + offsetR + localRadius * (1 - cosine[pointPairIndex]));
						points.push(topY + offsetT + offsetB + localHeight + localRadius * (1 - sine[pointPairIndex]));
						// trace ('Z');
					}
				case "F":
					for (pointPairIndex in 0...segments) {
						points.push(topX + offsetL + offsetR + localWidth + localRadius * (cosine[segments - pointPairIndex] - 1));
						points.push(topY + offsetT + offsetB + localRadius * (1 - sine[segments - pointPairIndex]));
						// trace ('F');
					}
				case "Y":
					for (pointPairIndex in 0...segments) {
						points.push(topX + offsetL + offsetR + localWidth + localRadius * (cosine[segments - pointPairIndex] - 1));
						points.push(topY + offsetT + offsetB + localHeight + localRadius * (1 - sine[segments - pointPairIndex]));
						// trace ('Y');
					}
				case "I":
					for (pointPairIndex in 0...segments) {
						points.push(topX + offsetL + offsetR + localRadius * (cosine[pointPairIndex] - 1));
						points.push(topY + offsetT + offsetB + localHeight + localRadius * (1 - sine[pointPairIndex]));
						// trace ('I');
					}
				case "L":
					for (pointPairIndex in 0...segments) {
						points.push(topX + offsetL + offsetR + localWidth + localRadius * (cosine[pointPairIndex] - 1));
						points.push(topY + offsetT + offsetB + localHeight + localRadius * (sine[pointPairIndex] - 1));
						// trace ('L');
					}
				case "V":
					for (pointPairIndex in 0...segments) {
						points.push(topX + offsetL + offsetR + localRadius * (cosine[segments - pointPairIndex] - 1));
						points.push(topY + offsetT + offsetB + localHeight + localRadius * (sine[segments - pointPairIndex] - 1));
						// trace ('V');
					}
				case "J":
					for (pointPairIndex in 0...segments) {
						points.push(topX + offsetL + offsetR + localRadius * (1 - cosine[segments - pointPairIndex]));
						points.push(topY + offsetT + offsetB + localHeight + localRadius * (sine[segments - pointPairIndex] - 1));
						// trace ('J');
					}
				case "D":
					for (pointPairIndex in 0...segments) {
						points.push(topX + offsetL + offsetR + localWidth + localRadius * (1 - cosine[pointPairIndex]));
						points.push(topY + offsetT + offsetB + localHeight + localRadius * (sine[pointPairIndex] - 1));
						// trace ('D');
					}
			}
		}

		var shape = new Shape();
		shape.color = color;
		shape.points = points;

		return shape;
	}
}
