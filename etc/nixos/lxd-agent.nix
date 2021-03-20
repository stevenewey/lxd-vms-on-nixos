with import <nixpkgs> {};

stdenv.mkDerivation buildGoPackage rec {
  name = "lxd-agent";
  version = "4.5";  # modify the version if using newer LXD

  goPackagePath = "github.com/lxc/lxd";

  buildFlags = [ "-ldflags=-extldflags=-static" "-ldflags=-s" "-ldflags=-w" "-tags libsqlite3" ];

  src = fetchurl {
    url = "https://github.com/lxc/lxd/releases/download/lxd-${version}/lxd-${version}.tar.gz";
    sha256 = "1nszzcyn8kvpnxppjbxky5x9a8n0jfmhy20j6nrwm3196gd6hirr";  # update this when changing LXD version
  };

  subPackages = [ "lxd-agent" ];

  preConfigure = ''
    export CGO_ENABLED=0
  '';

  postPatch = ''
    substituteInPlace shared/usbid/load.go \
      --replace "/usr/share/misc/usb.ids" "${hwdata}/share/hwdata/usb.ids"
  '';

  preBuild = ''
    # unpack vendor
    pushd go/src/github.com/lxc/lxd
    rm _dist/src/github.com/lxc/lxd
    cp -r _dist/src/* ../../..
    popd
  '';
}
