# ursa-major

[![License](https://img.shields.io/github/license/myTerminal/see-link.svg)](https://opensource.org/licenses/MIT)  
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Y8Y5E5GL7)

My opinionated data backup and retrieval system

## Purpose

(coming soon...)

## Requirements

### Hardware

The system has been designed with an external storage drive in mind with the following data volumes:

1. /dev/sdb1 - Backup volume 1
2. /dev/sdb2 - Backup volume 2
3. /dev/sdb3 - Backup volume 3
4. /dev/sdb4 - Live volume hosting *ursa*

The above specification assumes that the external drive has been identified as /dev/sdb block device.

### Software

*ursa* is a simple set of shell scripts with the least number of external dependencies that it sets up to be able to perform its operations, which includes regular backups, updates, and eventual data retrieval by a trusted family member or inheritor.

#### Suggested Volume Setup

Set up partitions

    cfdisk /dev/sdb

Partitions:

1. `/dev/sdb1` - backup partition 1
2. `/dev/sdb2` - backup partition 2
3. `/dev/sdb3` - backup partition 3
4. `/dev/sdb4` - auxiliary partition

Format backup partitions with LUKS

    cryptsetup -y -v luksFormat --type luks1 /dev/sdb1
    cryptsetup -y -v luksFormat --type luks1 /dev/sdb2
    cryptsetup -y -v luksFormat --type luks1 /dev/sdb3

Format auxiliary partition with EXT4

    mkfs.ext4 /dev/sdb4

Open backup partitions to create an EXT4 underneath

    cryptsetup open /dev/sdb1 vault-a
    cryptsetup open /dev/sdb2 vault-b
    cryptsetup open /dev/sdb3 vault-c
    mkdir /mnt/vault-a /mnt/vault-b /mnt/vault-c
    mount /dev/mapper/vault-a /mnt/vault-a
    mount /dev/mapper/vault-b /mnt/vault-b
    mount /dev/mapper/vault-c /mnt/vault-c
    chmod 777 -R /mnt/vault-a /mnt/vault-b /mnt/vault-c
    mkfs.ext4 /dev/mapper/vault-a
    mkfs.ext4 /dev/mapper/vault-b
    mkfs.ext4 /dev/mapper/vault-c
    cryptsetup close vault-a
    cryptsetup close vault-b
    cryptsetup close vault-c

Unmount the auxiliary partition

    udisksctl unmount -b /dev/sdb4
    udisksctl power-off -b /dev/sdb4

Install a graphical Linux distribution on the fourth volume, and deploy *ursa* on it. Follow the next section on deploying *ursa*. Preferably enable running `sudo` commands without a password.

## Setup

To prepare the environment with external dependencies, run:

    make setup

In order to set *ursa* on an external storage drive, clone it to a local directory, and run the following command:

    ./ursa-deploy

You will be prompted to enter a location to the fourth live volume on the target drive. Once a location is provided, and if everything goes as expected, you should be able to see the commands deployed to the specified device.

## Usage

### Retrieving Data

If you simply need to retrieve data from the three data volumes, run:

    ./ursa-retrieve

You should be presented with three file explorer windows for the three decrypted data volumes, each having the same exact data. 

### Regular Backups

*ursa* has been designed to work with three sets of identical data volumes. It is recommended to run a replication cycle at regular intervals to avoid data loss. The reason for having thee data volumes is that if during a replication cycle, a volume has been identified with issues, another one can be used for the current cycle, and the problematic volume could still be repaired from one of the two working volumes.

To start a backup, simply run:

    ./ursa-backup

The scripts automatically unlocks the vaults, identify the newest and the oldest replicated volume, and the user is suggested to use the former to replicate the latter. This way, the oldest replicated volume becomes the newest for the next cycle, and all the three volumes get checked for data integrity every third replication cycle. *ursa* maintains the timestamp using an empty file named `.ursa-tag` at the root of each data volumes.

### Removing the Backup Drive

Removing the backup drive can be performed using a simple command:

    ./ursa-remove

### Updating *ursa*

In order to update *ursa* on the backup drive, simply run:

    ./ursa-update

## External Dependencies

- [cryptsetup](https://gitlab.com/cryptsetup/cryptsetup)
- [udisks2](https://www.freedesktop.org/wiki/Software/udisks)
- [meld](https://meldmerge.org)
