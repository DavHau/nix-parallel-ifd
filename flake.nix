{
  description =
    "Demonstration of performance opportunities in IFD evaluation";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = {
    nixpkgs,
    self,
  }: let
    l = nixpkgs.lib // builtins;
    supportedSystems = [ "x86_64-linux" ];

    forAllSystems = f: l.genAttrs supportedSystems
      (system: f system nixpkgs.legacyPackages.${system});

    slowPackage = pkgs: num: pkgs.runCommand "slow-${num}" {} ''
      # Bring in impurity to trigger rebuild for demonstration purposes
      # ${builtins.getEnv "VAR"}

      sleep 10
      echo "${num}" > $out
    '';

  in {
    packages = forAllSystems (system: pkgs: {

      non-ifd = pkgs.runCommand "non-IFD" {} ''
        mkdir $out
        cp "${slowPackage pkgs "1"}" $out/1
        cp "${slowPackage pkgs "2"}" $out/2
        cp "${slowPackage pkgs "3"}" $out/3
      '';

      ifd = pkgs.runCommand "IFD" {} ''
        mkdir $out
        echo "${builtins.readFile (slowPackage pkgs "1")}" > $out/1
        echo "${builtins.readFile (slowPackage pkgs "2")}" > $out/2
        echo "${builtins.readFile (slowPackage pkgs "3'")}" > $out/3
      '';
    });
  };
}
