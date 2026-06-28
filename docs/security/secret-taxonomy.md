# TreasureNet Secret Taxonomy And Remediation Rules

## Purpose

This document defines the shared TreasureNet baseline for source-code secret detection. It is intended for GitHub Actions scanning, code review, incident triage, and repository cleanup work across TN repositories.

## Non-Negotiable Remediation Principle

Any private key, mnemonic, deployer credential, cloud credential, or production token committed to GitHub history must be treated as compromised.

Deleting the file, reverting the commit, force-pushing, or rewriting Git history may reduce casual exposure, but it is not sufficient remediation. A real secret finding can only be closed after one of these outcomes is documented:

- `rotated/revoked`
- `abandoned`
- `migrated`
- `false positive`
- `accepted residual exposure`

`removed from repo` is not a valid final status for a real secret.

## Severity Model

| Severity | Meaning | Default CI Behavior |
| --- | --- | --- |
| Critical | Direct signing keys, mnemonics, private keys, production deployer credentials, production cloud credentials, or credentials that can control funds, infrastructure, releases, or production data. | Block PR/push immediately. |
| High | Service tokens, database URLs with credentials, CI/CD tokens, package registry tokens, OAuth client secrets, webhook secrets, or credentials that can access non-public systems. | Block PR/push once the rule is stable. |
| Medium | Suspicious high-entropy strings, non-production credentials, internal shared secrets, or context-dependent tokens requiring owner review. | Warn or block after tuning. |
| Low | Weak signals, examples, fake fixtures, public identifiers, or values that require additional context. | Do not block by default. |

## Secret Categories

### Blockchain And Wallet Secrets

Default severity: Critical.

- EVM private keys, including `0x` and non-`0x` 32-byte hex keys.
- Cosmos/TN private keys.
- BIP39 mnemonic phrases.
- Wallet keystore JSON containing encrypted private key material.
- Hardhat, Foundry, Truffle, ethers.js, web3.js, or deployment script private keys.
- Deployer, signer, oracle, bridge, feeder, relayer, faucet, treasury, or admin keys.
- Any key able to move funds, deploy contracts, upgrade contracts, sign oracle data, mint, burn, bridge, or administer protocol contracts.

Required remediation:

- Abandon or rotate the key.
- Move funds, ownership, roles, and signer permissions away from the exposed key.
- Document residual on-chain authority if any cannot be moved.

### Cloud And Infrastructure Secrets

Default severity: Critical for production or privileged credentials; High otherwise.

- AWS access keys and secret keys.
- AWS session tokens.
- GCP service account JSON and private keys.
- Azure client secrets, tenant credentials, and publish profiles.
- Terraform Cloud tokens and backend credentials.
- Kubernetes kubeconfig files and service-account tokens.
- Docker, ECR, GHCR, GCR, ACR, and other registry credentials.
- Cloudflare, DNS provider, CDN, load-balancer, and certificate automation tokens.
- VPN, bastion, SSH jump host, WireGuard, OpenVPN, or Tailscale credentials.

Required remediation:

- Revoke or rotate the credential at the provider.
- Review audit logs for usage after exposure.
- Replace affected CI/CD or runtime secret references.

### GitHub, CI/CD, And Release Credentials

Default severity: Critical or High.

- GitHub personal access tokens.
- GitHub App private keys.
- GitHub Actions, CircleCI, GitLab, Jenkins, Buildkite, Drone, or ArgoCD tokens.
- Deployment tokens, environment promotion credentials, release signing keys, and artifact publishing keys.
- npm, Yarn, pnpm, PyPI, Maven, Gradle, RubyGems, NuGet, Go proxy, Cargo, Docker registry, and package publishing tokens.
- SSH deploy keys and machine-user private keys.

Required remediation:

- Revoke or rotate the token/key.
- Review repository, package, and release audit logs.
- Check whether malicious packages, releases, workflows, or tags were created.

### SaaS, Monitoring, And Communication Tokens

Default severity: High.

- Slack bot tokens, app tokens, webhook URLs, and signing secrets.
- Discord, Telegram, DingTalk, Feishu/Lark, Teams, and webhook tokens.
- SendGrid, Mailgun, SES SMTP, Postmark, Twilio, and SMS/email provider secrets.
- Sentry auth tokens, Datadog, Grafana, Prometheus remote-write, New Relic, PagerDuty, Opsgenie, Honeycomb, Logtail, Loki, and observability API keys.
- Notion, Linear, Jira, Confluence, Google Workspace, Google Drive, and document automation tokens.
- Stripe, Plaid, Coinbase, Alchemy, Infura, QuickNode, WalletConnect, Moralis, The Graph, Etherscan, and blockchain infrastructure provider keys.

Required remediation:

- Rotate the token in the SaaS provider.
- Review audit logs and webhook delivery history when available.
- Remove the value from source and move it into the approved secret manager.

### Database, Cache, Messaging, And Search Credentials

Default severity: High.

- PostgreSQL, MySQL, MariaDB, MongoDB, Redis, Memcached, ClickHouse, Snowflake, BigQuery, DynamoDB, Elasticsearch, OpenSearch, Solr, Cassandra, and Neo4j credentials.
- RabbitMQ, Kafka, NATS, MQTT, SQS, SNS, and queue/broker credentials.
- DSNs or URLs containing usernames and passwords.
- Root/admin database credentials in any format.

Required remediation:

- Rotate the password or credential.
- Review database access logs where available.
- Confirm application/runtime configuration has moved to secret-managed values.

### Web, Authentication, And Application Secrets

Default severity: High.

- JWT signing secrets and private signing keys.
- Session, cookie, CSRF, password-reset, invite, API signing, HMAC, encryption, and webhook verification secrets.
- OAuth/OIDC/SAML client secrets.
- Basic-auth URLs containing credentials.
- Admin bootstrap passwords.
- Encryption keys for application data, backups, cookies, and local storage.
- CAPTCHA, Turnstile, reCAPTCHA, and anti-abuse secret keys.

Required remediation:

- Rotate signing/encryption material when feasible.
- Invalidate affected sessions or tokens when the secret can sign or decrypt them.
- Update all dependent services and clients.

### Cryptographic Private Material

Default severity: Critical.

- SSH private keys.
- TLS private keys.
- PGP/GPG private keys.
- PEM, PKCS#1, PKCS#8, OpenSSH, and PuTTY private key blocks.
- Code-signing, mobile signing, notarization, and certificate authority keys.
- Java keystore, Android keystore, iOS provisioning, App Store Connect, and Google Play signing secrets.

Required remediation:

- Revoke, rotate, or replace the key/certificate.
- Reissue certificates and update trust chains where needed.
- Review signing history and release artifacts.

### Mobile And Client Distribution Secrets

Default severity: High or Critical depending on capability.

- Android keystores and keystore passwords.
- iOS certificates, provisioning profiles, App Store Connect API keys, and fastlane match credentials.
- Firebase service account keys and privileged server keys.
- Push notification keys such as APNs auth keys and FCM server keys.
- Mobile analytics or attribution admin tokens.

Required remediation:

- Rotate or revoke through the platform owner.
- Confirm release pipelines and store credentials are updated.

### Machine Learning, Data, And Third-Party Provider Keys

Default severity: High.

- OpenAI, Anthropic, Gemini, Cohere, Hugging Face, Replicate, Pinecone, Weaviate, Qdrant, vector database, and model provider keys.
- Data warehouse, ETL, analytics, and BI provider tokens.
- Internal vendor API keys with non-public data access.

Required remediation:

- Rotate the key.
- Review usage and billing spikes.
- Add rate limits or provider-side restrictions where available.

### Generic High-Entropy Strings

Default severity: Medium.

High entropy alone is not enough to classify a finding as a real secret. It should be combined with path, variable name, assignment context, or provider pattern. Generic entropy rules must avoid blocking:

- Hashes.
- Checksums.
- Transaction hashes.
- Block hashes.
- Public addresses.
- Public keys.
- Lockfiles.
- Minified assets.
- Test snapshots.

## Values That Are Not Secrets By Default

- Public blockchain addresses.
- Transaction hashes.
- Block hashes.
- Public keys.
- Public certificates without private key blocks.
- `.env.example` placeholders.
- Fake credentials in explicitly marked fixtures.
- Non-sensitive DSNs that vendors intentionally expose publicly, unless paired with an auth token.

## Allowlist Rules

Allowlist entries must be narrow and justified. Prefer path-scoped or test-fixture-scoped allowlists over value-wide allowlists.

Allowed examples:

- `docs/example/**`
- `**/.env.example`
- `security/gitleaks/fixtures/**`
- Clearly fake values containing `fake`, `dummy`, `example`, `placeholder`, or `not-a-real-secret`

Disallowed examples:

- Allowlisting all private-key-looking values.
- Allowlisting production config paths.
- Closing a finding because the secret was deleted from the latest branch.

## Required Triage Fields

Every real secret finding should record:

- Repository.
- File path.
- Commit or PR.
- Secret category.
- Severity.
- Scanner source.
- Whether the secret is verified.
- Suspected owner.
- Runtime or environment impact.
- Remediation status.
- Remediation evidence.
- Residual exposure decision, if any.

## CI Blocking Policy

PR and protected-branch scans should block:

- Critical findings.
- High findings from provider-specific rules.
- Any verified TruffleHog credential.

Initial rollout may warn on medium generic entropy findings until false positives are tuned.
