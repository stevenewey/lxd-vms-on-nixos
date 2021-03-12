with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "lxd-agent";
  src = fetchurl {
    url = https://github.com/stevenewey/lxd-vms-on-nixos/raw/master/lxd-agent/lxd-agent;
    sha256 = "4c17cb711a95b7d2fd1ec90f02f94ec0b4bbd89e556e188576ece66f91666bb7";
  };
  buildCommand = ''
    mkdir -p $out/bin
    cp $src $out/bin/lxd-agent
    chmod +x $out/bin/lxd-agent
  '';
}
