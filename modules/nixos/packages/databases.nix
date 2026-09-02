{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # mariadb removed: services.mysql (MariaDB) already puts mysql, mysqldump,
    # mysqladmin etc. on PATH via the service package. Installing it again here
    # is a duplicate build.
    # mongosh        # MongoDB Shell
    # mongodb-tools  # MongoDB Utilities (dump, restore, etc.)
  ];
}