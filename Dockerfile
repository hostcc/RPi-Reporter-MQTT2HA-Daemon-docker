# Stage to build Python `apt` package for Alpine
FROM python:3.13.0b4-alpine as builder
ARG PYTHON_APT_VERSION=2.5.3
WORKDIR /build

RUN apk -U add gettext-dev apt-dev python3-dev gcc g++
RUN env && pip wheel \
	https://salsa.debian.org/apt-team/python-apt/-/archive/${PYTHON_APT_VERSION}/python-apt-${PYTHON_APT_VERSION}.tar.gz

FROM python:3.13.0b4-alpine
ARG DAEMON_VERSION=master

# Final stage
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
