package ui;

import haxe.ui.containers.HBox;

@:xml('
<hbox styleName="status" width="100%">
	<label id="action" width="75%" text="Hello :3" />
	<hbox width="25%" height="100%">
		<box width="100%" />
		<hbox verticalAlign="center" style="margin-right: 12px;">
			<hbox width="62px">
				<image resource="icons/move-horizontal" verticalAlign="center" />
				<label id="pos-x" text="0" horizontalAlign="right" />
			</hbox>
			<hbox width="62px">
				<image resource="icons/move-vertical" verticalAlign="center" />
				<label id="pos-y" text="0" horizontalAlign="right" />
			</hbox>
		</hbox>
	</hbox>
</hbox>
')
class Status extends HBox {}
