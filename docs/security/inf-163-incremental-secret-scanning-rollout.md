# INF-163 Incremental Secret Scanning Rollout

## Summary

INF-163 rolls the TN reusable secret-scanning workflow out to every active,
non-empty, non-fork repository in the `treasurenetprotocol` GitHub
organization.

The rollout protects new work only:

- every pull request is scanned;
- every pushed commit, on every branch, is scanned;
- high and critical new findings fail the incremental check;
- GitHub native secret scanning and push protection are enabled for supported
  provider secret patterns; and
- full-history inventory and remediation remain in INF-164.

Deleting or reverting a real secret after it has been committed is not
sufficient remediation. The credential must be rotated, revoked, migrated, or
abandoned.

## References

- Linear: [INF-163](https://linear.app/treasurenet/issue/INF-163/roll-out-incremental-secret-scanning-to-priority-tn-repositories)
- Reusable workflow implementation: [reusable-workflows PR #63](https://github.com/treasurenetprotocol/reusable-workflows/pull/63)
- Rollout and organization guidance: [reusable-workflows PR #64](https://github.com/treasurenetprotocol/reusable-workflows/pull/64)
- Shared secret taxonomy: [secret-taxonomy.md](secret-taxonomy.md)

## Scope

Inventory captured on 2026-07-14:

| Category | Count | Treatment |
| --- | ---: | --- |
| Active, non-empty, non-fork repositories | 47 | Included |
| Archived repositories | 18 | Excluded; not re-enabled |
| Active forks | 0 | None |

All included repositories used `main` as their default branch at rollout time.

## Protection Layers

### 1. GitHub native push protection

GitHub native secret scanning and push protection are enabled and independently
verified on all 47 included repositories. This is the receive-time control for
secret patterns supported by GitHub.

### 2. TN incremental GitHub Action

Each included repository has a rollout PR adding the standard caller below.
The caller uses only read access, scans both pull requests and pushes, and pins
the reusable workflow and shared configuration to the immutable INF-162 merge
commit.

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

The Actions `push` event runs after GitHub accepts a commit. It adds broader
TN-specific detection, including rules not covered by GitHub's provider
patterns, but it is not a substitute for receive-time push protection.

### 3. Default-branch required check

Every included repository has a dedicated ruleset named
`INF-163 incremental secret scan`, configured to require:

```text
secret-scan / SecurityScan
```

The rulesets are pre-created but intentionally disabled until the caller PR is
merged into the corresponding default branch. At staging time, the organization
had 453 existing non-INF-163 pull requests. Activating the required check before
the caller exists on the default branch could block those pull requests because
they cannot emit the new check.

Existing repository rulesets were preserved.

## Validation Evidence

The rollout was validated without retrieving or exposing raw secret values.

| Validation | Result |
| --- | --- |
| Caller files present and identical across rollout repositories | 47/47 |
| Rollout PRs created | 47/47 |
| Rollout PRs Ready for review | 47/47 |
| `secret-scan / SecurityScan` success | 47 |
| Pending checks | 0 |
| Failed checks | 0 |
| Missing checks | 0 |
| Native secret scanning enabled | 47/47 |
| Native push protection enabled | 47/47 |
| Required-check rulesets staged with configuration intact | 47/47 |

Representative pilot repositories were `repo-template`, `technical-demo`, and
`smart-contracts`. Each pilot exercised both the branch-push and pull-request
paths.

## Pull Request Manifest

All 47 rollout PRs were open and Ready for review when this document was
generated.

| Repository | Pull request |
| --- | --- |
| `reusable-workflows` | [#64](https://github.com/treasurenetprotocol/reusable-workflows/pull/64) |
| `technical-demo` | [#8](https://github.com/treasurenetprotocol/technical-demo/pull/8) |
| `treasurenet-tnservices-airdrop-fe` | [#47](https://github.com/treasurenetprotocol/treasurenet-tnservices-airdrop-fe/pull/47) |
| `AI-QA-Orchestrator` | [#17](https://github.com/treasurenetprotocol/AI-QA-Orchestrator/pull/17) |
| `treasurenet` | [#105](https://github.com/treasurenetprotocol/treasurenet/pull/105) |
| `treasurenet-tnservices-datacenter` | [#41](https://github.com/treasurenetprotocol/treasurenet-tnservices-datacenter/pull/41) |
| `coding-style` | [#13](https://github.com/treasurenetprotocol/coding-style/pull/13) |
| `treasurenet-bigdipper` | [#22](https://github.com/treasurenetprotocol/treasurenet-bigdipper/pull/22) |
| `treasurenet-centralized-crosschain` | [#15](https://github.com/treasurenetprotocol/treasurenet-centralized-crosschain/pull/15) |
| `treasurenet-cosmos-pack` | [#234](https://github.com/treasurenetprotocol/treasurenet-cosmos-pack/pull/234) |
| `logging-middleware` | [#19](https://github.com/treasurenetprotocol/logging-middleware/pull/19) |
| `treasurenet-tnservices-producerPlatform-fe` | [#66](https://github.com/treasurenetprotocol/treasurenet-tnservices-producerPlatform-fe/pull/66) |
| `treasurenet-tnservices-faucet-fe` | [#29](https://github.com/treasurenetprotocol/treasurenet-tnservices-faucet-fe/pull/29) |
| `treasurenet-tnservices-datacenter-fe` | [#39](https://github.com/treasurenetprotocol/treasurenet-tnservices-datacenter-fe/pull/39) |
| `treasurenet-tnservices-tokenlocker` | [#19](https://github.com/treasurenetprotocol/treasurenet-tnservices-tokenlocker/pull/19) |
| `treasurenet-tnservices-datauploader` | [#52](https://github.com/treasurenetprotocol/treasurenet-tnservices-datauploader/pull/52) |
| `treasurenet-tnservices-dataprocess` | [#55](https://github.com/treasurenetprotocol/treasurenet-tnservices-dataprocess/pull/55) |
| `treasurenet-js-libs` | [#36](https://github.com/treasurenetprotocol/treasurenet-js-libs/pull/36) |
| `treasurenet-tnservices-dataprovider` | [#79](https://github.com/treasurenetprotocol/treasurenet-tnservices-dataprovider/pull/79) |
| `treasurenet-tnservices-www` | [#38](https://github.com/treasurenetprotocol/treasurenet-tnservices-www/pull/38) |
| `treasurenet-tnservices-platform` | [#43](https://github.com/treasurenetprotocol/treasurenet-tnservices-platform/pull/43) |
| `treasurenet-tnservices-airdrop-manager-fe` | [#54](https://github.com/treasurenetprotocol/treasurenet-tnservices-airdrop-manager-fe/pull/54) |
| `treasurenet-tnservices-feeder` | [#74](https://github.com/treasurenetprotocol/treasurenet-tnservices-feeder/pull/74) |
| `treasurenet-tnservices-fmtool` | [#17](https://github.com/treasurenetprotocol/treasurenet-tnservices-fmtool/pull/17) |
| `treasurenet-tnservices-faucet` | [#33](https://github.com/treasurenetprotocol/treasurenet-tnservices-faucet/pull/33) |
| `treasurenet-tnservices-tngateway` | [#66](https://github.com/treasurenetprotocol/treasurenet-tnservices-tngateway/pull/66) |
| `treasurenet-tnservices-mqservice` | [#34](https://github.com/treasurenetprotocol/treasurenet-tnservices-mqservice/pull/34) |
| `treasurenet-bdjuno` | [#61](https://github.com/treasurenetprotocol/treasurenet-bdjuno/pull/61) |
| `treasurenet-ibc-go-pack` | [#86](https://github.com/treasurenetprotocol/treasurenet-ibc-go-pack/pull/86) |
| `treasurenet-gha-cicd` | [#11](https://github.com/treasurenetprotocol/treasurenet-gha-cicd/pull/11) |
| `smart-contracts` | [#84](https://github.com/treasurenetprotocol/smart-contracts/pull/84) |
| `skills` | [#16](https://github.com/treasurenetprotocol/skills/pull/16) |
| `treasurenet-tnservices-servicesplatform-fe` | [#128](https://github.com/treasurenetprotocol/treasurenet-tnservices-servicesplatform-fe/pull/128) |
| `iac-mainnet` | [#114](https://github.com/treasurenetprotocol/iac-mainnet/pull/114) |
| `docs` | [#58](https://github.com/treasurenetprotocol/docs/pull/58) |
| `treasurenet-terraform` | [#13](https://github.com/treasurenetprotocol/treasurenet-terraform/pull/13) |
| `treasurenet-crosschain` | [#4](https://github.com/treasurenetprotocol/treasurenet-crosschain/pull/4) |
| `blockscout-mainnet` | [#4](https://github.com/treasurenetprotocol/blockscout-mainnet/pull/4) |
| `internal-tools` | [#30](https://github.com/treasurenetprotocol/internal-tools/pull/30) |
| `treasurenet-ssh-keys` | [#5](https://github.com/treasurenetprotocol/treasurenet-ssh-keys/pull/5) |
| `monitoring-hub` | [#11](https://github.com/treasurenetprotocol/monitoring-hub/pull/11) |
| `tngateway-client` | [#2](https://github.com/treasurenetprotocol/tngateway-client/pull/2) |
| `blockscout-testnet` | [#1](https://github.com/treasurenetprotocol/blockscout-testnet/pull/1) |
| `chest` | [#4](https://github.com/treasurenetprotocol/chest/pull/4) |
| `AutoTestArk` | [#1](https://github.com/treasurenetprotocol/AutoTestArk/pull/1) |
| `repo-template` | [#2](https://github.com/treasurenetprotocol/repo-template/pull/2) |
| `treasurenetprotocol.github.io` | [#12](https://github.com/treasurenetprotocol/treasurenetprotocol.github.io/pull/12) |

## Archived Repository Exceptions

The following 18 repositories were archived at inventory time. INF-163 did not
re-enable or modify them:

- `treasurenet-bech32-pack`
- `automatictester`
- `treasurenet-bech32`
- `treasurenet-digitalassets-dataprovider-btc`
- `blockscout`
- `smart-contracts-early-release`
- `treasurenet-digitalAssets-platform-fe`
- `treasurenet-digitalassets-dataprovider`
- `treasurenet-digitalassets-dataprovider-eth`
- `treasurenet-digitalassets-platform`
- `callisto`
- `iac-devnet`
- `node-launcher`
- `iac`
- `treasurenet-address-converter`
- `treasurenet-blockscout`
- `treasurenet-chains`
- `treasurenet-blockscout-fe`

## Merge And Activation Procedure

1. Review and merge each repository's rollout PR.
2. Confirm `.github/workflows/tn-incremental-secret-scan.yml` is present on
   `main`. The reusable-workflows repository uses
   `.github/workflows/secrets-scanning.yml` instead.
3. Confirm a clean default-branch push produces
   `secret-scan / SecurityScan`.
4. Change that repository's `INF-163 incremental secret scan` ruleset from
   `disabled` to `active`.
5. Open or refresh a pull request and confirm the secret scan is required.
6. After all repositories are complete, audit all 47 callers, native security
   settings, and rulesets before moving INF-163 to Done.

The rollout PRs reference the already merged INF-162 commit, so they do not
depend on PR #64 being merged first.

## Engineer Response Guide

When the incremental check fails:

1. Do not paste the suspected value into a PR, issue, chat, or allowlist
   request.
2. Review only the sanitized scanner, rule, path, line, severity, and commit
   metadata.
3. If the value is real, revoke, rotate, migrate, or abandon it immediately.
4. Remove the value from the proposed change and move it to the approved secret
   manager.
5. Review relevant access and audit logs when the credential may have been
   exposed.
6. Rerun the check after remediation.

For a suspected false positive, request security review using sanitized
metadata only. Allowlist changes must be narrow, justified, and preferably
scoped to a test fixture or path. A value-wide allowlist is a last resort.

## INF-163 Versus INF-164

INF-163 does not claim that repository history is clean. It prevents and
detects new secret introduction through PR and push ranges.

INF-164 owns organization-wide historical scanning, finding triage, credential
rotation, incident review, and any history-rewrite decisions. Historical
findings must not be silently converted into blocking incremental checks before
owners have triaged and remediated them.
