{ config, pkgs, inputs, lib,... }:

let
  # Script to toggle a window to/from the special "minimized" workspace
  minimize-script = pkgs.writeShellScriptBin "minimize" ''
    #!/usr/bin/env bash
    # Get the address of the active window
    active_window_address=$(hyprctl activewindow -j | jq -r '.address')

    # Find if there's a window on the special workspace
    special_window_address=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:minimized") | .address' | head -n 1)

    if [[ "$active_window_address" == "$special_window_address" ]]; then
      # If the active window is the one on the special workspace, "unminimize" it
      hyprctl dispatch movetoworkspace e+0
    elif [[ -n "$active_window_address" ]]; then
      # Otherwise, "minimize" the current active window
      hyprctl dispatch movetoworkspacesilent special:minimized
    fi
  '';
in

{
	home.username = "terajaki";
	home.homeDirectory = "/home/terajaki";
	home.stateVersion = "25.05";

	programs.zsh = {
		enable = true;
		enableCompletion = true;
		syntaxHighlighting.enable = true;
		autosuggestion.enable = true;
		oh-my-zsh = {
			enable = true;
			plugins = [ "git" "sudo" ];
		};
		# initContent allows you to add custom zsh configuration
		initContent = ''
			source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
			
			# my config
			source ~/.p10k.zsh
		'';
	};

	home.shellAliases  = {
    nrs = "sudo nixos-rebuild switch";
    gs = "git status";
  };

	programs.git = {
    enable = true;
    settings = {
      user.name = "ejhay26";
      user.email = "ejperez623@gmail.com";
      init.defaultBranch = "main";
      # Optional: helps with GitHub authentication if you use the 'gh' CLI
      # credential.helper = "store";
};
	};

	programs.rofi = {
		enable = true;
		plugins = [
			pkgs.rofi-emoji
			pkgs.rofi-calc
		];
	};

	home.packages = with pkgs; [
		kdePackages.applet-window-buttons6
		minimize-script

	# for waybar
		lexend              # Required by that specific config
  		jetbrains-mono      # Required font
  		nerd-fonts.jetbrains-mono # Or your preferred Nerd Font
	];

# 	programs.fastfetch = {
#     enable = true;
#     settings = {
#       modules = [
#         "title"
#         "separator"
#         "os"
#         "kernel"
#         "uptime"
#         "packages"
#         "shell"
#         "de"
#         "wm"
#         "terminal"
#         "memory"
#         "swap"
#         "disk"
#         "localip"
#         "battery"
#         "break"
#         "colors"
#         # Note: "host", "display", "cpu", and "gpu" are omitted
#       ];
#     };
#   };

	wayland.windowManager.hyprland = {
    enable = true;
    # Use the flake package
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    
    # This is the option that was missing in NixOS!
    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
    ];

    # Since you are currently symlinking your config, 
    # you can keep using the symlink or move the settings here.

	# this avoids warning with config files not being checked
	extraConfig = lib.mkForce "";
  	};

	xdg.configFile."hypr/hyprland.conf".enable = false;

	# Linking modules to system

	# Hyprland config link
	home.file.".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/home/hyprland";

	# Waybar 
	programs.waybar.enable = true;
	
	# waybar by someone
	home.file.".config/waybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/home/waybar";

	# quickshell link
	home.file.".config/quickshell".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/home/Quickshell";

	# kitty terminal link
	home.file.".config/kitty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/home/kitty_config";
}
