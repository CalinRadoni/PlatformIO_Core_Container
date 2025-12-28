In this implementation:

- [PlatformIO Core (CLI)](https://docs.platformio.org/en/latest/core/index.html) is installed in container
- the frameworks, tools, packages, etc. are installed in a host directory

The examples are for [Podman](https://podman.io/) but can be used with [Docker](https://www.docker.com/); just write `docker` instead of `podman` (or alias it with `alias podman=docker`) .

I used this container to build projects mostly for ESP32 with Arduino on the [pioarduino community platform](https://github.com/pioarduino/platform-espressif32) .

## Container image

```sh
# build the image
podman build --build-arg=PLATFORMIO_VERSION=latest -t pio .
# and create the directory for platformio
mkdir -p /data/platformio
```

## Usage

Running the contaner without argument will run a `bash` shell.

Running the container with arguments will run `pio` inside the container with the same arguments. 

For basics of `PlatformIO Core (CLI)` see PlatformIO Core's [Quick Start](https://docs.platformio.org/en/latest/core/quickstart.html).

PlatformIO Core's [CLI Guide](https://docs.platformio.org/en/latest/core/userguide/index.html) have all the commands and options.

Examples:

```sh
# pio -h
podman run -it --rm pio -h

# pio pkg list
podman run -it --rm \
    -v /data/platformio:/platformio:Z \
    -v "${PWD}":/project:Z \
    pio pkg list
```

### Upload preparation

In Linux you have to install `udev` rules for your boards / devices.

I prefer to add rules only for the devices that I have (see [Non-root access for ST-LINK and USB-to-serial devices](https://calinradoni.github.io/blog/non-root_access_usb/) if you want more details):

```sh
#!/bin/bash

# udev rule for boards with the CP2102 USB-to-serial convertor
sudo tee /etc/udev/rules.d/70-cp2102.rules > /dev/null <<'EOF'
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="600", TAG+="uaccess"
EOF

# udev rule for boards with the CH340 USB-to-serial convertor
sudo tee /etc/udev/rules.d/70-ch340.rules > /dev/null <<'EOF'
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="600", TAG+="uaccess"
EOF

# reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

but you can add the whole list from PlatformIO (see [99-platformio-udev.rules](https://docs.platformio.org/en/latest/core/installation/udev-rules.html) if you want more details):

```sh
# download the rules straight to the destination directory
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules

# reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### Initialize a project

Initialize a new empty project or update existing with the new data:

```sh
# empty initialization
podman run -it --rm -v /data/platformio:/platformio:Z -v "${PWD}":/project:Z \
    pio project init

# or, more specific example:
podman run -it --rm -v /data/platformio:/platformio:Z -v "${PWD}":/project:Z \
    pio project init --board esp32dev --project-option \
        "platform=https://github.com/pioarduino/platform-espressif32/releases/download/stable/platform-espressif32.zip"
```

These are the pre-configured [Boards](https://docs.platformio.org/en/latest/boards/index.html) - also, the list can be obtained with `pio boards` equivalent `podman run -it --rm pio boards`

### Build workflow

Here is a simple build workflow. Run these commands in the directory where the file `platformio.ini` is located:

```sh
podman run -it --rm -v /data/platformio:/platformio:Z -v "${PWD}":/project:Z pio run

podman run -it --rm -v /data/platformio:/platformio:Z -v "${PWD}":/project:Z \
    --device /dev/ttyUSB0 \
    pio run --target upload

podman run -it --rm -v /data/platformio:/platformio:Z -v "${PWD}":/project:Z \
    --device /dev/ttyUSB0 \
    pio run --target monitor

podman run -it --rm -v /data/platformio:/platformio:Z -v "${PWD}":/project:Z pio run --target clean
```

## License

This repository is licensed under the terms of [GNU GPLv3](http://www.gnu.org/licenses/gpl-3.0.html) license. See the `LICENSE-GPLv3.txt` file.
