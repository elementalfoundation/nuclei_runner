# Nuclei Runner

Automate [ProjectDiscovery Nuclei](https://github.com/projectdiscovery/nuclei) scans with a reproducible container and ready-made GitHub Actions workflows. The image published by the workflows is pinned to an immutable base digest so every run executes the exact same Nuclei build.

## Repository Layout

- `Dockerfile` – builds the scan container, default command prints the Nuclei version.
- `targets/targets.txt` – default target list used for ad-hoc runs.
- `targets/<n>-<weekday>.yaml` – per-weekday target inventories used by the scheduled workflow.
- `.github/workflows/` – automation for building the image and running scans.

## Quick Start

### Run locally

```bash
# Build the image and drop into the container
docker build . -t nuclei_runner
docker run --rm -it nuclei_runner nuclei -list targets/targets.txt
```

Override the command to run any other Nuclei invocation, for example to run a specific template collection:

```bash
docker run --rm -it nuclei_runner nuclei -list targets/targets.txt -t cves/2024/
```

### Publish from GitHub Actions

1. Push to `main` (or any branch) to trigger `.github/workflows/0_build.yml`.
   The workflow builds the container, logs in to `ghcr.io`, and publishes two tags: `latest` and the commit SHA.
2. Retrieve the published image from `ghcr.io/<owner>/nuclei_runner:<tag>` for local or external use.

## Workflows

- **0_build.yml** &mdash; Builds and pushes the Docker image on every push. A second job performs a light-weight smoke test that runs `nuclei -version` inside the freshly published image.
- **1_ad_hoc_run.yml** &mdash; `workflow_dispatch` entry point. It checks out the repo and runs `nuclei -list targets.txt -cloud-upload`. Provide the optional `PDCP_API_KEY` secret to enable anonymous template sharing with ProjectDiscovery Cloud Platform. You can also invoke it manually via the workflow dispatch button.
- **2_scheduled_daily_run.yml** &mdash; Cron-triggered daily scan. The job selects the correct `targets/<n>-<weekday>.yaml`, copies it to `targets/targets.txt`, and runs the scan.

## Customising Targets

- Edit `targets/targets.txt` to maintain a single list shared by ad-hoc runs.
- Update the weekday YAML files to rotate through different asset groups; the filenames must stay in the `N-dayname` format that the workflow expects.

## Secrets and Environment

- `PDCP_API_KEY` (optional) enables uploading results to the ProjectDiscovery cloud during CI runs.

## Maintenance Notes

- Because the base image digest is pinned, update it periodically to pick up upstream Nuclei releases.
- GitHub Actions caching (`cache-to` / `cache-from`) is enabled for faster rebuilds. Clear or rotate the cache if you need to invalidate layers.
- Consider retagging immutable digests (e.g., `:prod`) once a build passes any additional hardening or smoke tests.

## License

Released under the terms of the [MIT License](LICENSE).
