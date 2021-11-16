{
  description = "IELE Semantics";

  inputs.utils.url = "github:kreisys/flake-utils";

  outputs = { self, nixpkgs, utils }: utils.lib.simpleFlake {
    inherit nixpkgs;
    systems = [ "x86_64-darwin" "x86_64-linux" ];
    packages = { lib, writeShellScriptBin }: rec {
      hello = let
        src = builtins.fetchTree (builtins.trace self.modules.plugin self.modules.plugin);
        #split = lib.splitString "?" self.modules.plugin;
        #url = lib.head split;
        #rev = lib.last (lib.splitString "=" (lib.last split));
        #src = builtins.fetchTree {
        #  inherit url rev;
        #  submodules = true;
        #};
      in writeShellScriptBin "hello" ''
        echo ${src}
        echo "hello world!"
      '';
      defaultPackage = builtins.trace self.modules hello;
    };
  };
}
