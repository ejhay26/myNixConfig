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

    # PipeWire clock/resampling configuration.
    # Without this, PipeWire defaults to 48000Hz and resamples everything
    # to/from your hardware's native rate (likely 44100Hz on this laptop).
    # Constant resampling via the default speexrate resampler adds audible
    # harshness through EasyEffects' multi-stage processing chain.
    # allowed-rates lets PipeWire negotiate the hardware's native rate and
    # skip resampling entirely when possible. speexrate_best is used as
    # fallback when resampling is unavoidable (e.g. 48kHz app -> 44.1kHz HW).
    extraConfig.pipewire."10-clock-quality" = {
      "context.properties" = {
        "default.clock.allowed-rates" = [ 44100 48000 ];
        "default.clock.rate" = 48000;
      };
    };
  };

  # EasyEffects runtime plugin dependencies.
  # EasyEffects itself does NOT pull these in — they are optional runtime
  # deps that presets reference. Missing plugins cause EasyEffects to load
  # a preset but silently skip the missing effect node, making the output
  # sound thin, harsh, or wrong compared to the preset's intent.
  environment.systemPackages = with pkgs; [
    lsp-plugins      # LSP: equalizers, compressors, limiters (most presets use these)
    calf             # Calf Studio: saturator, exciter, bass enhancer, vintage EQ
    zam-plugins      # ZamAudio: maximizer (ZaMaximX2)
    zita-convolver   # Convolver effect (room correction, impulse responses)
    libebur128       # Auto gain / level meter (loudness normalization)
    mda_lv2          # MDA Bass: bass loudness plugin
    speexdsp         # Speech processor / noise suppressor
    soundtouch       # Pitch shift effect
  ];
}
