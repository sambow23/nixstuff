{
  config,
  pkgs,
  inputs,
  ...
}: {
  # TODO please change the username & home directory to your own
  home.username = "cr";
  home.homeDirectory = "/home/cr";

  # imports = [
  #   ../../wm/niri.nix
  # ];

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    zip
    xz
    unzip
    p7zip
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
    btop
    iotop
    iftop
    strace
    ltrace
    lsof
    sysstat
    lm_sensors
    ethtool
    pciutil
    usbutils
    alacritty
    fuzzel
    swaylock
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Sam Bowman";
    userEmail = "sambow23@gmail.com";
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
