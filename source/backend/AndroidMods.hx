package backend;

#if android
import haxe.io.Path;
import lime.system.System;
import openfl.Assets;
import sys.FileSystem;
import sys.io.File;

/** Install packaged mod files where Psych's filesystem-based loaders can read them. */
class AndroidMods
{
	public static function prepare():Void
	{
		var root = Path.addTrailingSlash(System.applicationStorageDirectory);
		FileSystem.createDirectory(root);
		Sys.setCwd(root);
		var manifest = Assets.getText("android-mods-manifest.txt");
		var marker = ".bundled-mods-manifest";
		if (FileSystem.exists(marker) && File.getContent(marker) == manifest)
			return;

		for (line in manifest.split("\n"))
		{
			if (line.length == 0)
				continue;
			var relative = line.substr(65);
			var target = "mods/" + relative;
			FileSystem.createDirectory(Path.directory(target));
			// Write each file atomically; record completion only after all files succeed.
			File.saveBytes(target + ".installing", Assets.getBytes("bundled-mods/" + relative));
			FileSystem.rename(target + ".installing", target);
		}
		File.saveContent(marker, manifest);
	}
}
#end
