# NixOS migration configuration

This repository targets an Acer Aspire A715-42G running Niri and Noctalia v5.
It configures GDM, PipeWire, Steam, Docker, GNOME Keyring, zram swap, and AMD
iGPU + NVIDIA RTX 3050 Ti PRIME offload.

## Disk layout

```text
New 1 TB SSD (~931 GiB)
└── GPT
    ├── ESP       1 GiB     FAT32, mounted at /boot
    ├── NixOS     465 GB    Btrfs (@, @home, @nix)
    └── remaining space     intentionally unallocated
```

`@`, `@home`, and `@nix` are Btrfs subvolumes in the one NixOS partition; they
share its capacity and are mounted with `compress=zstd,noatime`. There is no
swap partition: normal swap is supplied by zram.

## First installation from the NixOS Live ISO

> **DANGER — read this before running Disko.**
>
> Disko destroys the partition table on the disk selected in
> `hosts/acer-a715-42g/disko.nix`. The existing CachyOS SSD must not be
> selected. Do not continue until you are **100% sure** which `/dev/disk/by-id`
> entry belongs to the **new SSD**.

1. Boot the Live ISO with both disks connected. Identify the new SSD by its
   model, serial number, transport and persistent identifier:

   ```bash
   lsblk -o NAME,SIZE,MODEL,SERIAL,TRAN
   ls -l /dev/disk/by-id/
   ```

   Use a whole-disk path such as
   `/dev/disk/by-id/nvme-SERIAL_OR_MODEL`, not a partition ending in `-part1`.
   Never substitute `/dev/sda` or `/dev/nvme0n1` just because it happens to be
   the current name.

2. Copy the *contents* of this directory to the target configuration location:

   ```bash
   sudo mkdir -p /mnt/etc/nixos
   sudo cp -r /path/to/NixOS/. /mnt/etc/nixos/
   cd /mnt/etc/nixos
   ```

3. Edit the only intentionally invalid device setting in
   `hosts/acer-a715-42g/disko.nix`:

   ```nix
   device = "/dev/disk/by-id/REPLACE_WITH_TARGET_SSD";
   ```

   Replace it with the exact `by-id` path of the **new SSD**, then review the
   file once more. The literal placeholder is deliberately not runnable.

4. Create `flake.lock` before partitioning so the Disko version is pinned:

   ```bash
   sudo nix --extra-experimental-features "nix-command flakes" flake lock
   ```

5. Run the Disko package exported by this flake. This is the destructive step;
   it creates GPT, formats the ESP and Btrfs partition, makes the three Btrfs
   subvolumes, and mounts them under `/mnt`. It leaves the second half of the
   SSD unallocated.

   ```bash
   sudo nix --extra-experimental-features "nix-command flakes" run \
     /mnt/etc/nixos#disko -- \
     --mode destroy,format,mount \
     /mnt/etc/nixos/hosts/acer-a715-42g/disko.nix
   ```

   Verify the result before continuing:

   ```bash
   findmnt /mnt /mnt/boot /mnt/home /mnt/nix
   lsblk
   ```

6. Generate hardware declarations without filesystem or swap entries; Disko is
   the sole owner of those declarations. Copy the resulting hardware file into
   the host module location:

   ```bash
   sudo nixos-generate-config --root /mnt --no-filesystems
   sudo cp /mnt/etc/nixos/hardware-configuration.nix \
     /mnt/etc/nixos/hosts/acer-a715-42g/hardware-configuration.nix
   ```

   Do not copy filesystem UUIDs from CachyOS. If a generated hardware file
   somehow contains `fileSystems` or `swapDevices`, remove those declarations
   before installation because `disko.nix` already provides them.

7. Install the mounted target. In a Live ISO use `nixos-install`, not
   `nixos-rebuild switch`:

   ```bash
   sudo nixos-install --flake /mnt/etc/nixos#acer-a715-42g
   ```

8. Set the password before rebooting, remove the Live ISO, then boot the new
   disk and select the **Niri** session in GDM:

   ```bash
   sudo nixos-enter --root /mnt -c 'passwd drew'
   reboot
   ```

## Checks after the first boot

```bash
lsblk
findmnt
df -h
nvidia-smi
nvidia-offload nvidia-smi
sudo parted -l
```

The NVIDIA commands verify PRIME offload; the ordinary desktop runs on the AMD
iGPU. `parted -l` should show only the 1 GiB ESP and ~465 GB NixOS partition on
the new SSD, with roughly half of the disk remaining unallocated.

The main Niri keys are `Super+Enter` (terminal), `Super+Space` (Noctalia
launcher), `Super+S` (control center), and `Super+Q` (close window). Switch the
keyboard layout with `Alt+Shift`.

## Normal updates

Keep this repository at `/etc/nixos`, including `flake.lock`, and put it under
Git. The configured fish aliases are `rebuild` and `update`.

No secrets, Wi-Fi passwords, old-disk UUIDs, or a real target disk identifier
are stored in this repository.
