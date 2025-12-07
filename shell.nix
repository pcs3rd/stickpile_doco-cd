{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [ sops age nano lazydocker ];


  shellHook = ''
    alias swarm-deploy=" docker stack deploy doco-cd --compose-file compose.yaml -d && lazydocker"
    alias swarm-undeploy="docker stack rm doco-cd"
    alias svls="docker network create --driver overlay traefik_backbone && docker service ps $(docker service ls -q) --no-trunc"
    alias rasv="docker service rm $(docker service ls -q)"
  '';
}

