{
  config,
  pkgs,
  inputs,
  ...
}: {
  # TODO please change the username & home directory to your own
  home.username = "cr";
  home.homeDirectory = "/home/cr";


  imports = [
    ./plasma/plasma.nix
  ];

  home.packages = with pkgs; [
    zip
    xz
    unzip
    p7zip
    eza
    mtr
    iperf3
    dnsutils
    ldns
    aria2
    nmap
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
    lsof
    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils
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
