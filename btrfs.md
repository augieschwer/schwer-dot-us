# BTRFS
Documentation and configuration for my btrfs setup.

## The basics

### Intro

[BTRFS Lightning Talk - DTG (PDF)](./BTRFS%20Lightning%20Talk%20-%20DTG.pdf)

[BTRFS Lightning Talk - DTG (YouTube)](https://www.youtube.com/live/iu-ryIwFcAw?si=Kq3gbEDuxq2Khqoa&t=1409)

### Walkthroughs

### Snapshot layouts

#### OpenSUSE style
As described [here](https://en.opensuse.org/SDB:BTRFS#Default_Subvolumes) in the official documentation, and with some more detail and explanation [here](https://www.jwillikers.com/btrfs-layout). The advantage is that you have a lot more control over what happens during a roll back and how often or if you want to snapshot certain directories; the disadvantage is: unless you're running OpenSUSE, you have to set all this up manually.

::: info /etc/fstab
```
UUID=8884113b-f807-4ac6-a97a-948fe9eee833 /               btrfs   defaults,subvol=@ 0       0
UUID=8884113b-f807-4ac6-a97a-948fe9eee833 /root           btrfs   defaults,subvol=@root_user 0       0
UUID=8884113b-f807-4ac6-a97a-948fe9eee833 /tmp		  btrfs   defaults,subvol=@tmp	 0       0
UUID=8884113b-f807-4ac6-a97a-948fe9eee833 /usr/local	  btrfs   defaults,subvol=@usr_local 0       0
UUID=8884113b-f807-4ac6-a97a-948fe9eee833 /var	 	  btrfs   defaults,subvol=@var 	0       0
UUID=8884113b-f807-4ac6-a97a-948fe9eee833 /opt	 	  btrfs   defaults,subvol=@opt 	0       0
UUID=0786fd3e-4e4c-4113-858b-a7f53e676be9 /home           btrfs   defaults,compress=zstd,subvol=@home 0       0
```
:::

#### Ubuntu style

Uses a subvolume layout that separates the root system (`@`) from the home directory (`@home`) on a single partition. The advantage is that it comes default and there isn't anything you need to do to set it up, plus tools like [Timeshift](#timeshift) require this layout to work.

::: info /etc/fstab
```
/dev/mapper/nvme0n1p3_crypt /               btrfs   defaults,subvol=@ 0       0
/dev/mapper/nvme0n1p3_crypt /home           btrfs   defaults,subvol=@home 0       0
```
:::

## Useful tools

### Snapshot automation

::: warning
Check [Gotchas](#gotchas) if you plan on storing snapshots in a location scanned by `updatedb`.
:::

#### [btrbk](https://github.com/digint/btrbk)

By far the best and most versatile BTRFS backup tool.

#### [Timeshift](https://github.com/linuxmint/timeshift)

Not really backup, but snapshot automation.

### Maintenance :hammer_and_wrench:

#### [btrfsmaintenance](https://github.com/kdave/btrfsmaintenance) 
This tool works well as a set and forget for always mounted drives. See [Maitenance Tasks](#maintenance-tasks) for a list of tasks to run manually on drives that are not always attached.

::: tip Configuration option
The special word/mountpoint "auto" will evaluate all mounted btrfs filesystems.
This is useful if you have multiple btrfs mount points and you just want them to be found without having to list them all.
:::

## Cool Tricks

Take a snapshot before installing/removing/updating a package. 

::: tip
Details on `DPkg::Pre-Install-Pkgs` can be found in [apt.conf(5)](https://manpages.debian.org/stretch/apt/apt.conf.5.en.html).
:::

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

## Gotchas

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