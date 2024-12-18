{...}: {
  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock
      "aghfnjkcakhmadgdomlmlhhaocbkloab" # black theme
      "dhdgffkkebhmkfjojejmpbldmpobfkfo" # tampermonkey for drag-and-freeze fix
    ];
    commandLineArgs = [
      #        "--use-angle=opengl" # ty novideo for the driver bugs <3
      "--enable-features=WebContentsForceDark,WebContentsForceDark:inversion_method/cielab_based/image_behavior/none/foreground_lightness_threshold/150/background_lightness_threshold/205"
      "--disable-smooth-scrolling"
      "--enable-gpu-rasterization"
      "--ignore-gpu-blocklist"
      ""
    ];
  };
}
