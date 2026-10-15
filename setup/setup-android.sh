#!/usr/bin/env bash
set -euo pipefail
# Haxe 4.3.2; intentionally separate from the floating desktop hmm.json.
haxelib install lime 8.1.2 --quiet
haxelib install openfl 9.3.3 --quiet
haxelib install flixel 5.6.2 --quiet
haxelib install flixel-addons 3.2.2 --quiet
haxelib install flixel-ui 2.6.1 --quiet
haxelib install hxcpp 4.3.2 --quiet
haxelib install hxCodec 3.0.2 --quiet
haxelib install tjson 1.4.0 --quiet
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit daf0664aee99aa8b8d6bdd1eda993a1c3a399067 --quiet
# Dependencies can select newer transitive versions; restore the build's versions.
haxelib set lime 8.1.2
haxelib set openfl 9.3.3
haxelib set flixel 5.6.2
haxelib set flixel-addons 3.2.2
haxelib set flixel-ui 2.6.1
haxelib set hxcpp 4.3.2
haxelib set hxCodec 3.0.2
haxelib set tjson 1.4.0
python3 setup/prepare-android.py
