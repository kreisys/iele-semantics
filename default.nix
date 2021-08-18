{ sources ? import ./nix/sources.nix { inherit system; }
, pkgs ? import sources."nixpkgs" { inherit system; }
, system ? builtins.currentSystem
, release ? null
, src ? ./.
, kframework ?
    let release_ = release; in
    let
      release = if release_ == null then pkgs.stdenv.isLinux else false;
      tag = pkgs.lib.fileContents ./deps/k_release;
      url = "https://github.com/kframework/k/releases/download/${tag}/release.nix";
      args = import (builtins.fetchurl {
        inherit url;
        sha256 = "sha256:16axhma1r6kvmppbdcwnbp12v5sxcwq6k091bkd8gi65znf68d1g";
      });
      # src = pkgs.fetchgit args;
      src = builtins.fetchGit {
        url = "https://github.com/kreisys/k";
        submodules = true;
        rev = "b9cb57a6f319e2f84d3feace2b372dd5fe9df562";
      };
    in import src { inherit release system; }
}:


let
  inherit (pkgs) lib;
  ttuegel = import sources."nix-lib" { inherit pkgs; };


  inherit (kframework) k haskell-backend llvm-backend clang;
  llvmPackages = pkgs.llvmPackages_10;
  src' = src;
in

let
  inherit (pkgs) callPackage;
in

let
  src = ttuegel.cleanGitSubtree {
    name = "iele-semantics";
    src = src';
  };
  libff = callPackage ./nix/libff.nix {
    stdenv = llvmPackages.stdenv;
    src = ttuegel.cleanGitSubtree {
      name = "libff";
      src = src';
      subDir = "plugin/deps/libff";
    };
  };
  kiele = callPackage ./nix/kiele.nix {
    inherit src;
    inherit (ttuegel) cleanSourceWith;
    inherit libff;
    inherit k haskell-backend llvm-backend clang;
    inherit (pkgs.python2Packages) python;
    inherit (iele-assemble) iele-assemble;
  };
  iele-assemble = import ./iele-assemble { inherit system; };

  default =
    {
      inherit kiele libff clang;
      inherit (iele-assemble) iele-assemble;
    };

in default
