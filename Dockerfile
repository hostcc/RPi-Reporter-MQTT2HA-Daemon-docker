FROM python:3.10-alpine

ARG version

RUN \
	# For `vcgencmd`
	apk -U add raspberrypi-userland && \
	wget \
		https://raw.githubusercontent.com/ironsheep/RPi-Reporter-MQTT2HA-Daemon/${version}/ISP-RPi-mqtt-daemon.py \
		-O /usr/local/bin/rpi-mqtt-daemon && \
	pip install -r https://raw.githubusercontent.com/ironsheep/RPi-Reporter-MQTT2HA-Daemon/${version}/requirements.txt && \
	chmod +x /usr/local/bin/rpi-mqtt-daemon

USER nobody	
ENTRYPOINT ["rpi-mqtt-daemon", "-c", "/etc/rpi-mqtt-daemon"]
