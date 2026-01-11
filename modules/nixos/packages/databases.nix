{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mariadb        # MySQL client, mysqldump, etc.
    mongosh        # MongoDB Shell
    mongodb-tools  # MongoDB Utilities (dump, restore, etc.)
  ];
}