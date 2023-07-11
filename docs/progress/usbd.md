# Analysis of `usbd`

- Watches following files with inotify:
  - `/sys/class/udc/19c00000.dwc3/state`
  - `/sys/class/udc/19c00000.dwc3/current_speed`
- When the content of `/sys/class/udc/19c00000.dwc3/state` is changed to `configured` the daemon starts doing some work
