{ config, pkgs, ... }:


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

	home.packages = with pkgs; [
		kdePackages.applet-window-buttons6
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

}
