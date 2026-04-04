# BTRFS
Documentation and configuration for my btrfs setup.

## Useful tools
### Maintenance
[btrfsmaintenance](https://github.com/kdave/btrfsmaintenance) works well as a set and forget for always mounted drives. See [Maitenance](#maintenance-1) for a list of tasks to run manually on drives that are not always attached.

## Maintenance

| Interval | Task | Command |
| -------- | ---- | ------- |
| Monthly  | Scrub| `sudo btrfs scrub start -B /mnt/archive` |

::: info
Check the status of a scrub with
```sh
sudo btrfs scrub status /mnt/archive
```