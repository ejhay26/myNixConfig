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
        swww # for desktop wallpaper
        hyprshot # screenshot utility

        # Applications
        kitty
        nwg-displays # manage monitors
    ];
}

