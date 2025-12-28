{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    superhtml.url = "github:iainh/superhtml";
    superhtml.flake = false;
  };

  outputs = inputs@{ flake-parts, superhtml, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { pkgs, system, ... }: 
      {
        packages = import ./default.nix {inherit system pkgs superhtml;};
        devShells = {
            default = pkgs.mkShell {
                buildInputs = with pkgs; [python3 ];
            };
        };
      };
    };
}
