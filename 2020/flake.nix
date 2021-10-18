{
  description = "Advent of Code 2020";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/21.05";
  };

  outputs = { self, ... }@inputs:
    (inputs.flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = import inputs.nixpkgs { inherit system; }; in
        {
          devShell = pkgs.mkShell rec {
            name = "adventofcode-2020";
            buildInputs = [ pkgs.zig ];
          };
        }));
}
