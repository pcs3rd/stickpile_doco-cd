{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [ sops age nano lazydocker ];


  shellHook = ''
    alias test="echo 'test'"
    alias ll="ls -alF"
  '';
}

