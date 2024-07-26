#!/usr/bin/env python3
import subprocess
import json
import sys


def main():
    outs = []
    if len(sys.argv) < 2:
        raise ValueError("No version provided")
    version = sys.argv[1]
    systems = {
        "x86_64-linux-musl": "x86_64-linux",
        "aarch64-linux": "aarch64-linux",
        "x86_64-macos": "x86_64-darwin",
        "aarch64-macos": "aarch64-darwin",
    }
    for system in systems:
        url = f"https://github.com/kristoff-it/superhtml/releases/download/{version}/{system}.tar.gz"
        prefetch_hash_output = subprocess.run(
            ["nix-prefetch-url", f"{url}"], capture_output=True
        )
        prefetch_hash = prefetch_hash_output.stdout.decode("utf-8").strip("\n")
        res = {}
        res["hash"] = prefetch_hash
        res["binary_system"] = system
        res["name"] = systems[system]
        print(res)
        outs.append(res)

    with open("superhtml.json", "w") as f:
        json.dump(outs, f, indent=2)


if __name__ == "__main__":
    main()
