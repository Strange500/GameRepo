# Compute NPM Dependencies Hash
#
# This file can be used to compute the npmDepsHash for the flake.nix
# Run: nix-build compute-npm-hash.nix
# The build will fail with the correct hash to use

{ pkgs ? import <nixpkgs> {} }:

pkgs.buildNpmPackage {
  pname = "game-catalogue-deps";
  version = "1.0.0";
  
  src = ./.;
  
  npmDepsHash = pkgs.lib.fakeHash;
  npmFlags = [ "--legacy-peer-deps" ];
  
  dontBuild = true;
  installPhase = "echo 'Use the hash from the error message above'";
}
