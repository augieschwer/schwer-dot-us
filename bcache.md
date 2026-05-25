# Bcache

Bcache is a Linux kernel block layer cache. It allows one or more fast storage devices (like SSDs) to be used as a cache for slower storage devices (like HDDs). This can significantly improve the performance of the slower storage devices by caching frequently accessed data on the faster devices.

## Documentation
- [Bcache Documentation](https://www.kernel.org/doc/html/latest/admin-guide/bcache.html)
- [Bcache Arch Documentation](https://wiki.archlinux.org/title/Bcache)

## Installation
```sh
apt install bcache-tools
```