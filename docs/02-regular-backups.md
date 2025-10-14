# Regular Backups

Most of the use of *ursa* is with data updates during regular incremental backups.

These operations can be performed from another system while the storage drive is plugged-in as an external drive. Use the commands discussed in the upcoming sections from the root of a local clone of this project.

### Incremental Backups

For backups, run the following from a command terminal:

    ./commands/ursa backup <device-name>

for example:

    ./commands/ursa backup /dev/sdb

Note that this isn't the volume name, but instead a block device name.

You should be presented with a file explorer window with the vault opened.

> Do remember to remove the drive safely with using remove command!

### Integrity Refresh (Suggested Once or Twice a Year)

It is recommended to run an integrity refresh occasionally to avoid data loss. The reason for having three data volumes is that if during a replication cycle, a volume has been identified with issues, another one can be used for the current cycle, and the problematic volume could still be repaired from one of the two working volumes.

To start an integrity refresh cycle, simply run:

    ./commands/ursa refresh <device-name>

for example:

    ./commands/ursa refresh /dev/sdb

The scripts automatically unlock the vaults, identify the newest and the oldest replicated volume, and the user is suggested to use the former to replicate the latter. This way, the oldest replicated volume becomes the newest for the next cycle, and effectively, all three volumes get checked for data integrity every third replication cycle. *ursa* maintains the timestamp using an empty file named `.ursa-tag` at the root of each data volume.

The device should be automatically removed once done.

### Removing the Backup Drive

Removing the backup drive can be performed using a simple command:

    ./commands/ursa remove <device-name>

for example:

    ./commands/ursa remove /dev/sdb
