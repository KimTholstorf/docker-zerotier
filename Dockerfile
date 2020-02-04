FROM --platform=$BUILDPLATFORM debian:buster-slim AS buildstage

ENV ZEROTIER_VERSION=1.4.6
RUN apt-get update && apt-get install -y curl gnupg && \
    apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 0x1657198823e52a61  && \
    echo "deb http://download.zerotier.com/debian/buster buster main" > /etc/apt/sources.list.d/zerotier.list && \
    apt-get update && apt-get install -y zerotier-one=$ZEROTIER_VERSION
COPY main.sh /var/lib/zerotier-one/main.sh

FROM alpine:latest
LABEL VERSION="1.4.6"
LABEL MAINTAINER="kim@tholstorf.dk"
LABEL DISCRIPTION="Containerized ZeroTier for Docker Linux hosts. NOTE: Needs to run with priviledged network access to work :("
##   docker run --name zerotier-one \
##              --device=/dev/net/tun --net=host --cap-add=NET_ADMIN --cap-add=SYS_ADMIN \
##              --volume=/var/lib/zerotier-one:/var/lib/zerotier-one kimtholstorf/zerotier

RUN apk add --update --no-cache libgcc libc6-compat libstdc++
RUN mkdir -p /var/lib/zerotier-one
COPY --from=buildstage /usr/sbin/zerotier-one /usr/sbin/zerotier-one
COPY --from=buildstage /usr/sbin/zerotier-cli /usr/sbin/zerotier-cli
COPY --from=buildstage /usr/sbin/zerotier-idtool /usr/sbin/zerotier-idtool
COPY --from=buildstage /var/lib/zerotier-one/main.sh /main.sh
RUN chmod 0755 /main.sh

EXPOSE 9993/udp

ENTRYPOINT ["/main.sh"]
CMD ["zerotier-one"]