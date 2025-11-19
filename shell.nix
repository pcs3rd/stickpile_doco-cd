{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [ sops age nano lazydocker ];


  shellHook = ''
    alias deploy=" docker stack deploy doco-cd --compose-file compose.yaml -d && lazydocker"
    alias undeploy="docker stack rm doco-cd"
  '';
}

