{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "adventofcode-2020";
  buildInputs = [ pkgs.zig ];
  COOKIE = "53616c7465645f5fd2181dbc4878870a99ccdc55245b276607a67eea8b06f7120050c8144e2bdc07f3fbd2da5440222e";
}
