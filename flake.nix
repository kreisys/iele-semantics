{
  description = "IELE Semantics";

  outputs = { self, nixpkgs }: let
    combineModules = { lib, runCommand, input }: let
      inherit (lib) concatStringsSep mapAttrs mapAttrsToList pipe;
    in runCommand  "src-with-submodules" {} ''
      cp -r ${input} $out
      chmod -R +w $_

      ${
        pipe input.modules [
          (mapAttrs (_: url: fetchTree url))
          (mapAttrsToList (path: src: "cp -rT ${src} $out/${path}"))
          (concatStringsSep "\n")
        ]
      }
    '';
  in {
    packages.x86_64-linux.src-with-submodules = combineModules {
      inherit (nixpkgs) lib;
      inherit (nixpkgs.legacyPackages.x86_64-linux) runCommand;
      input = self;
    };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.src-with-submodules;
  };
}
