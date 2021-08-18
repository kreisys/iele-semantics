{
  description = "A Simple Flake™️";

  inputs = {
    utils.url = "github:kreisys/flake-utils";

    kframework = {
      type = "git";
      url = "https://github.com/kreisys/k";
      submodules = true;
    };

    plugin = {
      type = "git";
      url = "https://github.com/runtimeverification/blockchain-k-plugin";
      submodules = true;
      flake = false;
      rev = "cc7384e565e4c8df4d17a3330cd9951d32d4830f";
    };

    k-web-theme = {
      type = "git";
      url = "https://github.com/runtimeverification/k-web-theme";
      submodules = true;
      flake = false;
      rev = "189fe6650488f8f04dc89d25a61cdfd888cd9dd8";
    };

    ethereum-tests = {
      type = "git";
      url = "https://github.com/ethereum/tests";
      submodules = true;
      flake = false;
      ref = "develop";
      rev = "7057d0e021f7dbee37a2ddb6acf34f4946bc157d";
    };

    secp256k1 = {
      type = "git";
      url = "https://github.com/bitcoin-core/secp256k1";
      submodules = true;
      flake = false;
      rev = "f532bdc9f77f7bbf7e93faabfbe9c483f0a9f75f";
    };
  };

  outputs =
  { self, nixpkgs, utils, kframework, plugin, k-web-theme, ethereum-tests, secp256k1 }:
    utils.lib.simpleFlake {
      inherit nixpkgs;
      systems = [ "x86_64-linux" ];

      packages = { system, runCommand }: let
        src = runCommand "src" { } ''
          cp -r ${self} $out
          chmod -R +w $_
    
          cp -r "${plugin}" $out/plugin
          cp -r "${k-web-theme}" $out/web/k-web-theme
          mkdir -p $out/.build
          cp -r "${secp256k1}" $_/secp256k1
          cp -r "${ethereum-tests}" $out/tests/ethereum-tests
        '';

      in rec {
        inherit (import src {
          inherit system;
          kframework = kframework.legacyPackages.${system};
        }) kiele kiele-assemble libff;
        defaultPackage = kiele;
      };

      shell =
        { mkShell
        , clang
        , protobuf
        , bashInteractive
        , cmake
        , cryptopp
        , gmp
        , procps
        , mpfr
        , opam
        , openssl
        , python
        , secp256k1
        , stack
        , pkgconfig
        , rapidjson
        , zlib
        , system
        }: mkShell rec {
          nativeBuildInputs = buildInputs;
          buildInputs =
            let
              inherit (kframework.legacyPackages.${system})
                k haskell-backend llvm-backend;

                inherit (self.legacyPackages.${system}) libff;
            in
            [
              clang
              cmake
              cryptopp
              gmp
              haskell-backend
              k
              libff
              llvm-backend
              mpfr
              opam
              openssl
              pkgconfig
              procps
              protobuf
              python
              rapidjson
              secp256k1
              stack
              zlib
            ];

          SHELL = "${bashInteractive}/bin/bash";
          shellHook = ''
            tail -n8 INSTALL.md
          '';

          SYSTEM_LIBFF = true;
          SYSTEM_LIBSECP256K1 = true;
          SYSTEM_LIBCRYPTOPP = true;
        };
    };
}
