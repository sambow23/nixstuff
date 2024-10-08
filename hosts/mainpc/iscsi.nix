{
  config,
  lib,
  pkgs,
  ...
}: {
  services.openiscsi = {
    enable = true;
    name = "iqn.2005-10.org.freenas.ctl:supah-vault";
  };

  systemd.services.iscsi-manual-mount = {
    description = "Manually mount iSCSI target";
    after = ["network-online.target" "openiscsi.service"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    path = [pkgs.openiscsi];
    script = ''
      set -e
      echo "Starting iSCSI discovery and login..."
      iscsiadm -m discovery -t sendtargets -p 192.168.50.49:3260
      iscsiadm -m node -o new -T iqn.2005-10.org.freenas.ctl:supah-vault -p 192.168.50.49:3260
      iscsiadm -m node -T iqn.2005-10.org.freenas.ctl:supah-vault -p 192.168.50.49:3260 -l
      echo "iSCSI setup complete."
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "30s";
    };
  };

  systemd.services.mount-supah-vault = {
    description = "Mount Supah-Vault";
    after = ["iscsi-manual-mount.service"];
    requires = ["iscsi-manual-mount.service"];
    wantedBy = ["multi-user.target"];
    path = with pkgs; [ntfs3g util-linux udev];
    script = ''
      set -e
      echo "Waiting for Supah-Vault device..."
      udevadm settle
      for i in {1..60}; do
        if [ -e /dev/disk/by-label/Supah-Vault ]; then
          echo "Supah-Vault device found"
          break
        fi
        echo "Waiting for Supah-Vault device (attempt $i)..."
        sleep 1
      done

      if [ ! -e /dev/disk/by-label/Supah-Vault ]; then
        echo "Supah-Vault device not found after 60 seconds"
        exit 1
      fi

      mkdir -p /mnt/Supah-Vault
      ${pkgs.util-linux}/bin/mount -t ntfs /dev/disk/by-label/Supah-Vault /mnt/Supah-Vault
      echo "Supah-Vault mounted successfully"
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "30s";
    };
  };

  # Ensure the necessary kernel modules are loaded
  boot.kernelModules = ["iscsi_tcp"];
  boot.initrd.kernelModules = ["iscsi_tcp"];
}
