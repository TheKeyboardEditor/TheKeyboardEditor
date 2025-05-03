package ui;

import haxe.ui.containers.VBox;
import haxe.ui.events.UIEvent;

@:xml('
<vbox width="100%" height="100%" style="spacing: 0">
	<hbox width="100%" height="100%" style="spacing: 0; padding: 0; margin: 0;">
		<stack width="224px" height="100%" id="sidebars-stack" selectedIndex="0" />
		<tabview id="tabs" closable="true" />
	</hbox>
	<status id="status" />
</vbox>
')
class Index extends VBox {
	public function new() {
		super();
		StatusBar.element = status;
	}

	public function switchMode(mode: Mode) {
		var modes = cast(sidebarsStack.getComponentAt(sidebarsStack.selectedIndex), ui.SidebarCollection).modeSelector.modes;
		modes.selectedButton = modes.findComponent(mode);
		if (mode == Place) {
			(cast tabs.selectedPage : ui.ViewportContainer).display.clearSelection();
		}
	}

	@:bind(tabs, UIEvent.CHANGE)
	function onTabChange(_) {
		sidebarsStack.selectedIndex = tabs.pageIndex;
	}
}
