import backend.Mods;
import backend.Paths;
import backend.StageData;
import haxe.Json;
import haxe.io.Path;
import objects.Character;
import openfl.utils.AssetLibrary;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

class AssetLoadingTest
{
	static var checks:Int = 0;

	static function main()
	{
		if (Sys.args().length != 1)
			throw 'Pass an empty temporary directory for the simulated app storage.';

		// Register real project JSON as packaged assets, then leave the source checkout.
		var library = new AssetLibrary();
		var bf = File.getContent('assets/shared/characters/bf.json');
		var gf = File.getContent('assets/shared/characters/gf.json');
		var stage = File.getContent('assets/shared/stages/stage.json');
		for (id => text in [
			'assets/shared/characters/bf.json' => bf,
			'assets/shared/characters/gf.json' => gf,
			'assets/shared/stages/stage.json' => stage
		])
		{
			@:privateAccess library.types.set(id, lime.utils.AssetType.TEXT);
			@:privateAccess library.cachedText.set(id, text);
		}
		Assets.registerLibrary('default', library);
		Sys.setCwd(Sys.args()[0]);
		Paths.currentLevel = null;
		Mods.currentModDirectory = '';

		expect(FileSystem.exists('assets/shared/characters/bf.json'), false, 'BF is not a disk file');
		expect(FileSystem.exists('assets/shared/stages/stage.json'), false, 'stage is not a disk file');
		expect(Character.getCharacterFile('bf').image, Json.parse(bf).image, 'packaged BF');
		expect(Character.getCharacterFile('gf').image, Json.parse(gf).image, 'packaged GF retains its own definition');
		expect(Character.getCharacterFile('missing-character').image, Json.parse(bf).image, 'missing character uses packaged BF');
		expect(StageData.getStageFile('stage').defaultZoom, Json.parse(stage).defaultZoom, 'packaged stage');
		expect(StageData.getStageFile('missing-stage'), null, 'missing stage keeps dummy fallback');
		StageData.loadDirectory(cast {stage: 'stage'});
		expect(StageData.forceNextDirectory, Json.parse(stage).directory, 'packaged stage directory');

		#if MODS_ALLOWED
		var modCharacter = Json.parse(gf);
		modCharacter.image = 'root-mod-character';
		write('mods/characters/gf.json', Json.stringify(modCharacter));
		expect(Character.getCharacterFile('gf').image, modCharacter.image, 'root mod overrides packaged character');

		var modStage = Json.parse(stage);
		modStage.directory = 'mod-stage-assets';
		write('mods/stages/stage.json', Json.stringify(modStage));
		expect(StageData.getStageFile('stage').directory, modStage.directory, 'root mod overrides packaged stage');
		StageData.loadDirectory(cast {stage: 'stage'});
		expect(StageData.forceNextDirectory, modStage.directory, 'mod stage directory');

		modCharacter.image = 'selected-mod-character';
		modStage.directory = 'selected-mod-assets';
		write('mods/selected/characters/gf.json', Json.stringify(modCharacter));
		write('mods/selected/stages/stage.json', Json.stringify(modStage));
		Mods.currentModDirectory = 'selected';
		expect(Character.getCharacterFile('gf').image, modCharacter.image, 'selected mod takes priority over root');
		expect(StageData.getStageFile('stage').directory, modStage.directory, 'selected stage takes priority over root');
		Mods.currentModDirectory = '';

		write('mods/characters/bf.json', Json.stringify(modCharacter));
		expect(Character.getCharacterFile('missing-character').image, Json.parse(bf).image, 'default BF fallback remains built-in');
		write('mods/characters/mod-only.json', Json.stringify(modCharacter));
		write('mods/stages/mod-only.json', Json.stringify(modStage));
		expect(Character.getCharacterFile('mod-only').image, modCharacter.image, 'mod-only character');
		expect(StageData.getStageFile('mod-only').directory, modStage.directory, 'mod-only stage');

		// Keep desktop loose-file compatibility as well as the packaged-asset path.
		write('assets/shared/characters/loose.json', gf);
		write('assets/shared/stages/loose.json', stage);
		expect(Character.getCharacterFile('loose').image, Json.parse(gf).image, 'loose shared character');
		expect(StageData.getStageFile('loose').defaultZoom, Json.parse(stage).defaultZoom, 'loose shared stage');
		#end

		Sys.println('Asset loading: ' + checks + ' checks passed (mods ' + #if MODS_ALLOWED 'enabled' #else 'disabled' #end + ').');
	}

	static function write(path:String, text:String)
	{
		FileSystem.createDirectory(Path.directory(path));
		File.saveContent(path, text);
	}

	static function expect(actual:Dynamic, expected:Dynamic, label:String)
	{
		if (actual != expected)
			throw label + ': expected ' + expected + ', got ' + actual;
		checks++;
	}
}
