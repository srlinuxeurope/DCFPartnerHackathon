#!/usr/bin/env python3
"""
Sync selected README.md files (and referenced images) from
https://github.com/srl-labs/containerlab-workshop-ch into docs/workshop/_vendor
so MkDocs can build locally without fetching from GitHub at build time.

- Copies the following module READMEs:
  README.md
  05-install/README.md
  10-basics/README.md
  15-startup/README.md
  20-vm/README.md
  30-askai/README.md
  40-streaming-telemetry/README.md
  50-clab-vscode-extension/README.md

- Downloads images referenced by those README files if they use relative paths.

Run:
  python tools/sync_workshop.py

This script uses only the standard library.
"""
from __future__ import annotations

import os
import re
from pathlib import Path, PurePosixPath
from urllib.parse import urlparse
from urllib.request import urlopen

REPO = "srl-labs/containerlab-workshop-ch"
REF = "main"
RAW_BASE = f"https://raw.githubusercontent.com/{REPO}/{REF}/"

# Modules to sync relative to repo root
MODULE_READMES = [
	"README.md",
	"05-install/README.md",
	"10-basics/README.md",
	"15-startup/README.md",
	"20-vm/README.md",
	"30-askai/README.md",
	"40-streaming-telemetry/README.md",
	"50-clab-vscode-extension/README.md",
]

# File extensions considered as assets to fetch when referenced relatively
ASSET_EXTS = {".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp", ".bmp", ".ico"}

# Markdown image: ![alt](url)
IMG_MD_RE = re.compile(r"!\[[^\]]*\]\(([^)]+)\)")
# HTML image: <img src="url" ...>
IMG_HTML_RE = re.compile(r"<img[^>]+src=\"([^\"]+)\"")


def _repo_root() -> Path:
	# tools/sync_workshop.py -> repo root is two parents up
	here = Path(__file__).resolve()
	return here.parent.parent


def _fetch(url: str) -> bytes:
	with urlopen(url) as resp:
		return resp.read()


def _write(path: Path, data: bytes) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	with open(path, "wb") as f:
		f.write(data)


def _is_url(s: str) -> bool:
	try:
		return bool(urlparse(s).scheme)
	except Exception:
		return False


def _norm_posix(path: str) -> str:
	return str(PurePosixPath(path))


def _download_asset_if_needed(vendor_root: Path, module_path: str, rel_url: str) -> None:
	# Skip anchors or data URIs
	if rel_url.startswith("#") or rel_url.startswith("data:"):
		return
	# Only handle relative paths (no scheme)
	if _is_url(rel_url):
		return
	# Only known asset types
	# Strip query/fragment
	ext = os.path.splitext(rel_url.split("?")[0].split("#")[0])[1].lower()
	if ext not in ASSET_EXTS:
		return

	base_dir = PurePosixPath(module_path).parent
	asset_repo_rel = _norm_posix(base_dir.joinpath(rel_url))
	dest_path = vendor_root / asset_repo_rel
	if dest_path.exists():
		return

	raw_url = RAW_BASE + asset_repo_rel
	try:
		data = _fetch(raw_url)
		_write(dest_path, data)
		print(f"Downloaded asset: {asset_repo_rel}")
	except Exception as e:
		print(f"WARN: failed to download asset {raw_url}: {e}")


def _extract_image_links(markdown: str) -> list[str]:
	links = []
	links += [m.group(1).strip() for m in IMG_MD_RE.finditer(markdown)]
	links += [m.group(1).strip() for m in IMG_HTML_RE.finditer(markdown)]
	return links


def sync_module(vendor_root: Path, module_readme_path: str) -> None:
	repo_rel = _norm_posix(module_readme_path)
	raw_url = RAW_BASE + repo_rel
	print(f"Syncing {repo_rel}")
	data = _fetch(raw_url)
	text = data.decode("utf-8", errors="replace")

	# Download assets referenced by relative paths
	for link in _extract_image_links(text):
		_download_asset_if_needed(vendor_root, repo_rel, link)

	# Write README itself
	dest = vendor_root / repo_rel
	_write(dest, text.encode("utf-8"))


if __name__ == "__main__":
	root = _repo_root()
	vendor_root = root / "docs" / "workshop" / "_vendor"
	vendor_root.mkdir(parents=True, exist_ok=True)

	for module in MODULE_READMES:
		sync_module(vendor_root, module)

	print("\nDone. Local copies are in docs/workshop/_vendor.\n")
	print("If you haven't yet, pages should include local copies, e.g.:")
	print("  --8<-- \"workshop/_vendor/05-install/README.md\"")

