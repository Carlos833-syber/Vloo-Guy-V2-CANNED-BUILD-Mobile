#!/usr/bin/env python3
"""Generate a deterministic manifest for app-private mod installation."""
import hashlib
from pathlib import Path

root = Path(__file__).resolve().parents[1]
files = {
    path.relative_to(root / "example_mods").as_posix(): path
    for path in (root / "example_mods").rglob("*")
    if path.is_file() and path.suffix != ".hx"
}
files["performance/stages/performance.lua"] = root / "source/android/performance.lua"
manifest = "".join(
    f"{hashlib.sha256(path.read_bytes()).hexdigest()} {name}\n"
    for name, path in sorted(files.items())
)
out = root / ".android-assets"
out.mkdir(exist_ok=True)
(out / "mods-manifest.txt").write_text(manifest, encoding="utf-8")
print(f"Prepared {len(files)} Android mod assets")
