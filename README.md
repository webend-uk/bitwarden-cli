# bitwarden-cli

`bw serve` in a container, for the [External Secrets Operator webhook provider](https://external-secrets.io/latest/examples/bitwarden/). Works with Bitwarden and Vaultwarden.

```
ghcr.io/webend-uk/bitwarden-cli:<bw version>
```

## How it is built

- Bitwarden's official `bw-oss-linux` zip from [bitwarden/clients releases](https://github.com/bitwarden/clients/releases), checked against a sha256 pinned in the [Dockerfile](Dockerfile).
- Base `debian:trixie-slim`, pinned by digest. Runs as UID 1000. Works with a read-only root filesystem if `/home/bw/data` and `/tmp` are writable.
- Built and pushed by [GitHub Actions](.github/workflows/build.yaml) on every commit to `main`. Tags: the `bw` version, and `sha-<commit>`.

## Environment

| Variable | Value |
|---|---|
| `BW_HOST` | Server URL, e.g. `https://vault.example.com` |
| `BW_CLIENTID`, `BW_CLIENTSECRET` | The account's personal API key |
| `BW_PASSWORD` | The account's master password (to unlock) |

The container logs in with the API key, unlocks the vault and runs `bw serve --hostname all --port 8087`.

## Security

`bw serve` has **no authentication**: anything that can reach port 8087 can read the whole vault of that account. Use an account that can only see the items your cluster needs, and put a NetworkPolicy in front of the pod that admits only the External Secrets controller.

## Updating

Renovate proposes new `bw` versions. Update `BW_SHA256` in the same PR; the PR build fails until it matches.
