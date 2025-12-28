{
  pkgs ? import <nixpkgs> { },
  system ? builtins.currentSystem,
  superhtml,
}:
let
  inherit (pkgs) lib;
in
{
  "default" = pkgs.stdenv.mkDerivation {
    name = "superhtml";
    src = superhtml;
    nativeBuildInputs = with pkgs; [ zig ];
    buildPhase = ''
      export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
      zig build -Doptimize=ReleaseSafe --prefix $out
    '';
    installPhase = ''
      true
    '';
  };
}
