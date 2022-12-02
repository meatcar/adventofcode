{
  description = "Advent of Code 2022";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, ... }@inputs:
    (inputs.flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
          erlang = pkgs.erlangR25;
          epkgs = pkgs.beam.packagesWith erlang;
        in
        {
          devShells.default = pkgs.mkShell rec {
            YEAR = 2022;
            name = "aoc-${toString YEAR}";
            _PATH = "./bin";
            buildInputs = [
              (pkgs.writeShellScriptBin "run" ''
                DAY=$(printf '%02d' "$1")
                bin/cache-input "$1"
                test -f "days/$DAY.exs" && elixir "days/$DAY.exs"
              '')
              epkgs.elixir_1_14
              epkgs.elixir_ls
            ];
          };
        }));
}
