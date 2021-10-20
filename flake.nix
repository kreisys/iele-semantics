{
  description = "A Simple Flake™️";

  inputs.utils.url = "github:kreisys/flake-utils";

  outputs = { self, nixpkgs, utils }: utils.lib.simpleFlake {
    inherit nixpkgs;
    systems = [ "x86_64-darwin" "x86_64-linux" ];
    packages = { writeShellScriptBin }: rec {
      hello = writeShellScriptBin "hello" ''
        echo "hello world!"
      '';
      defaultPackage = builtins.trace self.modules hello;
    };
  };
}
