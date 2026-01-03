# NixOS Configuration (Modularized)

This NixOS configuration is now organized in a modular structure similar to nix-parts, making it easier to manage and maintain.

## Directory Structure

```
nixos/
├── flake.nix                 # Flake inputs and outputs
├── configuration.nix         # Main system configuration (imports modules)
├── home.nix                  # Home-manager configuration (imports modules)
├── modules/
│   ├── nixos/               # System-level modules
│   │   ├── boot.nix         # Boot and kernel configuration
│   │   ├── networking.nix   # Network, hostname, firewall settings
│   │   ├── desktop.nix      # Display manager and desktop environment
│   │   ├── audio.nix        # PipeWire and audio configuration
│   │   ├── users.nix        # User accounts and groups
│   │   ├── virtualisation.nix # KVM, libvirtd, virt-manager
│   │   ├── graphics.nix     # GPU drivers and graphics support
│   │   ├── programs.nix     # System-wide programs and settings
│   │   ├── services.nix     # System services (MySQL, udev)
│   │   ├── packages.nix     # System packages and fonts
│   │   ├── web-server.nix   # Apache/PHP/web server configuration
│   │   └── web-setup.nix    # Web directories and permissions setup
│   └── home/                # Home-manager modules
│       ├── shell.nix        # Bash and shell configuration
│       └── git.nix          # Git configuration
```

## Benefits of This Modular Structure

1. **Separation of Concerns**: Each module handles a specific aspect of system configuration
2. **Easy to Navigate**: Find and modify specific settings quickly
3. **Reusable**: Modules can be easily shared across different systems
4. **Scalable**: Adding new modules is straightforward
5. **Maintainable**: Smaller files are easier to understand and debug

## Adding New Modules

To add a new system module:

1. Create a new file in `modules/nixos/` (e.g., `modules/nixos/my-module.nix`)
2. Define your configuration in that file
3. Add `./modules/nixos/my-module.nix` to the imports in `configuration.nix`

Example:
```nix
{ config, lib, pkgs, ... }:
{
  # Your configuration here
}
```

To add a new home module:

1. Create a new file in `modules/home/` (e.g., `modules/home/my-home-module.nix`)
2. Add `./modules/home/my-home-module.nix` to the imports in `home.nix`

## Rebuilding Your System

```bash
# Rebuild the system
sudo nixos-rebuild switch --flake .

# Or with a remote flake
sudo nixos-rebuild switch --flake /path/to/nixos
```

## Notes

- The main configuration files (`configuration.nix`, `home.nix`, and `flake.nix`) are now much cleaner and serve as entry points to the modular system
- All packages and configuration from the original files have been preserved and reorganized
- The structure allows for future expansion and easier troubleshooting
