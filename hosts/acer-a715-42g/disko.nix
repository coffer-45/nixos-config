{
  disko.devices = {
    disk = {
      main = {
        type = "disk";

        # WARNING:
        # Replace this value with the /dev/disk/by-id/... path of the NEW SSD
        # before running Disko. Never use /dev/sda or /dev/nvme0n1 blindly.
        # Disko will destroy the partition table on the selected disk.
        device = "/dev/disk/by-id/REPLACE_WITH_TARGET_SSD";

        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            nixos = {
              # Fixed size leaves the rest of the ~1 TB SSD unpartitioned.
              # Do not change this to 100% or add a partition after it.
              size = "465G";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
