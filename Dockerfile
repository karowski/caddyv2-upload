FROM ubuntu:latest

ENV XCADDY_VERSION=0.3.5 \
    GOLANG_VERSION=20.10 \
    APPPORT=:2011 \
    UPLOADER_VERSION=0.15

COPY docker-files /

RUN set -x \
  && apt-get -y update \
  && apt-get install -y curl libterm-readline-perl-perl \
  && mkdir build \
  && cd build \
  && curl -sSLO https://github.com/caddyserver/xcaddy/releases/download/v${XCADDY_VERSION}/xcaddy_${XCADDY_VERSION}_linux_amd64.tar.gz \
  && curl -sSLO https://go.dev/dl/go1.${GOLANG_VERSION}.linux-amd64.tar.gz \
  && rm -rf /usr/local/go \
  && tar -C /usr/local -xzf go1.${GOLANG_VERSION}.linux-amd64.tar.gz \
  && export PATH=$PATH:/usr/local/go/bin \
  && tar xfvz xcaddy_${XCADDY_VERSION}_linux_amd64.tar.gz \
  && ./xcaddy build --with github.com/kirsch33/realip \
    --with github.com/git001/caddyv2-upload \
    --with github.com/caddyserver/jsonc-adapter \
  && pwd \
  && mv caddy /usr/local/bin/ \
  && cd .. \
  && apt-get -y autoremove \
  && apt-get -y autoclean \
  && rm -rf build /usr/local/go /var/cache/apk/* root/.cache root/go/ \
  && /usr/local/bin/caddy list-modules \
  && /usr/local/bin/caddy version

WORKDIR /opt/webroot/

CMD ["/usr/local/bin/caddy","run","--config","config/Caddyfile-upload.json"]
