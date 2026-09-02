{ config, lib, pkgs, ... }:
{
  # virtualisation = {
  #   libvirtd.enable = true;
  #   kvmgt.enable = true;
  #   spiceUSBRedirection.enable = true;

    # Docker (rootless) — safe default: runs under your user, no root daemon.
    # "docker" group is in users.nix but rootless doesn't need it; harmless.
    # Uncomment to enable. After rebuild: run `dockerd-rootless-setuptool.sh install`
    # once, then `docker run hello-world` to verify.
    # docker.rootless = {
    #   enable = true;
    #   setSocketVariable = true; # sets DOCKER_HOST so CLI tools find the socket
    # };

    # Waydroid — runs Android apps via LXC container on Wayland.
    # BEFORE uncommenting, read:
    #   1. Uses ~2.2GB for Android images (downloaded at runtime via `sudo waydroid init`,
    #      NOT part of the Nix store / rebuild size).
    #   2. You are on linuxPackages_latest; ip_tables module may be missing
    #      (nixpkgs issue #459520). waydroid-nftables mitigates this.
    #   3. After rebuild: `sudo waydroid init -s GAPPS` (adds Google Play, needed
    #      for Minecraft Bedrock). Then: `waydroid show-full-ui`.
    #   4. Minecraft Bedrock 1.21.124+ crashes (SIGSEGV) inside Waydroid on x86_64
    #      due to an upstream Waydroid/Minecraft memory bug — not fixable via NixOS
    #      config. Pin to an older APK if you need stable Bedrock.
    # waydroid = {
    #   enable = true;
    #   package = pkgs.waydroid-nftables; # required for linuxPackages_latest (nftables)
    # };

    # Minecraft Bedrock Dedicated Server (Docker-based) — Bedrock Edition server.
    # Requires Docker to be enabled and running first (uncomment docker block above).
    # After enabling Docker, run manually:
    #
    #   docker run -d \
    #     --name minecraft-bedrock \
    #     -e EULA=TRUE \
    #     -p 19132:19132/udp \
    #     -v ~/minecraft-bedrock/data:/data \
    #     itzg/minecraft-bedrock-server
    #
    # World data lives in ~/minecraft-bedrock/data (survives container restarts).
    # Connect from other devices: use your Linux IP, port 19132.
    # Manage: `docker logs minecraft-bedrock` / `docker stop minecraft-bedrock`
    # This is intentionally a runtime command, not a NixOS service, so you can
    # start/stop it on demand without a system rebuild.
#   };
# #  programs.virt-manager.enable = true;
}
