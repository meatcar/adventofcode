{
  description = "Advent of Code 2021";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, ... }@inputs:
    (inputs.flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = import inputs.nixpkgs { inherit system; }; in
        {
          devShell = pkgs.mkShell rec {
            name = "adventofcode-2021";
            buildInputs = [
              pkgs.nixFlakes
            ];
          };
        }));
}
