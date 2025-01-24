package actions;

import viewport.Viewport;
import keyson.Keyson;
import keyson.Axis;

class DeleteKeys extends Action {
	final viewport: Viewport;
	final device: keyson.Keyboard; // the receiving unit
	var deletedKeys: Array<Keycap>;

	override public function new(viewport: Viewport, device: keyson.Keyboard, deletedKeys: Array<Keycap>) {
		super();
		this.viewport = viewport;
		this.device = device;
		this.deletedKeys = deletedKeys.copy();
	}

	override public function act(type: ActionType) {
		for (member in deletedKeys) {
			// clear keyson:
			this.device.removeKey(member.sourceKey);
			// clear Ceramic:
			member.destroy();
		}
		super.act(type);
	}

	override public function undo() {
		var i = 0;
		for (key in deletedKeys) {
			final recreatedKey = KeyMaker.createKey(this.device, key.sourceKey, this.viewport.unit, this.viewport.gapX, this.viewport.gapY);
			recreatedKey.pos(this.viewport.unit * key.sourceKey.position[Axis.X], viewport.unit * key.sourceKey.position[Axis.Y]);
			recreatedKey.component('logic', new viewport.components.KeyLogic(viewport));
			deletedKeys[i] = recreatedKey;
			// recreate keyson:
			this.device.insertKey(recreatedKey.sourceKey);
			// recreate Ceramic:
			this.viewport.keyboard.add(recreatedKey);
			i++;
		}
	}
}
