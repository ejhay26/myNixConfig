{ config, pkgs, ... }:
{
    # packages used by Hyprland
    environment.systemPackages = with pkgs; [
        # Hyprland compositor
        hyprland

        # shell
        quickshell

        # Tools
        wlogout
        rofi
        rofi-calc
        rofi-emoji

        # Utilities
        wl-clipboard
        xdg-utils
        jq
        # hyprexpo = this is already defined in home.nix
        grim
        slurp
        swappy
        # mako = this is for notification, but I have quickshell
#         dunst
        brightnessctl
        pamixer
        playerctl
        networkmanagerapplet
        swww
        hyprshot

        # Applications
        kitty
        nwg-displays
    ];
}

