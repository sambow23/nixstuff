{
  config,
  pkgs,
  inputs,
  ...
}: {
  sops.defaultSopsFile = ../../main/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/cr/.config/sops/age/keys.txt";
}
