# TN Gitleaks Configuration

This directory contains TreasureNet's shared Gitleaks baseline.

- `tn-gitleaks.toml`: shared rules and allowlists.
- `fixtures/negative.txt`: fake public identifiers and placeholders that should not block.
- `test-fixtures/generate-positive-fixture.sh`: creates a temporary fake-only positive fixture outside the committed source tree.

The fixture files intentionally contain fake values only. Do not add real credentials to this repository for testing.

## Validation

If `gitleaks` is installed locally:

```bash
tmpdir="$(mktemp -d)"
security/gitleaks/test-fixtures/generate-positive-fixture.sh "$tmpdir/positive.txt"
gitleaks detect --no-git --source "$tmpdir" --config security/gitleaks/tn-gitleaks.toml --verbose
gitleaks detect --no-git --source security/gitleaks/fixtures --config security/gitleaks/tn-gitleaks.toml --verbose
```

Expected behavior:

- The generated temporary positive fixture should produce findings.
- `fixtures/negative.txt` should not produce blocking findings.

If `gitleaks` is not installed, validate TOML syntax and run lightweight regex checks against a generated positive fixture and the committed negative fixture.
