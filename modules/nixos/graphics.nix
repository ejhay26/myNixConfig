{ config, lib, pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # intel-media-driver: correct VA-API driver for Skylake (6th gen, HD 520).
      # libva-vdpau-driver is the old VDPAU bridge — still included for compat
      # but iHD is the one Mesa/Wayland apps (including mcpelauncher) actually use.
      intel-media-driver  # iHD — hardware video decode/encode for 6th gen+
      libva
      libva-vdpau-driver
      libvdpau-va-gl
    ];
    # 32-bit Mesa drivers — required by mcpelauncher: it loads the Android APK's
    # native x86 libs which are 32-bit, and they need 32-bit EGL/OpenGL ES.
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
    ];
  };
  hardware.enableRedistributableFirmware = true;

  # XWayland: mcpelauncher's game window uses EGLUT which is X11-only by default.
  # It runs under XWayland on Wayland sessions (Hyprland/Niri). Must be enabled.
  # If this is disabled anywhere in your config, mcpelauncher silently fails to
  # open a window ("EGLUT: failed to initialize native display").
  programs.xwayland.enable = true;

  # Flatpak GPU driver fix for NixOS:
  # Flatpak sandboxes expect Mesa drivers at standard FHS paths. NixOS stores
  # them in /nix/store, so Flatpak falls back to llvmpipe (software rendering),
  # which is why mcpelauncher via Flatpak was extremely slow and crashed.
  # This activation script runs `flatpak override` once after each rebuild to
  # tell Flatpak's mcpelauncher sandbox to use the host Mesa drivers instead.
  system.activationScripts.flatpakMcpeLauncherGpuFix = {
    text = ''
      if command -v flatpak >/dev/null 2>&1; then
        flatpak override \
          --filesystem=host-os:ro \
          --env=LIBGL_DRIVERS_PATH=/run/opengl-driver/lib/dri \
          --env=LIBVA_DRIVERS_PATH=/run/opengl-driver/lib/dri \
          io.mrarm.mcpelauncher 2>/dev/null || true
      fi
    '';
    deps = [];
  };
}
