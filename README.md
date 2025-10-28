# Nuclei Runner

Automate [ProjectDiscovery Nuclei](https://github.com/projectdiscovery/nuclei) scans with Nuclei docker container and ready-made GitHub Actions workflows.

## Usage

You can:

1. Put your targets in `targets/targets.txt` and trigger the `1_ad_hoc_run.yml` workflow. When done the action results will show a link to a Nuclei result page (if you entered your Nuclei API key as `PDCP_API_KEY` in your Github Action secrets.)

2. Spread your targets out over the week by using files like `targets/monday.yml`. The `2_scheduled_daily_run` workflow will be triggered every day at 14.20 UTC. Again, if given the Nuclei API key (`PDCP_API_KEY`), the results will be posted to a dashboard and a link will be given in the workflow output.

Example of result output:

```
[INF] 30 Scan results uploaded to cloud, you can view scan results at https://cloud.projectdiscovery.io/scans/d40id9p95n6c7389p2m0?team_id=none
```


## Development

### Repository Layout

- `Dockerfile` – builds the scan container, default command prints the Nuclei version.
- `targets/targets.txt` – default target list used for ad-hoc runs.
- `targets/<n>-<weekday>.yaml` – per-weekday target inventories used by the scheduled workflow.
- `.github/workflows/` – automation for building the image and running scans.

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

### Workflows

- **0_build.yml** &mdash; Builds and pushes the Docker image on every push. A second job performs a light-weight smoke test that runs `nuclei -version` inside the freshly published image.
- **1_ad_hoc_run.yml** &mdash; `workflow_dispatch` entry point. It checks out the repo and runs `nuclei -list targets.txt -cloud-upload`. Provide the optional `PDCP_API_KEY` secret to enable anonymous template sharing with ProjectDiscovery Cloud Platform. You can also invoke it manually via the workflow dispatch button.
- **2_scheduled_daily_run.yml** &mdash; Cron-triggered daily scan. The cron schedule is defined inside the workflow file. The job selects the correct `targets/<n>-<weekday>.yaml`, copies it to `targets/targets.txt`, and runs the scan.

### Customising Targets

- Edit `targets/targets.txt` to maintain a single list shared by ad-hoc runs.
- Update the weekday YAML files to rotate through different asset groups; the filenames must stay in the `N-dayname` format that the workflow expects.

### Secrets and Environment

- `PDCP_API_KEY` (optional) enables uploading results to the ProjectDiscovery cloud during CI runs.

### Maintenance Notes

- Because the base image digest is pinned, update it periodically to pick up upstream Nuclei releases.
- GitHub Actions caching (`cache-to` / `cache-from`) is enabled for faster rebuilds. Clear or rotate the cache if you need to invalidate layers.

## License

Released under the terms of the [MIT License](LICENSE).
