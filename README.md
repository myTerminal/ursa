# ursa

[![License](https://img.shields.io/github/license/myTerminal/ursa.svg)](https://opensource.org/licenses/MIT)  
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Y8Y5E5GL7)

My opinionated data backup and retrieval system

## Purpose

Since the late 1990s, I have accumulated a significant amount of digital data. Starting from my first Casio digital diary, my data has migrated across various computing devices, undergone format changes, and I've also experienced occasional data loss. My quest to find the most secure and reliable method for data storage has led me through various solutions, including external drives, cloud storage, and a network of [Syncthing](https://syncthing.net) nodes offering more than sufficient redundancy.

While these methods have served me well, ensuring continued access to my data for an inheritor is tricky. Storage drives can fail, cloud services come with trust issues, and even replicating data across multiple computers is constrained by password requirements.

*ursa* is designed to address these concerns by:

1. **Centralizing Data:** Keeping all data in a single location
2. **Enhanced Security:** Protecting data behind encrypted volumes, accessible only through independent passwords
3. **Redundant Copies:** Maintaining more than two redundant copies of all data to ensure reliability
4. **Regular Synchronization:** Continuously syncing data from its various sources to keep it up-to-date
5. **Error Checking and Refreshing:** Periodically refreshing and checking data for errors to ensure ongoing integrity

With *ursa*, I could have peace of mind knowing that my data is securely managed and more accessible in case I need it available after I'm gone.

## Requirements

### Hardware

The system has been designed with an external storage drive in mind, with the following data volumes:

|    Volume    | Purpose                   |
|:------------:|:--------------------------|
| `/dev/sdb1`  | Boot                      |
| `/dev/sdb2`  | Linux root hosting *ursa* |
| `/dev/sdb3`  | Backup volume 1           |
| `/dev/sdb4`  | Backup volume 2           |
| `/dev/sdb5`  | Backup volume 3           |

The above specification assumes that the external drive has been identified as `/dev/sdb` block device.

### Software

*ursa* is a simple set of shell scripts with the least number of external dependencies that it sets up to be able to perform its operations, which include regular backups, updates, and eventual data retrieval by a trusted family member or inheritor.

#### Suggested Volume Setup

Set up partitions using `cfdisk`.

    cfdisk /dev/sdb

The following is the accepted partition scheme:

1. `/dev/sdb3` - backup partition 1
2. `/dev/sdb4` - backup partition 2
3. `/dev/sdb5` - backup partition 3

Format backup partitions with LUKS.

    cryptsetup -y -v luksFormat --type luks1 /dev/sdb4
    cryptsetup -y -v luksFormat --type luks1 /dev/sdb5
    cryptsetup -y -v luksFormat --type luks1 /dev/sdb6

It is assumed that a Linux setup is installed on `/dev/sdb2` with `/dev/sdb1` as EFI.

Run the following commands to set up the backup volumes:

    # Open the backup volumes
    cryptsetup open /dev/sdb3 vault-a
    cryptsetup open /dev/sdb4 vault-b
    cryptsetup open /dev/sdb5 vault-c

    # Create directories for mount points
    mkdir /mnt/vault-a /mnt/vault-b /mnt/vault-c

    # Mount backup volumes into the created directories
    mount /dev/mapper/vault-a /mnt/vault-a
    mount /dev/mapper/vault-b /mnt/vault-b
    mount /dev/mapper/vault-c /mnt/vault-c

    # Set permissions
    chmod 777 -R /mnt/vault-a /mnt/vault-b /mnt/vault-c

    # Format volumes as EXT4
    mkfs.ext4 /dev/mapper/vault-a
    mkfs.ext4 /dev/mapper/vault-b
    mkfs.ext4 /dev/mapper/vault-c

    # Close backup volumes
    cryptsetup close vault-a
    cryptsetup close vault-b
    cryptsetup close vault-c

Finally, unmount the auxiliary partition.

    udisksctl unmount -b /dev/sdb2
    udisksctl power-off -b /dev/sdb

Install a graphical Linux distribution on the fourth volume, and deploy *ursa* on it. Follow the next section on deploying *ursa*. Preferably enable running `sudo` commands without a password.

## Setup

In order to set up *ursa* on an external storage drive, clone it to a local directory, and run the following command:

    make setup

This will prepare the environment with external dependencies, and internally run `./ursa-deploy`, which will prompt for a location to the second volume on the target drive. Once a location is provided, and if everything goes as expected, you should be able to see the commands deployed to the specified device.

## Usage

*ursa* has been designed to maintain user data in a set of three identical data volumes. You may maintain your data backup in only one of the three, though keeping all three of them in sync is recommended.

> **Note:** As of this point, the commands will only be accessible from the directory *ursa* was cloned into. A future enhancement is planned that will deploy the commands such that they will be available from anywhere in the system.

### Retrieving Data

If you simply need to retrieve data from the three data volumes, run:

    ./ursa-retrieve

You should be presented with a file explorer window with the most recent data recorded by *ursa*.

> **Note:** As of this point, retrieval requires opening a command terminal, navigating to *ursa* directory, and running the commands. A future enhancement should be able to allow performing this action through the click of an icon on the desktop.

### Regular Backups

In order to back up data, you may run:

    ./ursa-retrieve <device-name>

for example:

    ./ursa-retrieve /dev/sdb

...which will find the most recently updated (and hence most up-to-date data volume) and unlock it for syncing files for a backup. Although it is recommended to occasionally also sync data between all three data volumes, and keep them in sync. This can be done using:

    ./ursa-sync

This will open [meld](https://meldmerge.org) on all three data volumes for manual sync.

Safely remove the drive using `./ursa-remove <device-name>`.

### Integrity Refresh (Suggested Once or Twice a Year)

It is recommended to run an integrity refresh occasionally to avoid data loss. The reason for having three data volumes is that if during a replication cycle, a volume has been identified with issues, another one can be used for the current cycle, and the problematic volume could still be repaired from one of the two working volumes.

To start an integrity refresh cycle, simply run:

    ./ursa-refresh <device-name>

for example:

    ./ursa-refresh /dev/sdb

The scripts automatically unlock the vaults, identify the newest and the oldest replicated volume, and the user is suggested to use the former to replicate the latter. This way, the oldest replicated volume becomes the newest for the next cycle, and effectively, all three volumes get checked for data integrity every third replication cycle. *ursa* maintains the timestamp using an empty file named `.ursa-tag` at the root of each data volume.

The device should be automatically removed once done.

### Removing the Backup Drive

Removing the backup drive can be performed using a simple command:

    ./ursa-remove <device-name>

for example:

    ./ursa-remove /dev/sdb

### Updating *ursa*

In order to update *ursa* on the backup drive, simply run:

    ./ursa-update

## External Dependencies

- [cryptsetup](https://gitlab.com/cryptsetup/cryptsetup)
- [udisks2](https://www.freedesktop.org/wiki/Software/udisks)
- [meld](https://meldmerge.org)

## TODO

- Implement progress update during long-running processes
- Implement the deployment of commands at the system level
- Implement ".desktop" files for normies
