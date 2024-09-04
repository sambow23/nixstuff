{ config, pkgs, inputs, ... }:

{
  home.username = "cr";
  home.homeDirectory = "/home/cr";

  home.packages = with pkgs; [
    neofetch
    zip
    xz
    unzip
    p7zip
    ripgrep
    jq
    yq-go
    eza
    fzf
    mtr
    iperf3
    dnsutils
    ldns
    aria2
    socat
    nmap
    ipcalc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    nix-output-monitor
    hugo
    glow
    btop
    iotop
    iftop
    strace
    ltrace
    lsof
    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils
    swaylock
    swayidle
    wl-clipboard
    mako
    alacritty
    rofi
    slurp
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Sam Bowman";
    userEmail = "sambow23@gmail.com";
  };

  # YEAH BABYY CHROME
  programs.chromium = {
    enable = true;
    extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock
        "aghfnjkcakhmadgdomlmlhhaocbkloab" # black theme
        "mfmhdfkinffhnfhaalnabffcfjgcmdhl" # scroll speed fix cuz fuck hyprland am i right
      ];
    commandLineArgs = [
        "--use-angle=opengl" # ty novideo for the driver bugs <3
        "--enable-features=WebContentsForceDark,WebContentsForceDark:inversion_method/cielab_based/image_behavior/none/foreground_lightness_threshold/150/background_lightness_threshold/205"
        "--disable-smooth-scrolling"
      ];
  };

  gtk = {
    enable = true;
    iconTheme = {
    name = "Arc";
    package = pkgs.arc-icon-theme;
  };
  theme = {
    name = "Tokyonight-Dark";
    package = pkgs.tokyonight-gtk-theme;
  };
};
  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";



  programs.nixvim.enable = true;

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
