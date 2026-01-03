{ config, pkgs, ... }:


{
	home.username = "terajaki";
	home.homeDirectory = "/home/terajaki";
	home.stateVersion = "25.05";
	programs.bash = {
		enable = true;
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
