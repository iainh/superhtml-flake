{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: 
      let
        version = "0.4.3";
        convertSystem = system:
        let
            jsonString = builtins.readFile ./superhtml.json;
            jsonData = builtins.fromJSON jsonString;
            matches = item: item.name == system;
            matched = builtins.filter matches jsonData;
            result = if builtins.length matched > 0 then let
                matchedItem = builtins.head matched;
            in {
                system = matchedItem.binary_system;
                hash = matchedItem.hash;
            } else abort "Unsupported system ${system}";
        in
            result;
        converted = convertSystem system;
        superhtml-binary = pkgs.stdenvNoCC.mkDerivation {
            name = "superhtml";
            inherit version;
            src = pkgs.fetchurl {
                url = "https://github.com/kristoff-it/superhtml/releases/download/v${version}/${converted.system}.tar.gz";
                sha256 = converted.hash;
            };
            unpackPhase = ''
                tar -xzf $src
            '';
            installPhase = ''
                mkdir -p $out/bin
                cp ${converted.system}/superhtml $out/bin
            '';
        };

      in{
        packages.default = superhtml-binary;
        devShells = {
            default = pkgs.mkShell {
                buildInputs = with pkgs; [python3 ];
            };
        };
      };
    };
}
