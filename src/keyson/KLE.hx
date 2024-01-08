package keyson;

class KLE {
	// Converts a json string from Keyboard Layout Editor to Keyson's object format
	public static function toKeyson(string: String): Keyson {
		var keyson = new keyson.Keyson();
		var kle = haxe.Json.parse(string);
		kle[0];

		var w: Float = 1;
		var x: Float = 0;
		var y: Float = 0;
		var posX: Float = 0;
		var posY: Float = 0; // legend coordinates
		var xNext: Float = 1;
		var shape: String = "1U";
		var keysColor: String = "0xFFFAFAFA";
		var legendColor: String = "0xFF000000";
		var key: Keyson.Key;
		var legendSize: Float = 20; // see below the default is [3]
		// HANDY RULER:                0  1  2  3  4  5  6  7  8  9
		var fontSizes: Array<Float> = [20,14,16,20,22,24,28,30,32,36];

		keyson.unit[0].legendPosition = [6.0,6.0]; // a default nice looking collective offset
		// KLE's keyson has really odd fileds and relations?
		for (row in kle) { // iterate thru rows
			row[0]; // with calling this we force haxe alow iteration of row
			x = 0; // reset horizontal key position
			for (column in row) { // iterate thru keys and gaps and all other stuff
				if (column.y != null) // if we find a y: pair we add it as vertical row-to row padding
					y = y + column.y; // effective immediately
				if (column.x != null) // if we find a x: pair we assume it's key to key padding
					xNext += column.x; // effective sfter placing the current element
				if (column is String) { // we check if there is a "legend" in this columanr element
					var legend: String = Std.string(column); // yes, we take it in
					//trace("legend:", legend);
					// @formatter:off
					if (shape == "ISO") // special case - for one reason or the other it renders 0.25U off to the right
						key = keyson.unit[0].addKey(shape, [x - 0.25, y], legend)
					else
						key = keyson.unit[0].addKey(shape, [x, y], legend);
					key.keysColor = keysColor;
					key.legends[0].legendColor = legendColor;
					key.legends[0].legendSize = legendSize;
					key.legends[0].legendPosition = [posX,posY];
					w = 1; // default presumed width (if none is given)
					shape = "1U"; // presumed shape
				} else { // no there is no string in this element:
					w =  if (column.w != null) column.w // if we have w: pair we evaluate width
					else if (column.h != null) column.h
					else 1; // default is width of 1U
					// SHAPES
					// TODO stepped
					// TODO actually rotate the rotated keys
					// ROTATION center seems to overide the current position!
					x = if (column.rx != null) column.rx else x;
					y = if (column.ry != null) column.ry+1 else y;// our running y is preadded by now
					shape = if (column.w2 != null && column.w2 == 1.5 && column.h == 2) "ISO"
					else    if (column.w2 != null && column.w2 == 2.25 && column.h == 2 ) "BAE"
					else    if (column.h != null) Std.string(w) + "U Vertical"
					else    if (column.w != null) Std.string(w) + "U"
					else       "1U"; // w to shape
					// trace("shape:",shape);
					// COLOR
					if (column.c != null)
						trace("column: ", "0xFF" + column.c.split("#")[1]); // extract the hex from "#hhhhhh" and add 0xFF in front
					keysColor = if (column.c != null)
						"0xFF" + column.c.split("#")[1] else keysColor;
					legendColor = if (column.t != null)
						"0xFF" + column.t.split("#")[1] else legendColor;
					legendSize = if (column.f != null)
						legendSize = fontSizes[column.f] else legendSize;
					if (column.a != null) {
					// LEGEND POSITIONS:
					// bitmask 1 << 0 (0x01) seems to be for X offset to the middle
					// TODO this should actually be the middle but we don't have centered text just yet
						posX = if ((column.a & 1 << 0) == 1 << 0) 22 else 0; // so far 22 seems a good middle point (that's 28 actually see above)
						// bitmask 1 << 1 (0x02) seems to be for X offset to the middle
						posY = if ((column.a & 1 << 1) == 1 << 1) 22 else 0;
					}
					// @formatter:on
					x--; // we compensate default automatic horizontal stepping for this non key producing element
				}
				x = x + xNext; // make horizontal stepping for the next item
				if (column.w != null) {
					xNext = column.w; // accout for item position in the next iteration
				} else {
					xNext = 1;
				}
			}
			y++; // make vertical stepping after the row is processed
		}
		// return what was converted
		return keyson;
	}

	// Converts a Keyson object to a Keyboard Layout Editor json
	public static function fromKeyson(keyson: Keyson) {}
}
