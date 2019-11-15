# Multi-stage builds
FROM bitnami/minideb:stretch

RUN apt-get update && apt-get -y install git
RUN git clone https://github.com/BayLibre/lava-healthchecks-binary.git



FROM debian:stretch-backports

RUN apt -q update
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
	lighttpd \
	vsftpd

ARG extra_packages=""
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install ${extra_packages}

ARG http_port=80
ENV PORT_HTTP=${http_port}

ARG ftp_port=21
ENV PORT_FTP=${ftp_port}

ARG root_path="/wwwroot"
ENV ROOT=$root_path

COPY --from=0 lava-healthchecks-binary/mainline /root/healthcheck/mainline/
COPY --from=0 lava-healthchecks-binary/images /root/healthcheck/images/
COPY --from=0 lava-healthchecks-binary/next /root/healthcheck/next/
COPY --from=0 lava-healthchecks-binary/stable /root/healthcheck/stable/

COPY scripts/entrypoint.sh /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
