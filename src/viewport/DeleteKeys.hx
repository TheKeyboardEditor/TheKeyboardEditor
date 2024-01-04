package viewport;

class DeleteKeys extends Action {
	final viewport: Viewport;
	var deleted: Array<keyson.Keyson.Key> = [];

	override public function new(viewport: Viewport) {
		super();
		this.viewport = viewport;
	}

	override public function act() {
		for (key in viewport.selected.keys()) {
			// Delete from viewport renderer
			viewport.keyboard.keys.remove(key);
			viewport.selected[key].destroy();

			this.deleted.push(key);
		}
		super.act();
	}

	override public function undo() {
		for (key in deleted) {
			this.viewport.keyboard.keys.push(key);
			this.viewport.drawKey(key);
		}
	}
}
