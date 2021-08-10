{
  description = "A Simple Flake™️";

  inputs.utils.url = "github:kreisys/flake-utils";

  outputs = { self, nixpkgs, utils }: utils.lib.simpleFlake {
    inherit nixpkgs;
    systems = [ "x86_64-darwin" "x86_64-linux" ];
    overlay = final: prev: {
      # This just fills in `system`. the flake's nixpkgs
      # isn't actually being used.
      inherit (final.callPackages ./. {}) kiele kiele-assemble;
    };

    packages = { kiele, kiele-assemble }: rec {
      inherit kiele kiele-assemble;
      defaultPackage = kiele;
    };
  };
}
