{
  description = "changeme";

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
            name = "changeme";
            buildInputs = with pkgs; [
              nodejs-18_x
            ];
          };
        }));
}
