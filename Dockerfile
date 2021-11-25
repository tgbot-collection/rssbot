FROM rust:alpine as builder

RUN apk update && apk add --no-cache git libc-dev ca-certificates tzdata && rustup install nightly && \
    echo -e "#!/bin/sh \n/rssbot  -d /database.json --min-interval 900 \${TOKEN}" > /entrypoint.sh \
    && chmod +x /entrypoint.sh

COPY . /rssbot
WORKDIR /rssbot
RUN cargo +nightly build --release


FROM alpine
ENV TZ=Asia/Shanghai

COPY --from=builder ["/rssbot/target/release/coolbot", "/entrypoint.sh", "/"]
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
RUN mv /coolbot /rssbot
CMD ["/entrypoint.sh"]