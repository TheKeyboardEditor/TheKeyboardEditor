package ui.sidebars;

import viewport.Viewport;
import haxe.ui.containers.VBox;
import haxe.ui.components.Button;
import haxe.ui.events.UIEvent;

@xml('
<vbox id="place-sidebar" styleName="sidebar-body">
	<box styleName="sidebar-title">
		<label text="Place" />
	</box>
	<scrollview styleName="sidebar-main" contentWidth="100%" autoHideScrolls="true">
		<vbox width="100%" horizontalAlign="center" verticalAlign="center">
			<button-bar id="keys" selectedIndex="0" layout="grid" layoutColumns="2" horizontalAlign="center" verticalAlign="center"></button-bar>
		</vbox>
	</scrollview>
</vbox>
')
class Place extends VBox {
	// HaxeUI ID => Keyson Shape
	var keyTypes: Map<String, String> = [
		"oneU" => "1U",
		"oneTwentyFiveU" => "1.25U",
		"oneFiveU" => "1.5U",
		"oneSeventyFiveU" => "1.75U",
		"twoU" => "2U",
		"twoTwentyFiveU" => "2.25U",
		"twoSeventyFiveU" => "2.75U",
		"twoUVertical" => "2U Vertical",
		"caps38oo" => "1.75U Stepped 1.5",
		"caps3ooo" => "1.75U Stepped 1.25",
		"ISO" => "ISO",
		"sixTwentyFiveU" => "6.25U",
		"BAE" => "BAE",
		"sevenU" => "7U",
		"AEK" => "AEK",
		"XT2U" => "XT_2U",
	];

	public var viewport: Viewport;

	public function new(?viewport: Viewport) {
		super();
		if (viewport != null) {
			this.viewport = viewport;
		}

		// TODO make shape and labels different one day
		for (key => value in keyTypes) {
			var button = new Button();
			button.id = key;
			button.text = value;
			button.width = button.height = 64;
			button.tooltip = 'select $value sized key for placing.';
			keys.addComponent(button);
		}
	}

	@:bind(keys, UIEvent.CHANGE)
	function onSelected(_) {
		CopyBuffer.designatedKey = keyTypes[keys.selectedButton.id];
		StatusBar.inform('Selected ${CopyBuffer.designatedKey}');
	}
}
