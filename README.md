# Dockerfile for dnscrypt-proxy

[![DNSCrypt logo](https://user-images.githubusercontent.com/31744379/127190173-92056864-f7d6-41fa-8888-cc6ab591c24b.png)](https://github.com/eisimoes/dnscrypt-proxy)

[![GitHub Discussions](https://badgen.net/badge/GitHub/Discussions?color=blue&icon=github)](https://github.com/eisimoes/dnscrypt-proxy/discussions)
[![Latest Release](https://badgen.net/github/release/eisimoes/dnscrypt-proxy?color=blue&label=Latest%20Release)](https://github.com/eisimoes/dnscrypt-proxy/releases)
[![Latest Tag](https://badgen.net/github/tag/eisimoes/dnscrypt-proxy?color=blue&label=Latest%20Tag)](https://github.com/eisimoes/dnscrypt-proxy/tags)
[![Open Issues](https://badgen.net/github/open-issues/eisimoes/dnscrypt-proxy?color=blue&label=Open%20Issues)](https://github.com/eisimoes/dnscrypt-proxy/issues)
[![License](https://badgen.net/github/license/eisimoes/dnscrypt-proxy?color=blue&label=License)](https://github.com/eisimoes/dnscrypt-proxy/blob/master/LICENSE)


This Dockerfile was originally created to build arm32v7 images of dnscrypt-proxy (for use in Raspberry Pi 4). However, it can be used to build images for other architectures as well.

## Build

```bash
# Build a local image
docker image build --pull --build-arg DNSCRYPT_RELEASE="2.0.45" -t eisimoes/dnscrypt-proxy:2.0.45 .
```

## Tests

```bash
# Create a container
docker run --rm -d --name dnscrypt eisimoes/dnscrypt-proxy
# Test the container
docker run --rm -it --link dnscrypt alpine sh -c "apk add bind-tools; dig +dnssec -p 53000 dnscrypt.info @dnscrypt"
```

## How to use?

Create a *dnscrypt-proxy* container using the image's default configuration file.

```bash
docker run -d -p 53:53000/tcp -p 53:53000/udp eisimoes/dnscrypt-proxy
```

Set the timezone and use a customized configuration file<sup>1</sup>.

```bash
# Using a custom configuration directory
docker run -d -p 53:53000/tcp -p 53:53000/udp -e TZ=America/Sao_Paulo -v /path/to/config/:/etc/dnscrypt-proxy/ eisimoes/dnscrypt-proxy
# Using a custom configuration file
docker run -d -p 53:53000/tcp -p 53:53000/udp -e TZ=America/Sao_Paulo -v /path/to/config/file:/etc/dnscrypt-proxy/dnscrypt-proxy.toml eisimoes/dnscrypt-proxy
```
1: The directory and/or the configuration file must be readable by nobody:nogroup.

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.

<https://github.com/eisimoes/dnscrypt-proxy/issues>

## Credits

Based on <https://github.com/klutchell/dnscrypt-proxy>.

## License

- eisimoes/dnscrypt-proxy: [MIT License](./LICENSE)
- DNSCrypt/dnscrypt-proxy: [ISC License](https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/LICENSE)
