package;

import actions.Action;

/**
 * This is a data structure that is used for saving and executing different "actions"
 * These actions can range anything from placing a key to changing the color
 * We can use this to handle undo/redo by reconstructing the "base" from the beginning
 */
class ActionQueue {
	// The original class that we start the reconstruction from
	var queue: Array<Action> = [];
	var applied: Array<Action> = [];

	public function new() {}

	public function act() {
		if (queue.length > 0) {
			final action = this.queue.pop();
			action.act();
			this.applied.push(action);
			// temporary disable this so i can see move amount TODO re enable
			// StatusBar.inform('Applied action: $action');
		}
	}

	public inline function undo() {
		if (applied.length > 0) {
			var action = this.applied.pop();
			action.undo();
			StatusBar.inform('Reverted previous action: $action');
		} else {
			StatusBar.error("No action to undo");
		}
	}

	public function push(a: Action) {
		this.queue.push(a);
	}
}
