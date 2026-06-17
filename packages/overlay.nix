final: prev: {
  feishin = final.callPackage ./feishin.nix {};
  mesa-git = final.callPackage ./mesa-git.nix {mesa = prev.mesa;};
  sunshine = final.callPackage ./sunshine.nix {
    sunshine = prev.sunshine;
  };
}
