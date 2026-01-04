{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    # This line connects the theme to your shell
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
    };

    # These add the "extras" like syntax colors and auto-suggestions
    enableSyntaxHighlighting = true;
    enableAutosuggestions = true;
  };

  # You need to tell NixOS to actually use Zsh for your user
  users.users.terajaki.shell = pkgs.zsh;

  # This makes sure the "Arrow" symbols display correctly instead of boxes
  fonts.packages = with pkgs; [
    nerdfonts
  ];
}