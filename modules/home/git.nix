{ config, lib, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "ejhay26";
    userEmail = "ejperez623@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
