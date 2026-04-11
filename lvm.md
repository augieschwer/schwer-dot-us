# LVM

## lvmcache

The advantage to using lvmcache is you can add a cacheing disk to an existing LVM setup, which is nice because other solutions require you to wipe the drives first before building the cache and backing drive setup.

For example is an external drive setup I have for backups; which uses a 750GB HDD backing disk and a 120GB SSD cache disk.

![lvmcache disks](./lvmcache.jpg)

```sh
➜  ~ sudo lvdisplay | grep Cache
  LV Cache pool name     lv_cache_cpool
  LV Cache origin name   backup_lv_corig
  Cache used blocks      99.99%
  Cache metadata blocks  24.39%
  Cache dirty blocks     0.00%
  Cache read hits/misses 5230927 / 1018894
  Cache wrt hits/misses  8805521 / 1427088
  Cache demotions        28982
  Cache promotions       28965
  ```
Cache disk is 100% full, and cache hit ratio is 5:1 for reads and 6:1 for writes.

### Documentation

[lvmcache(7)](https://man7.org/linux/man-pages/man7/lvmcache.7.html)

[Creating LVM Cache Logical Volumes](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/logical_volume_manager_administration/lvm_cache_volume_creation)

::: tip
The default dm-cache cache mode is "writethrough".  Writethrough
 ensures that any data written will be stored both in the cache and
 on the origin LV.  The loss of a device associated with the cache
 in this case would not mean the loss of any data.

 A second cache mode is "writeback".  Writeback delays writing data
 blocks from the cache back to the origin LV.  This mode will
 increase performance, but the loss of a cache device can result in
 lost data.
 :::