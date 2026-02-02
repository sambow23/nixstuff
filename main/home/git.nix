{...}: {
  programs.git = {
    enable = true;
    settings = {
      user.name = "Sam Bowman";
      user.email = "sambow23@gmail.com";
      };
  };
}
