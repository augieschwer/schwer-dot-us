# BTRFS
Documentation and configuration for my btrfs setup.

## The basics

### Intro

BTRFS is a Linux file system. It has several features that make it cool:

* Copy-on-Write (CoW)
* Dynamic inode allocation
* Online defragmentation, resizing
* Built-in RAID
* Built-in compression
	* Ztd, lzo, zlib
* Checksums

[BTRFS Lightning Talk - DTG (PDF)](./BTRFS%20Lightning%20Talk%20-%20DTG.pdf)

[BTRFS Lightning Talk - DTG (YouTube)](https://www.youtube.com/live/iu-ryIwFcAw?si=Kq3gbEDuxq2Khqoa&t=1409)

### Walkthroughs

### [Official documentation](https://btrfs.readthedocs.io/en/latest/)

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

BTRFS makes it easy to make snapshots, but snapshots are copies of your data on the same storage, so they aren't good backups; backups should go to another storage place, and `btrbk` makes that easy. Here's the configuration I use:

::: info /etc/btrbk.conf
```
backend_local_user     btrfs-progs-sudo
lockfile               /var/lock/btrbk.lock
snapshot_preserve      6h 2d 2w
snapshot_preserve_min  latest
ssh_identity           /etc/btrbk/ssh/btrbk
ssh_user               root
stream_buffer          256m
target_preserve        24h 7d 4w 12m 1y
target_preserve_min    latest
transaction_log        /var/log/btrbk.log

subvolume    /
	snapshot_dir 	/.snapshots
	target 		/mnt/backup/root/

subvolume 	/home
	snapshot_dir 	/home/.snapshots
	target 		/mnt/backup/home/

subvolume	/root
	snapshot_create	onchange
	snapshot_dir 	/root/.snapshots
	target 		/mnt/backup/root_user/

subvolume	/usr/local
	snapshot_create	onchange
	snapshot_dir 	/usr/local/.snapshots
	target 		/mnt/backup/usr_local/

subvolume	/opt
	snapshot_create	onchange
	snapshot_dir 	/opt/.snapshots
	target 		/mnt/backup/opt/
```
:::

I run it hourly out of cron:

::: info /etc/cron.hourly/btrbk
```sh
#!/bin/sh
exec /usr/local/bin/btrbk -q run
```
:::

Don't forget to rotate those logs:

::: info /etc/logrotate.d/btrbk
```
/var/log/btrbk.log {
	rotate 3
	monthly
```
:::

#### [Timeshift](https://github.com/linuxmint/timeshift)
::: tip
Requires [Ubuntu Style snapshot layout](#ubuntu-style).
:::

Not really backup, but snapshot automation. Snapshots are great because they are a copy of your data right next to your data, but for that reason they are not good backups -- if the hard drive your data is on dies and that's where your only snapshot copies are, well you're out of luck. A good backup solution should copy those snapshots to a different location, so you can still get them if your main drive fails; Timeshift doesn't have this, [btrbk](#btrbk) does.
The nice thing about it though, is it is built into some distros. 

### Maintenance

#### [btrfsmaintenance](https://github.com/kdave/btrfsmaintenance) 
This tool works well as a set and forget for always mounted drives. See [Maitenance Tasks](#maintenance-tasks) for a list of tasks to run manually on drives that are not always attached.

::: tip Configuration option
The special word/mountpoint "auto" will evaluate all mounted btrfs filesystems.
This is useful if you have multiple btrfs mount points and you just want them to be found without having to list them all.
:::

### Snapshot manipulation
#### [httm](https://github.com/kimono-koans/httm)
Winner for the coolest name: HTTM stands for "Hot Tub Time Machine".

### File system metrics
#### [compsize](https://github.com/kilobyte/compsize)
Useful for judging how effective [compression](https://btrfs.readthedocs.io/en/latest/Compression.html) is working on your subvolume.
`compsize` takes a list of files (given as arguments) on a btrfs filesystem and measures used compression types and effective compression ratio, producing a report.
```sh
➜  ~ sudo compsize /home
Processed 5525349 files, 969946 regular extents (9412294 refs), 1791531 inline.
Type       Perc     Disk Usage   Uncompressed Referenced  
TOTAL       65%       49G          75G         719G       
none       100%       30G          30G         340G       
zstd        41%       18G          45G         378G       
prealloc   100%      6.2M         6.2M         297M       
```

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