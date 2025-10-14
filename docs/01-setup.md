# Setting Up *ursa*

## Pre-Requisites

*ursa* has been designed for an external storage drive running a Linux setup.

### Hardware

Any kind of storage drive would work, including mechanical hard-drives, solid-state drives, flash-drives, etc. as long as they are fast enough to boot from and perform read-write operations at a reasonable speed, and have enough storage capacity to hold a host Linux operating system and more importantly all your data.

### Software

My choice of Linux distribution (at least at the time of this writing) is [Void Linux](https://voidlinux.org), which is fairly minimal out of the box and has [Runit](https://smarden.org/runit) as the init system instead of the more traditional [systemd](https://systemd.io). However, you may choose any other alternative as long as it satisfies the requirements mentioned in the upcoming sections.

## Suggested Host Setup

The volume setup should be as follows:

|    Volume    | Purpose                         |
|:------------:|:--------------------------------|
| `/dev/sdb1`  | Boot                            |
| `/dev/sdb2`  | Linux root hosting *ursa*       |
| `/dev/sdb3`  | Backup volume 1                 |
| `/dev/sdb4`  | Backup volume 2                 |
| `/dev/sdb5`  | Backup volume 3                 |

The above specification assumes that the external drive has been identified as `/dev/sdb` block device.

Set up partitions using `cfdisk` (or any other tool of your choice).

    cfdisk /dev/sdb

Designate `/dev/sdb3`, `/dev/sdb4`, and `/dev/sdb5` as the backup volumes.

### Setting up the Vaults

Format the backup partitions with LUKS encryption using `cryptsetup`. It is installed along with *ursa*, but while setting up the vaults, you may need to install it manually within your own setup.

    cryptsetup -y -v luksFormat --type luks1 /dev/sdb3
    cryptsetup -y -v luksFormat --type luks1 /dev/sdb4
    cryptsetup -y -v luksFormat --type luks1 /dev/sdb5

Run the following commands to set up the vaults:

    # Open the backup volumes
    cryptsetup open /dev/sdb3 vault-a
    cryptsetup open /dev/sdb4 vault-b
    cryptsetup open /dev/sdb5 vault-c

    # Format volumes as EXT4
    mkfs.ext4 /dev/mapper/vault-a
    mkfs.ext4 /dev/mapper/vault-b
    mkfs.ext4 /dev/mapper/vault-c

    # Create directories for mount points
    mkdir /mnt/vault-a /mnt/vault-b /mnt/vault-c

    # Mount backup volumes into the created directories
    mount /dev/mapper/vault-a /mnt/vault-a
    mount /dev/mapper/vault-b /mnt/vault-b
    mount /dev/mapper/vault-c /mnt/vault-c

    # Set permissions
    chmod 777 -R /mnt/vault-a /mnt/vault-b /mnt/vault-c

    # Unmount backup vaults
    umount /mnt/vault-a /mnt/vault-b /mnt/vault-c

    # Close backup volumes
    cryptsetup close vault-a
    cryptsetup close vault-b
    cryptsetup close vault-c

Finally, unmount the other volumes (if needed).

    udisksctl unmount -b /dev/sdb1
    udisksctl unmount -b /dev/sdb2

Safely remove the storage drive.

    udisksctl power-off -b /dev/sdb

### Installing and Setting Up the Host Linux System

Install a minimal Linux setup on `/dev/sdb2` with `/dev/sdb1` as EFI. Feel free to choose any Linux distribution, as long as it satisfies the following base requirements:

#### A Minimal Setup

Choose a TTY setup such that the system starts on the TTY, not GUI.

> Refer to [my guide that I use for my personal machines](https://github.com/myTerminal/dotfiles/blob/master/.setup/docs/install-void.md).

#### Sudo Access Without Passwords

Enable running `sudo` commands without a password. This can be done by uncommenting the below line through `visudo`:

    # %wheel ALL=(ALL:ALL) NOPASSWD: ALL

This also assumes that the user has been added to `wheel` group.

#### Auto-login on TTY

Configure it such that as soon as Linux boots, a user session is started through auto-login, instead of prompting the user for credentials.

##### On my Runit-based Void Linux, I do the following:

Switch to TTY2 using `Ctrl+Alt+F2`.

Create a copy of the `agetty-tty1` service.

    sudo cp -R /etc/sv/agetty-tty1 /etc/sv/agetty-autologin-tty1

Edit the file `/etc/sv/agetty-autologin-tty1/conf` to something similar to this:

    GETTY_ARGS="--autologin <username> --noclear"
    BAUD_RATE=38400
    TERM_NAME=linux

Remove the original service.

    sudo rm /var/service/agetty-tty1

Create a new auto-login service.

    sudo ln -s /etc/sv/agetty-autologin-tty1 /var/service

### Installing *ursa* Within Host

Boot into the host Linux system, and install *ursa* using one of the following two methods:

#### Manual Installation

Clone it to a local directory,

     # Clone project to the local directory
    git clone https://github.com/myTerminal/ursa.git

    # Switch to the project directory
    cd ursa

and run the following command:

    make setup

#### Semi-Automatic Installation

Run this directly on a command terminal, and the rest gets taken care of automatically:

    /bin/bash -c "$(curl https://raw.githubusercontent.com/myTerminal/ursa/main/setup)"

This will prepare the environment with external dependencies, install *ursa* commands on the system, and get everything else ready for use.
