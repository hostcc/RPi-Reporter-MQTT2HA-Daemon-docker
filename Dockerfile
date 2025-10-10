ARG PYTHON_APT_VERSION=2.9.9
ARG PYTHON_VERSION=3.14.0
ARG DAEMON_VERSION=master

# Stage to build Python `apt` package for Alpine
FROM python:${PYTHON_VERSION}-alpine AS builder
ARG PYTHON_APT_VERSION
WORKDIR /build

RUN apk -U add gettext-dev apt-dev python3-dev gcc g++
# Recent `python-apt` versions require `DEBVER` environment variable to avoid
# calling into `dpkg-parsechangelog`, which apparently does not exist on
# Alpine
RUN DEBVER=${PYTHON_APT_VERSION} pip wheel \
	https://salsa.debian.org/apt-team/python-apt/-/archive/${PYTHON_APT_VERSION}/python-apt-${PYTHON_APT_VERSION}.tar.gz

# Final stage
FROM python:${PYTHON_VERSION}-alpine
ARG DAEMON_VERSION

RUN --mount=type=bind,from=builder,source=/build,target=/build \
	# Needed by recent versions of `RPi-Reporter-MQTT2HA-Daemon`
	apk -U add bash && \
	# For APT packages support, installs package built in the previous stage
	pip install /build/python_apt-*.whl && \
	apk -U add dpkg apt-libs && \
	# For temperatures/throttling support (via `vcgencmd`)
	apk -U add raspberrypi-userland && \
	wget \
		https://raw.githubusercontent.com/ironsheep/RPi-Reporter-MQTT2HA-Daemon/${DAEMON_VERSION}/ISP-RPi-mqtt-daemon.py \
		-O /usr/local/bin/rpi-mqtt-daemon && \
	pip install -r https://raw.githubusercontent.com/ironsheep/RPi-Reporter-MQTT2HA-Daemon/${DAEMON_VERSION}/requirements.txt && \
	chmod +x /usr/local/bin/rpi-mqtt-daemon

USER nobody	
ENTRYPOINT ["rpi-mqtt-daemon", "-c", "/etc/rpi-mqtt-daemon"]
