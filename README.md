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

For a newly created branch where GitHub does not provide a usable `before` SHA, push mode derives the incremental range from the merge-base with the repository's default branch. If no merge-base exists, it scans only `HEAD`. PR and push modes skip unrelated refs; only history mode intentionally scans the complete fetched history.

The workflow intentionally does not print raw secret values in logs, step summaries, artifacts, or Slack notifications. Summaries include scanner engine, severity, rule, path, line, and commit where available. Every successful scan also uploads a 30-day `tn-secret-scan-<run-id>` artifact containing the Markdown summary and the complete sanitized JSON inventory. Raw Gitleaks and TruffleHog reports are never uploaded. Confirmed secrets require rotation, revocation, migration, or abandonment; deleting a file or rewriting history is not sufficient remediation by itself.

### Organization Incremental Caller

INF-163 installs this caller in every active TN repository. It scans every pull
request and every pushed commit, while leaving full-history inventory to
INF-164. The immutable workflow and configuration ref keep the organization
rollout reproducible.

```yaml
name: TN Incremental Secret Scan

on:
  pull_request:
  push:

permissions:
  contents: read

jobs:
  secret-scan:
    uses: treasurenetprotocol/reusable-workflows/.github/workflows/reusable-secrets-scanning.yml@d82d3ef57336183b47a09c40717ea0560e4e50f6
    with:
      scan_mode: ${{ github.event_name == 'pull_request' && 'pr' || 'push' }}
      fetch_depth: 0
      fail_threshold: high
      config_ref: d82d3ef57336183b47a09c40717ea0560e4e50f6
```

PR and push modes require their native GitHub event payloads so the reusable workflow can derive an accurate incremental commit range. Do not add a history dispatch to the organization incremental caller; use the separately controlled INF-164 process for historical inventory.

GitHub native secret scanning push protection is the receive-time control for provider-supported secret types. The Actions `push` event runs after GitHub accepts a commit and adds the broader TN-specific detection layer. The default-branch ruleset requires `secret-scan / SecurityScan`, so high and critical new findings cannot be merged through a pull request.

Slack secrets are optional. When both `SLACK_BOT_TOKEN` and `SLACK_CHANNEL_ID_GITHUB_NOTIFICATION` are present, failures send a sanitized notification with counts and a link to the GitHub Actions run.

When the check fails, do not paste a secret into a PR, issue, chat, or allowlist request. Review the sanitized path/rule metadata, revoke or rotate a real credential, remove it from the proposed change, and rerun the check. Deleting or reverting an already committed real secret is not sufficient remediation. For a suspected false positive, request security review with the sanitized rule, path, and line only; allowlist changes must be narrow and justified.

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
