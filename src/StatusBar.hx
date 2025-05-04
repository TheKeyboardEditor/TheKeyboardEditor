package;

class StatusBar {
	public static var element: haxe.ui.containers.HBox;

	/**
	 * Displays text in the left column
	 */
	public static function inform(with: String) {
		if (element == null)
			return;
		element.findComponent("action").text = with;
	}
	public static function error(with: String) {
		if (element == null)
			return;
		element.findComponent("action").text = with;
		haxe.ui.animation.AnimationTools.flash(element.findComponent("action"), 0xFFb13e53);
	}

	/**
	 * Sets the position text
	 */
	public static function pos(x: Float, y: Float) {
		if (element == null)
			return;
		element.findComponent("pos-x").text = '$x';
		element.findComponent("pos-y").text = '$y';
	}
}
