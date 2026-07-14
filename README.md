# Reusable GitHub Actions Workflow

## Utility
| Reusable Workflow | Description | Usage |
| --------------- | --------------- | --------------- |
| `reusable-timestamp.yml` | print out workflow start time | [README](docs/utility/readme-reusable-lint-go-workflow.md) |

## Security Baselines
| Asset | Description | Usage |
| --------------- | --------------- | --------------- |
| `docs/security/secret-taxonomy.md` | TN-wide secret taxonomy, severity model, and remediation rules | Read before tuning secret-scanning workflows |
| `security/gitleaks/tn-gitleaks.toml` | Shared Gitleaks rules for TN-specific and general software-engineering secrets | Used by `reusable-secrets-scanning.yml` |
| `.github/workflows/reusable-secrets-scanning.yml` | Reusable TN secret scan workflow that runs Gitleaks and TruffleHog | Call from TN repositories for PR, push, or manual history scans |

## Reusable Secret Scanning

`reusable-secrets-scanning.yml` runs both scanner engines:

- Gitleaks with `security/gitleaks/tn-gitleaks.toml` for TN-specific blocking rules.
- TruffleHog with verified-secret detection enabled.

Supported scan modes:

- `pr`: scans pull request changes and fails on findings at or above `fail_threshold`.
- `push`: scans new pushed commits and fails on findings at or above `fail_threshold`.
- `history`: scans available repository history for inventory and does not block by default.

The workflow intentionally does not print raw secret values in logs, step summaries, artifacts, or Slack notifications. Summaries include scanner engine, severity, rule, path, line, and commit where available. Every successful scan also uploads a 30-day `tn-secret-scan-<run-id>` artifact containing the Markdown summary and the complete sanitized JSON inventory. Raw Gitleaks and TruffleHog reports are never uploaded. Confirmed secrets require rotation, revocation, migration, or abandonment; deleting a file or rewriting history is not sufficient remediation by itself.

### Minimal Caller

```yaml
name: TN Secret Scan

on:
  pull_request:
  push:
    branches:
      - main
  workflow_dispatch:
    inputs:
      scan_mode:
        description: "Use history for manual inventory scans."
        required: true
        default: history
        type: choice
        options:
          - history
          - pr
          - push

jobs:
  secret_scan:
    uses: treasurenetprotocol/reusable-workflows/.github/workflows/reusable-secrets-scanning.yml@main
    with:
      scan_mode: ${{ github.event_name == 'workflow_dispatch' && inputs.scan_mode || github.event_name == 'pull_request' && 'pr' || 'push' }}
      fetch_depth: 0
      fail_threshold: high
      config_ref: main
    secrets:
      SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
      SLACK_CHANNEL_ID_GITHUB_NOTIFICATION: ${{ secrets.SLACK_CHANNEL_ID_GITHUB_NOTIFICATION }}
```

Slack secrets are optional. When both `SLACK_BOT_TOKEN` and `SLACK_CHANNEL_ID_GITHUB_NOTIFICATION` are present, failures send a sanitized notification with counts and a link to the GitHub Actions run.

### Inputs

| Input | Default | Description |
| --- | --- | --- |
| `scan_mode` | `pr` | `pr`, `push`, or `history`. |
| `fetch_depth` | `0` | Checkout depth. Use `0` for complete history and accurate range scans. |
| `fail_threshold` | `high` | Lowest severity that blocks PR/push scans: `critical`, `high`, `medium`, or `low`. |
| `config_ref` | `main` | Ref in `treasurenetprotocol/reusable-workflows` used to fetch the shared Gitleaks config. Pin this to a reviewed tag or commit for stricter rollout control. |
| `config_path` | `security/gitleaks/tn-gitleaks.toml` | Gitleaks config path inside this repository. |
| `gitleaks_version` | `v8.27.2` | Gitleaks container version. |
| `trufflehog_version` | `3.90.5` | TruffleHog container version. |
| `branch` | empty | Optional legacy ref override. Prefer the event ref. |
| `depth` | `2` | Deprecated legacy input retained so old callers do not break validation. |
