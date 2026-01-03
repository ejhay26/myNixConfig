{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    libpng
    libjpeg
    freetype
    libvorbis
    libogg
  ];
}
