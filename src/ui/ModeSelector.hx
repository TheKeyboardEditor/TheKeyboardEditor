package ui;

import haxe.ui.containers.VerticalButtonBar;
import haxe.ui.events.UIEvent;

@xml('
<vbox style="spacing: 0">
	<menu-item-picker id="picker" showText="false" showIcon="false" width="64px" height="32px" panelWidth="200" animatable="false" verticalAlign="center">
		<item-renderer id="itemPickerRenderer" height="32px" verticalAlign="center">
			<image resource="icons/logo-dropdown" horizontalAlign="center" verticalAlign="center" />
		</item-renderer>
		<data>
			<item id="new" text="New" />
			<item id="open" text="Open" />
			<item id="save" text="Save" />
			<item id="download" text="Download" />
			<item id="import" text="Import KLE" />
			<item id="export" disabled="true" text="Export" />
		</data>
	</menu-item-picker>
	<button-bar selectedIndex="0" direction="vertical" id="modes" styleName="modeSelector">
		<button id="place-mode" text="Place" icon="icons/place-mode" iconPosition="top" />
		<button id="edit-mode" text="Edit" icon="icons/edit-mode" iconPosition="top" />
		<button id="unit-mode" text="Unit" icon="icons/unit-mode" iconPosition="top" />
		<button id="legend-mode" text="Legend" icon="icons/legend-mode" iconPosition="top" />
		<button id="color-mode" text="Color" icon="icons/color-mode" iconPosition="top" />
		<button id="present-mode" text="Present" icon="icons/keyboard-mode" iconPosition="top" />
	</button-bar>
</vbox>
')
class ModeSelector extends VerticalButtonBar {
	public var mainScene: MainScene;

	@:bind(picker, UIEvent.CHANGE)
	function pickerEvents(event: UIEvent) {
		switch (event.relatedComponent.id) {
			case "new":
				final dialog = new ui.dialogs.NewNameDialog();
				dialog.onDialogClosed = function(_) {
					final name = dialog.name.value;
					if (StringTools.trim(name) == "")
						return;
					mainScene.openViewport(new keyson.Keyson(name));
				}
				dialog.showDialog();
			case "open":
				final dialog = new FileDialog();
				dialog.openJson("Keyson File");
				dialog.onFileLoaded(mainScene, (body: String) -> {
					mainScene.openViewport(keyson.Keyson.parse(body));
				});
			case "save":
				mainScene.save((cast mainScene.gui.tabs.selectedPage: ui.ViewportContainer).display.keyson, mainScene.store);
			case "download":
				mainScene.download((cast mainScene.gui.tabs.selectedPage: ui.ViewportContainer).display.keyson);
			case "import":
				final dialog = new FileDialog();
				dialog.openJson("KLE Json File");
				dialog.onFileLoaded(mainScene, (body: String) -> {
					var dialog = new ui.dialogs.ImportNameDialog();
					dialog.onDialogClosed = function(_) {
						final name = dialog.name.value;
						if (StringTools.trim(name) == "")
							return;
						mainScene.openViewport(keyson.KLE.toKeyson(name, body));
					}
					dialog.showDialog();
				});
			default:
				StatusBar.error("Unimplemented action");
		}
	}
}
