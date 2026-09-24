# NixOS migration configuration

Configuration for an Acer Aspire A715-42G: Niri + Noctalia v5, GDM,
PipeWire, Steam, Docker, GNOME Keyring, zram, AMD iGPU and NVIDIA RTX 3050 Ti
PRIME offload. User applications, including OpenAI Codex CLI, live in
`home/packages.nix` and are installed through Home Manager.

## Disk layout

```text
New 1 TB SSD (~931 GiB)
└── GPT
    ├── ESP       1 GiB     FAT32, mounted at /boot
    ├── NixOS     465 GiB   Btrfs (@, @home, @nix)
    └── remaining space    intentionally unallocated
```

The subvolumes share one partition and use `compress=zstd,noatime`.
This layout is **unencrypted**. Decide whether you want LUKS before installing;
adding encryption requires changing the disk layout and recovery procedure.
Zram provides compressed RAM swap, not persistent swap for hibernation.
Btrfs subvolumes and NixOS generations do not replace backups of your files.

## First installation from the NixOS Live ISO

> **Disko destroys the selected disk's partition table and data.**
> Select only the new SSD, never the existing CachyOS SSD. Back up valuable
> data first. The placeholder disk ID and empty hardware module must be
> replaced on the target machine; a successful CI check cannot verify hardware.

1. Boot a current NixOS Live ISO in **UEFI mode**, connect to the internet,
   and identify the new disk by model, serial number and persistent path:

   ```bash
   test -d /sys/firmware/efi
   lsblk -o NAME,SIZE,MODEL,SERIAL,TRAN,FSTYPE,MOUNTPOINTS
   ls -l /dev/disk/by-id/
   lspci -nn | grep -E 'VGA|3D|Display'
   ```

   Confirm the GPU addresses in `hosts/acer-a715-42g/default.nix`:
   AMD `05:00.0` maps to `PCI:5:0:0`, NVIDIA `01:00.0` to `PCI:1:0:0`.
   Secure Boot is not configured by this repository.

2. Copy the repository to a temporary directory **outside `/mnt`**. Keep this
   terminal open so the `install_config` variable remains available:

   ```bash
   install_config=$(mktemp -d /tmp/nixos-config.XXXXXX)
   cp -a /path/to/NixOS/. "$install_config/"
   cd "$install_config"
   ```

   Replace `/path/to/NixOS` with your actual source directory. Do not copy to
   `/mnt/etc/nixos` yet: mounting the new root would hide those files.

3. Edit `hosts/acer-a715-42g/disko.nix` and replace:

   ```nix
   device = "/dev/disk/by-id/REPLACE_WITH_TARGET_SSD";
   ```

   Use the exact **whole-disk** `by-id` path of the new SSD, never a `-partN`
   path. Check that the target has no mounted partitions. Keep the fixed
   partition size if you want the remaining space unallocated.

4. Check the pinned dependencies and desktop configuration **before** erasing
   anything. Keep the supplied `flake.lock`; do not update dependencies during
   installation. If using an older copy without a lock, generate it first with
   `nix --extra-experimental-features "nix-command flakes" flake lock`.

   ```bash
   nix --extra-experimental-features "nix-command flakes" \
     flake check --accept-flake-config --no-update-lock-file path:.
   ```

   This evaluates the NixOS configuration and builds/validates the Niri and
   Noctalia configuration files. It does not test booting or GPU drivers.
   `--accept-flake-config` accepts this repository's Noctalia binary cache and
   signing key. The `path:` form also includes new files not yet staged in Git.

5. Review the disk setting again, then run the **destructive** Disko step:

   ```bash
   sudo nix --extra-experimental-features "nix-command flakes" run \
     --accept-flake-config --no-update-lock-file "path:$install_config#disko" -- \
     --mode destroy,format,mount \
     "$install_config/hosts/acer-a715-42g/disko.nix"
   ```

   Verify all target mounts before continuing:

   ```bash
   findmnt -R /mnt
   lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS
   ```

   Expect `/mnt`, `/mnt/boot`, `/mnt/home`, and `/mnt/nix`. Do not run Disko
   again on the installed system when doing normal updates.

6. Now copy the configuration onto the **mounted new disk**, then generate
   hardware declarations. Disko exclusively owns filesystem/swap declarations:

   ```bash
   sudo mkdir -p /mnt/etc/nixos
   sudo cp -a "$install_config/." /mnt/etc/nixos/
   sudo nixos-generate-config --root /mnt --no-filesystems
   sudo cp /mnt/etc/nixos/hardware-configuration.nix \
     /mnt/etc/nixos/hosts/acer-a715-42g/hardware-configuration.nix
   ```

   Review the generated host file: it must contain the detected hardware and
   initrd modules, without `fileSystems` or `swapDevices`. Do not copy old-disk
   UUIDs from CachyOS. The generated top-level `configuration.nix` is not used
   by this flake.

7. Check the final configuration and install:

   ```bash
   sudo nix --extra-experimental-features "nix-command flakes" \
     flake check --accept-flake-config --no-update-lock-file path:/mnt/etc/nixos
   sudo nixos-install --flake path:/mnt/etc/nixos#acer-a715-42g \
     --no-update-lock-file --option accept-flake-config true
   ```

   In a Live ISO use `nixos-install`, not `nixos-rebuild switch`.

8. Set the user password before rebooting, then boot the new disk and select
   **Niri** in GDM:

   ```bash
   sudo nixos-enter --root /mnt -c 'passwd drew'
   sudo reboot
   ```

## Checks after the first boot

```bash
systemctl --failed
systemctl --user --failed
findmnt -t btrfs,vfat
df -h
niri validate
codex --version
glxinfo -B
nvidia-offload glxinfo -B
nvidia-smi
journalctl --user -b -u niri.service
```

Compare the OpenGL renderer in the two `glxinfo` calls: ordinarily AMD,
NVIDIA when offloaded. `nvidia-smi` checks NVIDIA driver access, but does not
by itself prove graphics offload. Test Steam, screen sharing, Wi-Fi, Bluetooth,
USB mounting, audio, locking/unlocking, and suspend/resume on the real laptop.

The main keys are `Super+Enter` (terminal), `Super+Space` (launcher),
`Super+S` (control center), `Super+Q` (close window), and `Alt+Shift` (layout).

## Codex CLI

`codex` is provided by nixpkgs through `home.packages`. No global npm install
is needed. Node.js remains installed for JavaScript projects.

```bash
codex --version
codex
```

On first launch, follow the sign-in flow. See the
[official Codex CLI documentation](https://developers.openai.com/codex/cli/).
Keep login credentials out of the repository and Nix expressions.

## Updates and recovery

Keep the working repository in `/etc/nixos`, including `flake.lock` and the
generated host hardware configuration. Track new files in Git before using
the normal Git-backed flake path; new untracked Nix files are otherwise omitted.
Commit a known-working configuration before updating dependencies.

The fish alias `update` only updates `flake.lock`; it does not switch systems.
The `rebuild` alias switches using the existing lock and refuses implicit input
updates. Run checks and a build first:

```bash
cd /etc/nixos
sudo nix flake update
sudo nix flake check --accept-flake-config --no-update-lock-file
sudo nixos-rebuild build --flake .#acer-a715-42g --no-update-lock-file
rebuild
```

If an update fails before activation, fix it or restore the previous lock from
Git. For a bad activated generation, boot a previous generation from the
systemd-boot menu or use `sudo nixos-rebuild switch --rollback`. Garbage
collection removes old generations after 14 days; the boot menu is limited to
10 entries. Neither method rolls back personal data or Docker volumes.

Docker runs as a system service, and membership in the `docker` group grants
root-equivalent access. Do not share its socket with untrusted applications.

## Development checks

```bash
nix flake check --accept-flake-config --no-update-lock-file path:.
nix fmt -- flake.nix home/*.nix hosts/acer-a715-42g/*.nix
```

GitHub Actions performs flake/config validation and evaluates the complete
system derivation. It does not format disks or build/install the entire system.
The repository intentionally ships no real SSD identifier or credentials.
