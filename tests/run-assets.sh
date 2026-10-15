#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
asset_test_dir="$(mktemp -d)"
trap 'rm -rf "$asset_test_dir"' EXIT
haxe tests/assets.hxml -D MODS_ALLOWED --run AssetLoadingTest "$asset_test_dir"
