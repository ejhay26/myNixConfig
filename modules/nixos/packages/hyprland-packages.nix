{ config, inputs, pkgs, ... }:
{
    # packages used by Hyprland
    environment.systemPackages = with pkgs; [
        # shell
        quickshell

        # Tools
        wlogout
        rofi
        rofi-calc
        rofi-emoji

        # Utilities
        wl-clipboard
        cliphist
        xdg-utils
        jq
        # hyprexpo = this is already defined in home.nix
        grim # screenshot utility
        slurp
        swappy # screenshot editor
        # mako = this is for notification, but I have quickshell
#         dunst
        brightnessctl
        pamixer
        pavucontrol
        playerctl
        networkmanagerapplet
        awww # for desktop wallpaper
        hyprshot # screenshot utility

        # Applications
        kitty
        alacritty
        nwg-displays # manage monitors
  ]; #++ [  
    #   inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
    #   inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo

  
  #];
}
