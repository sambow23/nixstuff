{ config, pkgs, ... }:

let
  thoriumVersion = "123.0.6312.133";
  thoriumSrc = {
    x86_64-linux = "https://github.com/Alex313031/thorium/releases/download/M${thoriumVersion}/Thorium_Browser_${thoriumVersion}_AVX2.AppImage";
  };

  makeThorium = system: let
    name = "thorium";
    version = thoriumVersion;
    src = pkgs.fetchurl {
      url = thoriumSrc.${system};
      sha256 = "3e11490fd0214987336a402c3eca4fb42c36d57531aa576bf8793136a6e0b3fb";
    };
    appimageContents = pkgs.appimageTools.extractType2 { inherit name src; };
  in pkgs.appimageTools.wrapType2 {
    inherit name version src;
    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/thorium-browser.desktop $out/share/applications/thorium-browser.desktop
      install -Dm444 ${appimageContents}/thorium.png $out/share/icons/hicolor/512x512/apps/thorium.png
    '';
  };

  thorium_x86_64_linux = makeThorium "x86_64-linux";
in
{
  environment.systemPackages = with pkgs; [
    thorium_x86_64_linux
  ];
}
