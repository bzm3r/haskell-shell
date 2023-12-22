# pkgs could from the derivation, or outside of it
{ name, cabalHomeBase, pkgs ? (import <nixpkgs> { }), ... }:
let
  sources = import ./npins;
  # A wrapper around `pkgs.stdenv.mkShell` that is almost a copy of it
  mkDevShell = pkgs.callPackage sources.mkDevShell {
    extraNativeBuildInputs = with pkgs; [ sd ];
  };
  CABAL_DIR = "${cabalHomeBase}/.cabal_${name}";
  CABAL_CONFIG = "${CABAL_DIR}/config";
  CABAL_BUILDDIR = "${CABAL_DIR}/build";
  shellInitialization = ''
    mkdir -p ${CABAL_BUILDDIR}
  '';
  shellCleanUp = ''
    rm -rf ${CABAL_DIR}
  '';
in mkDevShell (
  # The information defining our shell environment (which should be executed in
  # a user's shell, but for now I am hardcoding it as zsh (see the
  # customShellHook attribute).
  {
    # https://cabal.readthedocs.io/en/3.4/installing-packages.html
    inherit name CABAL_DIR CABAL_CONFIG CABAL_BUILDDIR shellInitialization
      shellCleanUp;

    # list of executable packages to add to the nix-shell dev env
    packages = with pkgs; [
      cabal2nix
      cabal-install
      ghc
      haskellPackages.zlib.out
      haskellPackages.zlib.doc
    ];

    IN_NIX_SHELL = "impure"; # these custom shells are impure by construction

    meta = {
      #homepage = "xyz";
      description =
        "Haskell development shell for integration with IDEs and personal experimentation. This is not meant to be an environment within which builds meant for distribution are produced.";
      #license = licenses.ofl;
      platforms = pkgs.lib.platforms.all;
      maintainers = [ ];
      mainProgram = name;
    };
  })
