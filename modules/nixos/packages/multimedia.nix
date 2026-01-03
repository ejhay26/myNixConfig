{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mpv
    ffmpeg
    obs-studio
    qpwgraph
    alsa-tools
    libva-utils
    x264
  ];
}
