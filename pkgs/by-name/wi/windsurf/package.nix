{
  lib,
  stdenv,
  callPackage,
  fetchurl,
  nixosTests,
  commandLineArgs ? "",
  useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin,
}:
callPackage ../../../applications/editors/vscode/generic.nix (let
  info = builtins.fromJSON (builtins.readFile ./info.json);
in rec {
  inherit commandLineArgs useVSCodeRipgrep;

  pname = "windsurf";
  version = info.windsurfVersion;

  executableName = pname;
  longName = "Windsurf";
  shortName = pname;

  src = fetchurl {
    inherit (info) url;
    sha256 = info.sha256hash;
  };

  sourceRoot = "Windsurf";

  tests = nixosTests.vscodium;

  updateScript = ./update.py;

  meta = with lib; {
    description = "The first agentic IDE, and then some";
  };
})
