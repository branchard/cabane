ARG GARAGE_VERSION

FROM dxflrs/garage:${GARAGE_VERSION} AS garage

FROM alpine:latest

ARG GARAGE_VERSION

ENV RUST_BACKTRACE=1
ENV RUST_LOG=garage=info

RUN apk add --no-cache bash

COPY --from=garage /garage /garage
COPY garage.toml /etc/garage.toml.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# -- Labels --
# Placed last on purpose: VERSION/VCS_REF/BUILD_DATE change on every commit,
# and an ARG's value invalidates the build cache for every instruction after
# its declaration in a stage — even ones that don't reference it. Declaring
# them (and LABEL, which adds no filesystem layer) at the very end keeps the
# actual content-producing steps above reproducible/cacheable across builds
# that only differ by these three values.
ARG VERSION
ARG VCS_REF
ARG BUILD_DATE
LABEL org.opencontainers.image.title="cabane" \
      org.opencontainers.image.description="Garage, fully configurable via environment variables" \
      org.opencontainers.image.source="https://github.com/branchard/cabane" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      io.cabane.garage.version="${GARAGE_VERSION}"
