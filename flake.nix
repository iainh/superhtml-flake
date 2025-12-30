{
  description = "superhtml flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    superhtml = {
      url = "github:iainh/superhtml/driver";
      flake = false;
    };
  };

  outputs = { nixpkgs, zig-overlay, superhtml, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          zig = zig-overlay.packages.${system}.default;
        in
        {
          default = pkgs.stdenv.mkDerivation {
            name = "superhtml";
            src = superhtml;
            nativeBuildInputs = [ zig ];
            dontConfigure = true;
            dontInstall = true;
            buildPhase = ''
              export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
              zig build -Doptimize=ReleaseSafe --prefix $out
            '';
          };
        });

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = [ pkgs.python3 ];
          };
        });
    };
}
