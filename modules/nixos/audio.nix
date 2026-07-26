{ config, lib, pkgs, ... }:
{
  # rtkit hands out bounded real-time scheduling priority to PipeWire's
  # audio threads on demand. Without it, PipeWire runs as a normal
  # SCHED_OTHER process and gets starved under CPU load, causing xruns
  # (stutter/crackle). Not enabled by default by the pipewire module.
  # https://wiki.nixos.org/wiki/PipeWire
  security.rtkit.enable = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
}
