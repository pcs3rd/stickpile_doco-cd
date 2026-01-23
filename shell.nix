{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [ sops age nano lazydocker curl ];


  shellHook = ''
    alias swarm-deploy=" docker stack deploy doco-cd --compose-file compose.yaml -d && lazydocker"
  '';
}

