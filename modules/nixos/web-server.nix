{ config, lib, pkgs, ... }:
{
  services.httpd = {
    enable = true;
    adminAddr = "admin@example.com";
    user = "terajaki";
    group = "users";
    enablePHP = true;
    phpPackage = pkgs.php;

    virtualHosts."localhost" = {
      documentRoot = "/var/www/html";
      extraConfig = ''
        <Directory "/var/www/html">
          DirectoryIndex index.php index.html
          AllowOverride All
          Options Indexes FollowSymLinks
          Require all granted
        </Directory>

        # Also serve from ~/Documents/www with /dev/ prefix
        Alias /dev /home/terajaki/Documents/www/
        <Directory "/home/terajaki/Documents/www/">
          DirectoryIndex index.php index.html
          AllowOverride All
          Options Indexes FollowSymLinks
          Require all granted
        </Directory>

        <FilesMatch \.php$>
          SetHandler application/x-httpd-php
        </FilesMatch>

        # Adminer (database manager)
        Alias /adminer ${pkgs.adminer}/adminer.php
      '';
    };
  };
}
