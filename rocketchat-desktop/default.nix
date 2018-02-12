{ stdenv, lib, fetchurl, alsaLib, atk, cairo, cups, dbus, dpkg, expat, ffmpeg, fontconfig, freetype, gdk_pixbuf, glib, gnome3, gtk2, nspr, nss, pango, patchelf, xorg, makeWrapper, systemd}:
let
  version = "2.10.5";
  hashSums = {
    "amd64" = "10zmvnavk24wdxrqq91fqw49wz9ll6r67k23plik4rm18j6f6zch";
    "i386" = "0000000000000000000000000000000000000000000000000000000000000000";
  };

  mkSrc = version: let
    _arch = {
      "x86_64-linux" = "amd64";
      "i686-linux" = "i386";
    }.${stdenv.system};
    sha256 = hashSums."${_arch}";
  in fetchurl {
    inherit sha256;
    url = "https://github.com/RocketChat/Rocket.Chat.Electron/releases/download/${version}/rocketchat_${version}_${_arch}.deb";
  };
  src = mkSrc version;

  libPath = lib.makeLibraryPath [
    alsaLib
    atk
    cairo
    cups.lib
    dbus.lib
    expat
    ffmpeg
    fontconfig.lib
    freetype
    gdk_pixbuf
    glib
    glib
    gnome3.gconf
    gtk2
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
  ];

in stdenv.mkDerivation {
  name = "rocketchat-desktop-${version}";


  nativeBuildInputs = [ dpkg patchelf makeWrapper ];

  unpackPhase = ''
    dpkg-deb -x ${src} ./
    find .
  '';

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -av opt $out/opt
    cp -av usr/* $out/.
  '';

  postFixup = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$out/opt/Rocket.Chat+/rocketchat"
    wrapProgram $out/opt/Rocket.Chat+/rocketchat \
      --prefix LD_LIBRARY_PATH : "${libPath}"
    ln -s $out/opt/Rocket.Chat+/rocketchat $out/bin/rocketchat
  '';
}
