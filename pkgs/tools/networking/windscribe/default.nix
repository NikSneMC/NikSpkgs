{ 
  stdenv, 
  lib, 
  fetchurl,
  openssl,
  c-ares,
  libglvnd,
  curl,
  qtsvg,
  qt5compat,
  qtbase,
  qtwayland
}: stdenv.mkDerivation rec {
  name = "windscribe";
  version = "2.9.9";

  src = fetchurl {
    url = "https://github.com/Windscribe/Desktop-App/releases/download/v${version}/windscribe_${version}_amd64.deb";
    hash = "sha256-E/eiBDaFRsooqtg5bRU9CKoXbbJ7TVLY/yZRiREXIKo=";
  };
  sourceRoot = ".";
  unpackCmd = "dpkg-deb -x windscribe_${version}_amd64.deb .";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -R usr/share opt $out/
    # fix the path in the desktop file
    substituteInPlace \
      $out/share/applications/windscribe.desktop \
      --replace /opt/ $out/opt/
    # symlink the binary to bin/
    ln -s $out/opt/windscribe/Windscribe $out/bin/Windscribe
    ln -s $out/opt/windscribe/windscribe-authhelper $out/bin/windscribe-authhelper
    ln -s $out/opt/windscribe/windscribe-cli $out/bin/windscribe-cli
    ln -s $out/opt/windscribe/windscribectrld $out/bin/windscribectrld
    ln -s $out/opt/windscribe/windscribeopenpn $out/bin/windscribeopenvpn
    ln -s $out/opt/windscribe/windscribewireguard $out/bin/windscribewireguard
    ln -s $out/opt/windscribe/windscribewstunnel $out/bin/windscribewstunnel

    runHook postInstall
  '';
  preFixup = let
    # we prepare our library path in the let clause to avoid it become part of the input of mkDerivation
    libPath = {
      helper = lib.makeLibraryPath [
        stdenv.cc.cc.lib
        openssl
        c-ares
      ];
      Windscribe = lib.makeLibraryPath [
        libglvnd
        openssl
        c-ares
        curl
        qtsvg
        qt5compat
        qtbase
        qtwayland
        stdenv.cc.cc.lib
      ];
      windscribe-authhelper = lib.makeLibraryPath [
        stdenv.cc.cc.lib
        openssl
      ];
      windscribe-cli = lib.makeLibraryPath [
        stdenv.cc.cc.lib
        openssl
        qtbase
        qt5compat
      ];
      windscribectrld = lib.makeLibraryPath [

      ];
      windscribeopenvpn = lib.makeLibraryPath [

      ];
      windscribewireguard = lib.makeLibraryPath [

      ];
      windscribewstunnel = lib.makeLibraryPath [

      ];
    };
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath.helper}" \
      $out/opt/windscribe/helper

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath.Windscribe}" \
      $out/opt/windscribe/Windscribe

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath.windscribe-authhelper}" \
      $out/opt/windscribe/windscribe-authhelper

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath.windscribe-cli}" \
      $out/opt/windscribe/windscribe-cli

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath.windscribectrld}" \
      $out/opt/windscribe/windscribectrld

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath.windscribeopenvpn}" \
      $out/opt/windscribe/windscribeopenvpn

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath.windscribewireguard}" \
      $out/opt/windscribe/windscribewireguard

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath.windscribewstunnel}" \
      $out/opt/windscribe/windscribewstunnel
  '';

  meta = with lib; {
    homepage = https://windscribe.com;
    description = "Browse the web privately as it was meant to be";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [ NikSne ];
  };
}