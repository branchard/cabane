# Cabane

A [Garage](https://garagehq.deuxfleurs.fr/) container image configurable entirely through environment variables.

## Why

Garage is normally configured through a `garage.toml` file, which you have to bind-mount into the
container. That's inconvenient if you want a self-contained, portable Compose file.

## How it works

At startup, the entrypoint renders the template into a real `garage.toml` and hands it off to the
`garage` binary.

## Usage

### Docker

```bash
docker run -d \
  -p 3900:3900 \
  -p 3902:3902 \
  -e ADMIN_TOKEN=DcG6+4c0eETRYT/7Bpz9qu+1xQu2DEcFClJaXnbEWgU= \
  -e RPC_SECRET=5047bda706e16d268f0558d3b5c2319a587155b09ff99f902c347f5cf1e6d37c \
  -e RPC_PUBLIC_ADDR=127.0.0.1:3901 \
  ghcr.io/branchard/cabane:latest
```

### Docker Compose

```yaml
services:
  cabane:
    image: ghcr.io/branchard/cabane:latest
    environment:
      ADMIN_TOKEN: DcG6+4c0eETRYT/7Bpz9qu+1xQu2DEcFClJaXnbEWgU=
      RPC_SECRET: 5047bda706e16d268f0558d3b5c2319a587155b09ff99f902c347f5cf1e6d37c
      RPC_PUBLIC_ADDR: garage:3901
    ports:
      - "3900:3900"
      - "3902:3902"
    volumes:
      - garage-meta:/var/lib/garage/meta
      - garage-data:/var/lib/garage/data
    healthcheck:
      test: [ "CMD", "/garage", "status" ]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 60s

volumes:
  garage-meta:
  garage-data:
```

## Environment variables

| Variable             | Required | Default                |
|----------------------|:--------:|------------------------|
| `METADATA_DIR`       |          | `/var/lib/garage/meta` |
| `DATA_DIR`           |          | `/var/lib/garage/data` |
| `DB_ENGINE`          |          | `sqlite`               |
| `REPLICATION_FACTOR` |          | `1`                    |
| `RPC_BIND_ADDR`      |          | `[::]:3901`            |
| `RPC_PUBLIC_ADDR`    | ✅       | —                      |
| `RPC_SECRET`         | ✅       | —                      |
| `S3_REGION`          |          | `garage`               |
| `S3_API_BIND_ADDR`   |          | `[::]:3900`            |
| `ADMIN_API_BIND_ADDR`|          | `[::]:3902`            |
| `ADMIN_TOKEN`        | ✅       | —                      |

`RPC_SECRET` must be a 32-byte hex string. You can generate one with `openssl rand -hex 32`.

## Image tags

Published to `ghcr.io/branchard/cabane` on every change to `main` or on new Garage releases:

- `latest`
- `<garage-version>-<revision>` (e.g. `2.4.1-1`)
- `<garage-version>`, `<major.minor>`, `<major>` (e.g. `2.4.1`, `2.4`, `2`)
