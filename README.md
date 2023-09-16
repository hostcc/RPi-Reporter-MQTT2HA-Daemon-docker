# Docker images for RPi-Reporter-MQTT2HA-Daemon

The repository provides unofficial container images for
[RPi-Reporter-MQTT2HA-Daemon](https://github.com/ironsheep/RPi-Reporter-MQTT2HA-Daemon).
A best effort attempt has been made to make most of its functionality working
when run as container, although there might be issues specific to that
environment.

Please note the images are built irregularly, please open up an
[issue](https://github.com/hostcc/RPi-Reporter-MQTT2HA-Daemon-docker/issues) if
you believe an upstream version needs a build.

## Highlights

* Provides most of daemon functionality when run as container
* Runs as regular `nobody` user
* Does not require privileged container
* Does assume the host uses APT packaging system, though should be safely
  handling other managers

## How to use

Following Docker command should be sufficient to run the daemon as container.
Please note the command options are not exhaustive, and should be extended to
fit your use case.

While the command is provided for Docker it should be somewhat straightforward
to use other container runtimes.

```
$ docker run --detach --restart=unless-stopped \
  --device /dev/vcio:/dev/vcio \
  -v <path to daemon configuration directory on host>/:/etc/rpi-mqtt-daemon/:ro \
  -v /var/lib/dpkg/:/var/lib/dpkg/:ro \
  -v /etc/apt:/etc/apt:ro \
  -v /var/lib/apt/:/var/lib/apt/:ro \
  -v /etc/localtime:/etc/localtime:ro \
  --security-opt="systempaths=unconfined" \
  --group-add video \
  --hostname <hostname sent to Home Assistant> \
  ghcr.io/hostcc/rpi-reporter-mqtt2ha-daemon-docker:latest
```

Key options explained:
* `--device /dev/vcio:/dev/vcio` and `--group-add video` are needed to interact
  with Raspberry Pi specific hardware reading the temperatures/throttling status
  (the daemon uses `vcgencmd` for that, the tools is included into the image)
* `--security-opt="systempaths=unconfined"` unmasks `/proc/device-tree`, which
  daemon uses to read hardware information
* `-v /var/lib/dpkg/:/var/lib/dpkg/:ro`, `-v /etc/apt:/etc/apt:ro` and `-v
  /var/lib/apt/:/var/lib/apt/:ro` expose APT/DPKG related paths on host to
  container, for daemon to determine when packages has been updated, and if any
  updates are pending
* `-v /etc/localtime:/etc/localtime:ro` provides timezone definition to the
  container, for daemon to determine local time (same as the host is configured
  for)
* `-v <path to daemon configuration directory on
  host>/:/etc/rpi-mqtt-daemon/:ro` exposes directory where daemon configuration
  resides to the container. The directory might be useful if your configuration
  comprises of several files (e.g. daemon configuration file and SSL/TLS
  certificates), although you could use `-v <path to daemon configuration
  directory on
  host>/config.ini:/etc/rpi-mqtt-daemon/config.ini:ro` if your daemon
  configuration considers `config.ini` only
* `--hostname <hostname sent to Home Assistant>` is needed to make the MQTT
  discovered device be named in a meaningful manner - host name would be
  container ID rather
