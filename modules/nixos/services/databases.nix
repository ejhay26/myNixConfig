{ config, lib, pkgs, ... }:
{
  services = {
    mysql = {
      enable = true;
      package = pkgs.mariadb;
      settings.mysqld = {
        port = 3306;
        bind-address = "127.0.0.1";
      };
    };

    mongodb = {
      enable = true;
      package = pkgs.mongodb-ce; # mongodb is not pre-compiled
      bind_ip = "127.0.0.1";
    };

    postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      initialScript = pkgs.writeText "initial-script" ''
        CREATE ROLE ${config.users.users.terajaki.name} WITH LOGIN SUPERUSER;
      '';
    };

    redis.servers."".enable = true;
  };
}
