{ config, pkgs, inputs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Sam Bowman";
    userEmail = "sambow23@gmail.com";
  };
}
