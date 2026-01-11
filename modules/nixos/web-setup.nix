{ config, lib, pkgs, ... }:
{
  # Create /var/www/html owned by the user
  systemd.tmpfiles.rules = [
    "d /var/www 0755 terajaki users -"
    "d /var/www/html 0755 terajaki users -"
    # Ensure storage directory structure exists for login web app
    "d /var/www/html/login/storage 0777 terajaki users -"
    "d /var/www/html/login/storage/students 0777 terajaki users -"
    "d /home/terajaki/Documents/www 0755 terajaki users -"
  ];

  systemd.services.fix-www-permissions = {
    description = "Fix /var/www permissions";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      chown -R terajaki:users /var/www/html
      chmod -R 755 /var/www/html

      # Ensure storage directories exist and are writable
      mkdir -p /var/www/html/login/storage/students
      chown -R terajaki:users /var/www/html/login/storage
      chmod -R 777 /var/www/html/login/storage
    '';
  };
}
