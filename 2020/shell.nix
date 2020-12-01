{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "adventofcode-2020";
  buildInputs = [ pkgs.zig ];
  COOKIE = "***REMOVED***";
}
