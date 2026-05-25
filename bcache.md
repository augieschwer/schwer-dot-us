# Bcache

Bcache is a Linux kernel block layer cache. It allows one or more fast storage devices (like SSDs) to be used as a cache for slower storage devices (like HDDs). This can significantly improve the performance of the slower storage devices by caching frequently accessed data on the faster devices.

## Documentation
- [Bcache Documentation](https://www.kernel.org/doc/html/latest/admin-guide/bcache.html)
- [Bcache Arch Documentation](https://wiki.archlinux.org/title/Bcache)

## Installation
```sh
apt install bcache-tools
```

## Usage
```sh
make-bcache -B /dev/sdd -C /dev/sdc
```
This command creates a bcache device by using `/dev/sdd` as the backing device (the slower storage) and `/dev/sdc` as the caching device (the faster storage). After running this command, you can use the new bcache device for your storage needs, and it will automatically cache data from the backing device to improve performance.

### Encryption
```sh
cryptsetup luksFormat /dev/bcache0
cryptsetup open /dev/bcache0 bcache0_crypt
```
This example shows how to encrypt the bcache device using LUKS. The first command formats the bcache device with LUKS encryption, and the second command opens the encrypted device, making it available for use under the name `bcache0_crypt`. You can then use `bcache0_crypt` as you would any other block device, and it will be encrypted on disk.

#### Crypttab Configuration
::: info /etc/crypttab
```
# Fields are: name, underlying device, passphrase, cryptsetup options.

# Mount /dev/bcache0 as /dev/mapper/bcache0_crypt and prompt for the passphrase at boot time.
bcache0_crypt /dev/bcache0 none luks
```
:::
This line in the `/etc/crypttab` file configures the system to automatically open the encrypted bcache device at boot time, prompting the user for the passphrase.

### Filesystem Creation
```sh
mkfs.btrfs /dev/mapper/bcache0_crypt
```
After opening the encrypted bcache device, you can create a filesystem on it. In this example, we are creating a Btrfs filesystem on the encrypted bcache device. You can replace `btrfs` with any other supported filesystem type if you prefer. Once the filesystem is created, you can mount it and start using it for your data storage needs.

## Performance considerations
```sh
echo writeback > /sys/block/bcache0/bcache/cache_mode
```
This command sets the cache mode of the bcache device to "writeback". In writeback mode, data is written to the cache device first and then later flushed to the backing device. This can improve performance for write operations, but it also means that there is a risk of data loss if the cache device fails before the data is flushed to the backing device. It's important to choose the appropriate cache mode based on your performance needs and risk tolerance. Other cache modes include "writethrough", where data is written to both the cache and backing devices simultaneously, and "writearound", where data is written directly to the backing device without being cached.

## Bcache Status
```sh
cat /sys/block/bcache0/bcache/state
```
This command displays the current state of the bcache device.
The output will show information about the cache device, backing device, cache mode, and other relevant details. This can be useful for monitoring the performance and health of your bcache setup, as well as for troubleshooting any issues that may arise.

```sh
cat /sys/block/bcache0/bcache/cache_mode
```
This command displays the current cache mode of the bcache device. The output will indicate whether the cache mode is set to "writeback", "writethrough", or "writearound". Knowing the current cache mode can help you understand how data is being handled by the bcache device and can assist in making informed decisions about performance tuning and data safety.
