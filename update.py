#!/usr/bin/env python3
import subprocess
import json
import sys
from pathlib import Path
from collections import OrderedDict


def main():
    filename = "superhtml.json"
    outs = {}
    if len(sys.argv) < 2:
        raise ValueError("No version provided")
    version = sys.argv[1]
    data = {}
    if (Path.cwd() / filename).exists():
        with open(filename, "r") as f:
            data = json.load(f)
            if version in data:
                print(f"Version {version} already exists")
                exit()

    systems = {
        "x86_64-linux-musl": "x86_64-linux",
        "aarch64-linux": "aarch64-linux",
        "x86_64-macos": "x86_64-darwin",
        "aarch64-macos": "aarch64-darwin",
    }
    item = {}
    for system in systems:
        url = f"https://github.com/kristoff-it/superhtml/releases/download/{version}/{system}.tar.gz"
        prefetch_hash_output = subprocess.run(
            ["nix-prefetch-url", f"{url}"], capture_output=True
        )
        prefetch_hash = prefetch_hash_output.stdout.decode("utf-8").strip("\n")
        print(f"Hash {prefetch_hash} for system {system}")
        res = {}
        res["hash"] = prefetch_hash
        res["version"] = version
        res["url"] = url
        res["downloaded-system"] = system
        item[systems[system]] = res
    outs[version] = item

    with open(filename, "w") as f:
        if data != {}:
            data.update(outs)
            ordered_data = OrderedDict(sorted(data.items(), reverse=True))
            json.dump(ordered_data, f, indent=2)
        else:
            json.dump(outs, f, indent=2)


if __name__ == "__main__":
    main()
