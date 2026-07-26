{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mpv
    ffmpeg
    obs-studio
    qpwgraph
    alsa-tools
    libva-utils
    v4l-utils
    x264
    cheese
    # kdePackages.kamoso
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    # gst-plugins-bad, gst-plugins-ugly, gst-libav removed:
    # "bad" and "ugly" are large plugin packs covering obscure/patent-encumbered
    # formats. ffmpeg (already above) handles the same formats more efficiently.
    # gst-libav is a GStreamer wrapper around libav/ffmpeg — redundant given
    # ffmpeg is already installed directly.
  ];
}
