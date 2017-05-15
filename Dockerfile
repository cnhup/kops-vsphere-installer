FROM alpine:3.5
MAINTAINER miaol@vmware.com

# Install Docker and dependencies
RUN apk --update add \
  bash \
  curl \
  docker \
  && rm -rf /var/cache/apk/*

COPY coredns /coredns
COPY minio /minio
COPY deploy-template.sh /deploy-template.sh
COPY install.sh /install.sh

ENTRYPOINT /install.sh
