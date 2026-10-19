# bw serve for External Secrets Operator's webhook provider (works with Bitwarden and Vaultwarden).
# Official Bitwarden CLI binary, checked against the sha256 GitHub shows for the release asset.
# Bumping the version: change BW_VERSION and BW_SHA256 together (the build fails on a mismatch). Digest from
#   curl -s https://api.github.com/repos/bitwarden/clients/releases/tags/cli-v<version> | jq -r '.assets[] | select(.name=="bw-oss-linux-<version>.zip").digest'
FROM debian:trixie-slim@sha256:a29215f6a35e51e22adffa17f89e9d2ef06214e64a2bad10d765c46aea49f11f AS download
# renovate: datasource=github-releases depName=bitwarden/clients extractVersion=^cli-v(?<version>.+)$
ARG BW_VERSION=2026.10.0
ARG BW_SHA256=b90c0fc86bcf11c0b194aa3f0a89344738af0512cb267c39ad3250c5edd71663
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl unzip \
 && curl -fsSLo /tmp/bw.zip "https://github.com/bitwarden/clients/releases/download/cli-v${BW_VERSION}/bw-oss-linux-${BW_VERSION}.zip" \
 && echo "${BW_SHA256}  /tmp/bw.zip" | sha256sum -c - \
 && unzip -d /usr/local/bin /tmp/bw.zip bw \
 && chmod 0755 /usr/local/bin/bw

FROM debian:trixie-slim@sha256:a29215f6a35e51e22adffa17f89e9d2ef06214e64a2bad10d765c46aea49f11f
LABEL org.opencontainers.image.source="https://github.com/webend-uk/bitwarden-cli" \
      org.opencontainers.image.description="Official Bitwarden CLI (bw serve) for External Secrets Operator's webhook provider"
# curl: lets a liveness probe force a vault sync through bw serve.
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --uid 1000 --create-home bw
COPY --from=download /usr/local/bin/bw /usr/local/bin/bw
COPY --chmod=0755 entrypoint.sh /entrypoint.sh
USER 1000
ENV BITWARDENCLI_APPDATA_DIR=/home/bw/data
EXPOSE 8087
ENTRYPOINT ["/entrypoint.sh"]
