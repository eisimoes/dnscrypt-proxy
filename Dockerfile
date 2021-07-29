FROM golang:latest AS builder

ARG DEBIAN_FRONTEND=noninteractive

ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=True

ARG DNSCRYPT_RELEASE

ENV CGO_ENABLED 0

WORKDIR /tmp

RUN : "${DNSCRYPT_RELEASE:?The argument DNSCRYPT_RELEASE is mandatory.}" \
    echo "**** Setting up repositories ****" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
    && echo "**** Cloning dnscrypt-proxy repository ****" \
    && git config --global advice.detachedHead false \
    && git clone --branch ${DNSCRYPT_RELEASE} --single-branch https://github.com/DNSCrypt/dnscrypt-proxy.git \
    && cd /tmp/dnscrypt-proxy/dnscrypt-proxy \
    && go build -v -ldflags="-s -w" \
    && sed -i "s/^listen_addresses = \['127.0.0.1:53'\]$/listen_addresses = \['0.0.0.0:53000'\]/g" example-dnscrypt-proxy.toml \
    && cd /tmp \
    && echo "**** Cloning dumb-init repository ****" \
    && git clone https://github.com/Yelp/dumb-init.git \
    && cd dumb-init \
    && make


FROM scratch

LABEL org.opencontainers.image.title="DNSCrypt Proxy"
LABEL org.opencontainers.image.description="DNS proxy with support for encrypted DNS protocols"
LABEL org.opencontainers.image.authors="Eduardo Simoes <eisimoes@yahoo.com>"
LABEL org.opencontainers.image.version=${DNSCRYPT_RELEASE}
LABEL org.opencontainers.image.documentation="https://github.com/eisimoes/dnscrypt-proxy"
LABEL org.opencontainers.image.url="https://github.com/eisimoes/dnscrypt-proxy"
LABEL org.opencontainers.image.source="https://github.com/eisimoes/dnscrypt-proxy"

COPY --from=builder /etc/passwd /etc/group /etc/

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /tmp/dnscrypt-proxy/dnscrypt-proxy/dnscrypt-proxy /usr/bin/

COPY --from=builder --chown=nobody:nogroup /tmp/dnscrypt-proxy/dnscrypt-proxy/example-dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml

COPY --from=builder /tmp/dumb-init/dumb-init /usr/bin/

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

COPY --from=builder /bin/ls /bin/ls

USER nobody

EXPOSE 53000/tcp

EXPOSE 53000/udp

ENTRYPOINT ["/usr/bin/dumb-init", "/usr/bin/dnscrypt-proxy", "-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml"]
