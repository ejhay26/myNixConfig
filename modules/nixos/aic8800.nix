{ config, lib, pkgs, ... }:
let
  aic8800-driver = config.boot.kernelPackages.callPackage
    ({ stdenv, lib, fetchFromGitHub, kernel }:
      stdenv.mkDerivation {
        pname = "aic8800-driver-${kernel.version}";
        version = "unstable-2025-43db800";

        src = fetchFromGitHub {
          owner = "shenmintao";
          repo = "aic8800d80";
          rev = "43db8006cb9b5fcd2b3191ecb7e3ea5962d39aaa";
          # If the build reports a hash mismatch, paste the "got:" value here.
          hash = "sha256-Fr63xv/e6FfKLVNZCfSKqxpl8sqDZvA5au3GA/Xoe5o=";
        };

        nativeBuildInputs = kernel.moduleBuildDependencies;
        hardeningDisable = [ "pic" "format" ];

        buildPhase = ''
          runHook preBuild
          make -C drivers/aic8800 -j"$NIX_BUILD_CORES" \
            ${lib.escapeShellArgs kernel.makeFlags} \
            KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
            KVER=${kernel.modDirVersion} \
            O=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          moddir=$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/aic8800
          install -D -m 644 -t "$moddir" \
            drivers/aic8800/aic_load_fw/aic_load_fw.ko \
            drivers/aic8800/aic8800_fdrv/aic8800_fdrv.ko \
            drivers/aic8800/aic_zlp_quirk/aic_zlp_quirk.ko

          mkdir -p $out/lib/firmware
          cp -r --no-preserve=mode,ownership fw/* $out/lib/firmware/
          runHook postInstall
        '';

        # Driver opens the raw .bin files directly, so they must not be
        # compressed by hardware.firmwareCompression.
        passthru.compressFirmware = false;

        meta = {
          description = "AIC8800 USB WiFi/Bluetooth out-of-tree driver";
          license = lib.licenses.gpl2Only;
          platforms = lib.platforms.linux;
        };
      })
    { };
in
{
  boot.extraModulePackages = [ aic8800-driver ];
  # aic_load_fw / aic8800_fdrv autoload via their USB aliases after mode switch.
  # aic_zlp_quirk installs a kprobe and only matters for 368b:8d81; it also
  # autoloads by alias, so it is deliberately not forced at boot.
  hardware.firmware = [ aic8800-driver ];

  # Tell the driver where to find firmware on NixOS (no /lib/firmware here).
  # aic_fw_path is the driver's built-in module parameter for this purpose.
  boot.extraModprobeConfig = ''
    options aic_load_fw aic_fw_path=/run/current-system/firmware
  '';

  # Ensure both modules are loaded at boot so they are ready when udev
  # fires the modeswitch and the dongle re-enumerates as a WiFi device.
  boot.kernelModules = [ "aic_load_fw" "aic8800_fdrv" ];

  services.udev.extraRules = ''
    # Switch AIC8800 from mass-storage mode to WiFi/BT mode (device level only)
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="a69c", ATTR{idProduct}=="5721", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -K -v a69c -p 5721"
  '';
}
