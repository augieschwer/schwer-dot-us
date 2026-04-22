---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "Schwer.us"
  text: "Schwer, like where?"
  tagline: Projects, and documentation.
  actions:
    - theme: alt
      text: Checkout the code for this site on GitHub
      link: https://github.com/augieschwer/schwer-dot-us
features:
  - title: BTRFS
    details: Documentation and configuration for my btrfs setup.
    link: btrfs.md
    linkText: BTRFS
  - title: BTRFS
    details: Logical Volume Manager - my LVM setup leveraging lvmcache to speedup reads and writes to an external backup drive.
    link: lvm.md
    linkText: LVM
  - title: HPACUCLI
    details: HP Array Configuration Utility CLI - a quick BASH script I wrote to notify you via email if a drive in your RAID array goes bad.
    link: hpacucli.md
    linkText: HPACUCLI
---