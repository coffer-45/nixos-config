# Disk layout is declared exclusively in ./disko.nix.
#
# After Disko has mounted the new target at /mnt, generate this file with:
#   nixos-generate-config --root /mnt --no-filesystems
# Then copy the generated hardware-configuration.nix to this location.
#
# Do not retain fileSystems or swapDevices generated without --no-filesystems:
# Disko provides /, /home, /nix and /boot. Never copy UUIDs from CachyOS.
{ ... }:
{
}
