package;

import ceramic.PersistentData;
import ceramic.Scene;
import ceramic.KeyBindings;
import ceramic.KeyCode;
import haxe.ui.core.Screen;

class MainScene extends Scene {
	public var gui: ui.Index;
	public var store: PersistentData;

	/*
	 * Add any assets you want to load here
	 */
	override function preload() {
		assets.add(Fonts.FONTS__ROBOTO_REGULAR);
		// MODES
		assets.add(Images.ICONS__PLACE_MODE);
		assets.add(Images.ICONS__EDIT_MODE);
		assets.add(Images.ICONS__UNIT_MODE);
		assets.add(Images.ICONS__LEGEND_MODE);
		assets.add(Images.ICONS__KEYBOARD_MODE);
		assets.add(Images.ICONS__COLOR_MODE);
		// MISC ICONS
		assets.add(Images.ICONS__LOGO_DROPDOWN);
		assets.add(Images.ICONS__UNDO);
		assets.add(Images.ICONS__REDO);
		assets.add(Images.ICONS__COPY);
		assets.add(Images.ICONS__CUT);
		assets.add(Images.ICONS__PASTE);
		assets.add(Images.HEADER);
		// JSON
		assets.add(Texts.NUMPAD);
		assets.add(Texts.ALLPAD);
	}

	/*
	 * Called when scene has finished preloading
	 */
	override function create() {
		// Grab the stored projects
		this.store = new ceramic.PersistentData("keyboard");

		this.gui = new ui.Index();
		Screen.instance.addComponent(gui);

		openViewport(keyson.Keyson.parse(assets.text(Texts.NUMPAD)));

		// KEYBINDINGS!
		var keyBindings = new KeyBindings();
		var selectedPage: ui.ViewportContainer = cast gui.tabs.selectedPage;

		// Save
		keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_S)], () -> {
			save(selectedPage.display.keyson, store);
		});

		// Download
		keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_D)], () -> {
			download(selectedPage.display.keyson);
		});

		// Undo
		keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_Z)], () -> {
			selectedPage.display.queue.undo();
		});

		// Redo
		keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_Y)], () -> {
			selectedPage.display.queue.redo();
		});

		// Select all
		keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_A)], () -> {
			selectedPage.display.selectAll();
		});

		// Unselect all
		keyBindings.bind([SHIFT, CMD_OR_CTRL, KEY(KeyCode.KEY_A)], () -> {
			selectedPage.display.clearSelection();
		});

		// Copy
		keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_C)], () -> {
			selectedPage.display.copy();
		});

		// Cut
		keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_X)], () -> {
			selectedPage.display.cut();
		});

		// Paste
		keyBindings.bind([CMD_OR_CTRL, KEY(KeyCode.KEY_V)], () -> {
			selectedPage.display.paste();
		});
	}

	public function download(keyboard: keyson.Keyson) {
		FileDialog.download(haxe.Json.stringify(keyboard, "\t"), keyboard.name, "application/json");
		StatusBar.inform("Project has been downloaded");
	}

	public function save(keyboard: keyson.Keyson, store: ceramic.PersistentData) {
		// TODO: Compress during saving. See hxPako. No, it won't overcomplicate parsing as it will be done before that step.
		store.set(Std.string(keyboard.name), keyboard);
		store.save();
		StatusBar.inform("Project has been saved");
	}

	public function openViewport(keyboard: keyson.Keyson) {
		var viewport = new viewport.Viewport();
		viewport.keyson = keyboard;
		viewport.indexGui = gui;

		var container = new ui.ViewportContainer();
		container.styleString = "width: 100%; height: 100%; background-color: $secondary-background-color;";
		container.text = keyboard.name;
		container.display = viewport;

		gui.tabs.addComponent(container);
		gui.tabs.selectedPage = container;

		var sidebars = new ui.SidebarCollection();
		sidebars.viewport = viewport;
		sidebars.colorSidebar.viewport = viewport;
		sidebars.editSidebar.viewport = viewport;
		sidebars.modeSelector.mainScene = this;
		gui.sidebarsStack.addComponent(sidebars);
	}
}
