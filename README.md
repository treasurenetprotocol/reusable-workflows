# Reusable GitHub Actions Workflow

## Utility
| Reusable Workflow | Description | Usage |
| --------------- | --------------- | --------------- |
| `reusable-timestamp.yml` | print out workflow start time | [README](docs/utility/readme-reusable-lint-go-workflow.md) |

## Security Baselines
| Asset | Description | Usage |
| --------------- | --------------- | --------------- |
| `docs/security/secret-taxonomy.md` | TN-wide secret taxonomy, severity model, and remediation rules | Read before tuning secret-scanning workflows |
| `security/gitleaks/tn-gitleaks.toml` | Shared Gitleaks rules for TN-specific and general software-engineering secrets | Use from reusable secret-scanning workflows |
