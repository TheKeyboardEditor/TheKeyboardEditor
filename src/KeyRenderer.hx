package;

class KeyRenderer extends ceramic.Visual {
	@content public var topColor: ceramic.Color;
	@content public var bottomColor: ceramic.Color;
	@content public var legends: Array<LegendRenderer>;

	public var border: ceramic.Border;
	@content public var pivot: viewport.Pivot;
	@content public var sourceKey: keyson.Keyson.Key;

	public function select() {
		border.visible = true;
		pivot.visible = true;
	}

	// explicit deselection is sometimes unavoidable
	public function deselect() {
		border.visible = false;
		pivot.visible = false;
	}

	override public function computeContent() {
		// TODO recreate legends after color change
		for (l in legends) {
			l.depth = 50;
			this.add(l);
		}
		super.computeContent();
	}
}
