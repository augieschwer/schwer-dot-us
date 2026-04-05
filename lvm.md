Using lvmcache with a 750GB backing disk and a 120GB cache disk.

```sh
➜  ~ sudo lvdisplay | grep Cache
  LV Cache pool name     lv_cache_cpool
  LV Cache origin name   backup_lv_corig
  Cache used blocks      79.95%
  Cache metadata blocks  16.35%
  Cache dirty blocks     0.00%
  Cache read hits/misses 1335289 / 398697
  Cache wrt hits/misses  361936 / 913327
  Cache demotions        0
  Cache promotions       731578
  ```

Cache disk is 80% full, and pretty good cache hit ratio on reads (after backup, I'm cloning backups to another external drive).

The advantage to using lvmcache is you can add a cacheing disk to an existing LVM setup, which is nice because other solutions require you to wipe the drives first before building the cache and backing drive setup.

Other notables -- there are two cache modes:
The default dm-cache cache mode is "writethrough".  Writethrough
 ensures that any data written will be stored both in the cache and
 on the origin LV.  The loss of a device associated with the cache
 in this case would not mean the loss of any data.

 A second cache mode is "writeback".  Writeback delays writing data
 blocks from the cache back to the origin LV.  This mode will
 increase performance, but the loss of a cache device can result in
 lost data.