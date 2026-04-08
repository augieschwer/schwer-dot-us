# BTRFS
Documentation and configuration for my btrfs setup.

## The basics

### Intro

[BTRFS Lightning Talk - DTG (PDF)](./BTRFS%20Lightning%20Talk%20-%20DTG.pdf)

[BTRFS Lightning Talk - DTG (YouTube)](https://www.youtube.com/live/iu-ryIwFcAw?si=Kq3gbEDuxq2Khqoa&t=1409)

### Walkthroughs

### Snapshot layouts

#### Suse style

#### Ubuntu style

Uses a subvolume layout that separates the root system (`@`) from the home directory (`@home`) on a single partition.

::: info /etc/fstab
```
/dev/mapper/nvme0n1p3_crypt /               btrfs   defaults,subvol=@ 0       0
/dev/mapper/nvme0n1p3_crypt /home           btrfs   defaults,subvol=@home 0       0
```
:::

## Useful tools :toolbox:

### Snapshot automation

::: warning
Check [Gotchas](#gotchas) if you plan on storing snapshots in a location scanned by `updatedb`.
:::

#### [btrbk](https://github.com/digint/btrbk)

By far the best and most versatile BTRFS backup tool.

#### [timeshift](https://github.com/linuxmint/timeshift)

Not really backup, but snapshot automation.

### Maintenance :hammer_and_wrench:

#### [btrfsmaintenance](https://github.com/kdave/btrfsmaintenance) 
This tool works well as a set and forget for always mounted drives. See [Maitenance Tasks](#maintenance-tasks) for a list of tasks to run manually on drives that are not always attached.

::: tip Configuration option
The special word/mountpoint "auto" will evaluate all mounted btrfs filesystems.
This is useful if you have multiple btrfs mount points and you just want them to be found without having to list them all.
:::

## Cool Tricks :sunglasses:

Take a snapshot before installing/removing/updating a package.

### btrbk

::: info /etc/apt/apt.conf.d/99btrbk
```
// snapshot the filesystem before installing packages
DPkg::Pre-Install-Pkgs {"/usr/local/bin/btrbk snapshot -qp";};
```
:::

### Timeshift
::: info /etc/apt/apt.conf.d/80-btrfs-snapshot
```
DPkg::Pre-Install-Pkgs {"/usr/bin/timeshift --scripted --create --comments 'Dpkg::Pre-Install-Pkgs';"};
```
:::

## Gotchas :warning:

Tools like [plocate](https://plocate.sesse.net/plocate.1.html) make finding files on your computer easy and fast; they do this by scanning your filesystem and building an index with tools like [updatedb](https://plocate.sesse.net/updatedb.8.html). These tools will happily traverse BTRFS snapshots and grow their database until they are unusable. To prevent this utilize the `PRUNENAMES` and `PRUNEPATHS` configuration options from [updatedb.conf](https://plocate.sesse.net/updatedb.conf.5.html)

:::info updatedb.conf
```
PRUNENAMES=".snapshots"
PRUNEPATHS="/mnt/backup"
```
:::

## Maintenance Tasks

| Interval | Task | Command |
| -------- | ---- | ------- |
| Monthly  | Scrub| `sudo btrfs scrub start -B /mnt/archive` |

::: tip
Check the status of a scrub with
```sh
sudo btrfs scrub status /mnt/archive
```
:::