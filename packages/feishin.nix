{ lib
, stdenv
, fetchurl
, appimageTools
}:

let
  pname = "feishin";
  version = "1.4.2";
  
  sources = {
    x86_64-linux = {
      url = "https://github.com/jeffvli/feishin/releases/download/v${version}/Feishin-linux-x86_64.AppImage";
      sha256 = "163rjxipfj76zp36n8l0x7d1abd0bqkgwc4hx2r6qn12vssm7lg7";
    };
    aarch64-linux = {
      url = "https://github.com/jeffvli/feishin/releases/download/v${version}/Feishin-linux-arm64.AppImage";
      sha256 = "0622nrmk7ag8g5xvh26vpbc95vzagx8122nnmhajvsrwhjhwb5kc";
    };
  };

  src = fetchurl (sources.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}"));
  
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Install desktop file
    install -m 444 -D ${appimageContents}/feishin.desktop $out/share/applications/feishin.desktop
    
    # Install icon
    install -m 444 -D ${appimageContents}/feishin.png $out/share/pixmaps/feishin.png
    
    # Fix desktop file paths
    substituteInPlace $out/share/applications/feishin.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}' \
      --replace-fail 'Icon=feishin' 'Icon=${pname}'
  '';

  meta = with lib; {
    description = "A modern self-hosted music player";
    longDescription = ''
      Feishin is a modern music player for self-hosted music servers.
      Supports Jellyfin, Navidrome, and other Subsonic-compatible servers.
    '';
    homepage = "https://github.com/jeffvli/feishin";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "feishin";
    maintainers = [ ];
  };
}
