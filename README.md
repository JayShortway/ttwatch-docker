# ttwatch-docker
Dockerized [ttwatch](https://github.com/ryanbinns/ttwatch)

## How to

### Option A: Use a symlink
Steps 1 through 4 only have to be performed at first use.
1. Figure out the vendor and product ID of your watch using `lsusb`. Use `lsusb -v` for more descriptive output.
2. Create a `udev` rule file on the host at `/etc/udev/rules.d/99-tomtom-watch.rules`, and add the following rule. Make sure the vendor and product ID are correct for your watch.
```shell
SUBSYSTEM=="usb", ATTR{idVendor}=="1390", ATTR{idProduct}=="7474", SYMLINK+="tomtom_watch"
```
3. Reload the `udev` rules:
```shell
sudo udevadm control --reload-rules
sudo udevadm trigger
```
4. Reconnect the watch, and check that the symlink works:
```shell
ls -l /dev/tomtom_watch
```
5. Now you can run:

```shell
docker run --device=$(readlink -f /dev/tomtom_watch) --rm ghcr.io/jayshortway/ttwatch-docker:2025-03-11 ttwatch --devices
```

It should output your watch's name and serial.

### Option B: Use the device path
Both steps have to be performed for every use.
1. Figure out the device's bus and device ID using `lsusb`. 
2. Then run:

```shell
docker run --device=/dev/bus/usb/<bus-id>/<device-id> --rm ghcr.io/jayshortway/ttwatch-docker:2025-03-11 ttwatch --devices
```

It should output your watch's name and serial.
