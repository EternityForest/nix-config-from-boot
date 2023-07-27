# allow our nixpkgs import to be overridden if desired
{ pkgs ? import <nixpkgs> {} }:

# let's write an actual basic derivation
# this uses the standard nixpkgs mkDerivation function
pkgs.stdenv.mkDerivation {

  # name of our derivation
  name = "config-from-boot";

  # sources that will be used for our derivation.
  src = ./src;

  # see https://nixos.org/nixpkgs/manual/#ssec-install-phase
  # $src is defined as the location of our `src` attribute above
  installPhase = ''
    # $out is an automatically generated filepath by nix,
    # but it's up to you to make it what you need. We'll create a directory at
    # that filepath, then copy our sources into it.
    mkdir $out
    cp -rv $src/* $out
    chmod 555 $out/bin/config-from-boot
  '';

  nativeBuildInputs = [ pkgs.makeWrapper ];

  buildInputs = with pkgs; [
    python3
    nixos-rebuild
    busybox
    sudo
    fortune
    sl
  ];

  postFixup = ''
  wrapProgram $out/bin/config-from-boot \
    --set PATH ${pkgs.lib.makeBinPath (with pkgs; [
      python3
      nixos-rebuild
      busybox
      sudo
    ])}
    '';
}
