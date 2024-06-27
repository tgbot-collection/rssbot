FROM rust:alpine as builder

RUN apk update && apk add --no-cache git libc-dev ca-certificates tzdata && rustup install nightly

COPY . /rssbot
WORKDIR /rssbot
RUN cargo +nightly build --release


FROM alpine
ENV TZ=Asia/Shanghai

COPY --from=builder ["/rssbot/target/release/rssbot", "/usr/local/bin"]
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

CMD rssbot --database /root/rssbot.json --min-interval 900 $TOKEN