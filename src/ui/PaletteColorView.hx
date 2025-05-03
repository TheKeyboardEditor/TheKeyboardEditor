package ui;

import haxe.ui.components.Button;
import haxe.ui.containers.ScrollView;

// TODO can we make this section be parsed depending on the palette.swatches.length?
@:xml('
<scrollview width="100%" height="100%" contentWidth="100%" autoHideScrolls="true" style="border: none; background-color: $solid-background-color;">
	<vbox width="100%" horizontalAlign="center" verticalAlign="center">
		<button-bar id="colors" layout="grid" layoutColumns="4" horizontalAlign="center" verticalAlign="center" />
	</vbox>
</scrollview>
')
class PaletteColorView extends ScrollView {
	var columns(default, set): Int = 4;

	public function new(palette: keyson.Keyson.Palette, ?viewport: viewport.Viewport) {
		super();

		// Calculate the amount of columns
		// TODO: either >> 7 ) << 1) and >> 6 alone works, but which looks better?
		this.columns = Std.int(Math.min(16, ((palette.swatches.length >> 6) << 0) + 4));
		// above 16 columns it is really questionable if scrolling or hiting the right one is more tedious
		// we hardcode 16 as the sanity limt here

		for (color in palette.swatches ?? []) {
			var button = new Button();
			button.id = color.name;
			button.tooltip = color.name;
			button.width = button.height = 128 / columns;
			button.styleString = 'background-color: #${color.value.substring(4)};';
			if (viewport != null) {
				button.onClick = e -> {
					final value = palette.fromName(button.id).value;
					if (e.shiftKey) {
						viewport.colorSelectedKeyLegends(Std.parseInt('0x${value.substring(4)}'));
					} else {
						viewport.colorSelectedKeys(Std.parseInt('0x${value.substring(4)}'));
					}
				};
			}
			colors.addComponent(button);
		}
	}

	function set_columns(columns: Int) {
		this.columns = columns;
		(cast colors.layout: haxe.ui.layouts.VerticalGridLayout).columns = columns;
		return columns;
	}
}
