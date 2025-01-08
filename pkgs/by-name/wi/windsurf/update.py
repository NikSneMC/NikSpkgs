#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3 python3.pkgs.requests
from json import load, dump
from requests import get


def main() -> None:
    info = get("https://windsurf-stable.codeium.com/api/update/linux-x64/stable/latest").json()
    with open(file="./info.json", mode="r", encoding="utf-8") as f:
        info_old = load(f)
    if info["windsurfVersion"] == info_old["windsurfVersion"]:
        return
    print(f"Found new version: {info['windsurfVersion']}")
    with open(file="./info.json", mode="w", encoding="utf-8") as f:
        dump(info, f, indent=4)


if __name__ == "__main__":
    main()
