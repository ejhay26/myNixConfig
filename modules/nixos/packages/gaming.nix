{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # wineWow64Packages.full removed: "full" adds Mono (.NET) and Gecko (IE engine)
    # which Electron/Ionic portable exes don't need. "stable" is sufficient and
    # saves ~800MB-1GB. "wine" was redundant as it's already included inside
    # wineWow64Packages.
    # wineWow64Packages.stable
    mangohud
    # protonup

    # Minecraft Bedrock Edition (Android APK) on Linux — mcpelauncher
    # Runs the Android version of Minecraft Bedrock natively via a fake JNI bridge.
    # No Waydroid, no Wine, no container — the APK runs directly as a Linux process.
    #
    # REQUIRES: Owning Minecraft Bedrock on Google Play Store specifically.
    #           A Microsoft Store purchase is a separate license and won't work.
    #
    # IMPORTANT for your hardware (Intel HD 520 / Skylake):
    #   Your GPU supports OpenGL ES 3.0 via Mesa i965, NOT ES 3.1.
    #   Minecraft Bedrock 1.21.0+ requires ES 3.1 for certain rendering paths.
    #   This causes the crash-after-minutes you experienced: the game loads on ES 3.0
    #   geometry, then hits an ES 3.1 draw call and segfaults.
    #   FIX: In the launcher UI, download and pin to version 1.20.x (last stable
    #   ES 3.0 release). Do NOT update past that on your GPU.
    #
    # OPTION A: Native nixpkgs packages (declarative, but currently flaky on
    #   nixos-unstable — derivation parse errors reported in nixpkgs #422573).
    #   Uncomment if the build works on your current nixpkgs revision:
    # mcpelauncher-ui-qt   # GUI launcher (login with Google, download versions)
    # mcpelauncher-client  # CLI launcher (run a specific version directly)
    #
    # OPTION B: Flatpak (recommended — most stable on NixOS).
    #   graphics.nix now includes the GPU driver fix so Flatpak uses host Mesa
    #   instead of falling back to llvmpipe (which caused your crashes).
    #   XWayland is also explicitly enabled there (required for EGLUT window).
    #
    #   Steps after rebuild:
    #     1. flatpak install flathub io.mrarm.mcpelauncher
    #     2. In the launcher UI: download Minecraft version 1.20.x specifically.
    #        Do NOT download latest — 1.21.0+ requires OpenGL ES 3.1 which your
    #        Intel HD 520 does not support (max is ES 3.0). That is what caused
    #        the crash-after-minutes, not a NixOS config problem.
    #     3. Launch: flatpak run io.mrarm.mcpelauncher
  ];
}
