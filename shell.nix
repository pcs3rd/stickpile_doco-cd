{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [ sops age nano lazydocker curl ];


  shellHook = ''
    alias swarm-deploy=" docker stack deploy doco-cd --compose-file compose.yaml -d && lazydocker"
    alias kickstart="curl -H \"x-api-key: $(cat /stateful/sys-data/secrets/ws-secret.txt)\" \"http://localhost:1099/v1/api/v1/webhook/$1\""
  '';
}

