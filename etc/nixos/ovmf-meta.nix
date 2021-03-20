with import <nixpkgs> {};

# with this configuration, LXD will only support secureboot, which is the default

stdenv.mkDerivation rec {
  name = "ovmf-meta";
  buildCommand = ''
    mkdir -p $out
    cp ${pkgs.OVMF-secureBoot.fd}/FV/OVMF.fd $out/
    cp ${pkgs.OVMF-secureBoot.fd}/FV/OVMF_CODE.fd $out/
    cp ${pkgs.OVMF-secureBoot.fd}/FV/OVMF_VARS.fd $out/OVMF_VARS.ms.fd
  '';
}
