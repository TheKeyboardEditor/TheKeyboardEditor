package;

import ceramic.Entity;
//import ceramic.Dialogs;

class FileDialog extends Entity {
	@event function fileLoaded(body: String);

	public function openJson(title: String) {
		#if web
		var input: js.html.InputElement = cast js.Browser.document.createElement("input");
		input.type = "file";
		input.accept = ".json";

		input.onchange = () -> {
			var reader = new js.html.FileReader();
			reader.readAsText(input.files[0]);
			reader.onloadend = () -> {
				emitFileLoaded(reader.result);
			};
		};

		input.click();
		#else
		//Dialogs.openFile(title, [{name: title, extensions: ["json"]}], (file) -> {
		//	StatusBar.error("Not implemented");
		//	// emitFileLoaded(file);
		//});
		#end
	}

	public static function download(content: String, fileName: String, contentType: String = "text/plain") {
		#if web
		final file = new js.html.Blob([content], {type: contentType});
		var a: js.html.AnchorElement = cast js.Browser.document.createElement("a");
		a.href = js.html.URL.createObjectURL(file);
		a.download = fileName;
		if (contentType == "application/json") {
			a.download += ".json";
		}
		a.click();
		StatusBar.inform('Downloaded');
		#elseif sys
		//Dialogs.saveFile(fileName, null, (file: String) -> {
		//	sys.io.File.saveContent(file, content);
		//	StatusBar.inform('Saved to $file');
		//});
		#else
		throw "Not Implemented";
		#end
	}
}
