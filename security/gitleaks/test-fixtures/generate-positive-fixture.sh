#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <output-file>" >&2
  exit 64
fi

repeat_char() {
  local char="$1"
  local count="$2"
  local value=""
  local i
  for ((i = 0; i < count; i += 1)); do
    value="${value}${char}"
  done
  printf '%s' "$value"
}

output_file="$1"
mkdir -p "$(dirname "$output_file")"
hex_a_64="$(repeat_char a 64)"
hex_b_64="$(repeat_char b 64)"
alpha_a_24="$(repeat_char a 24)"
alpha_a_32="$(repeat_char a 32)"
alpha_a_35="$(repeat_char A 35)"
alpha_a_36="$(repeat_char a 36)"
alpha_a_40="$(repeat_char a 40)"
alpha_a_60="$(repeat_char a 60)"
alpha_b_36="$(repeat_char b 36)"
alpha_c_36="$(repeat_char c 36)"
mnemonic="$(printf 'abandon %.0s' {1..11})about"
aws_id="AKIAIOSF""ODNN7EXAMPLE"
aws_secret="wJalrXUtnFEMI/K7MD""ENG/bPxRfiCYEXAMPLEKEY"
slack_prefix="xox""b-"
pem_begin="-----BEGIN ""PRIVATE KEY""-----"
pem_end="-----END ""PRIVATE KEY""-----"
pg_url="postgres""://admin:super-secret-password@example.internal:5432/app"
redis_url="redis""://default:super-secret-password@example.internal:6379/0"

{
  printf '%s\n' '# Fake-only positive examples for TN secret scanning rules.'
  printf '%s\n' '# These values are intentionally non-production and must never be reused.'
  printf '\n'
  printf 'PRIVATE_KEY=0x%s\n' "$hex_a_64"
  printf 'DEPLOYER_KEY=%s\n' "$hex_b_64"
  printf 'MNEMONIC="%s"\n' "$mnemonic"
  printf 'AWS_ACCESS_KEY_ID=%s\n' "$aws_id"
  printf 'AWS_SECRET_ACCESS_KEY=%s\n' "$aws_secret"
  printf 'GITHUB_TOKEN=ghp_%s\n' "$alpha_a_36"
  printf 'npm_token=npm_%s\n' "$alpha_a_36"
  printf 'SLACK_BOT_TOKEN=%s111111111111-222222222222-%s\n' "$slack_prefix" "$alpha_a_24"
  printf 'SLACK_WEBHOOK=https://hooks.slack.com/services/T00000000/B00000000/%s\n' "$alpha_a_24"
  printf 'DISCORD_WEBHOOK=https://discord.com/api/webhooks/111111111111111111/%s\n' "$alpha_a_60"
  printf 'TELEGRAM_BOT_TOKEN=123456789:%s\n' "$alpha_a_35"
  printf 'SENDGRID_API_KEY=SG.%s.%s\n' "$alpha_a_24" "$alpha_a_32"
  printf 'DATABASE_URL=%s\n' "$pg_url"
  printf 'REDIS_URL=%s\n' "$redis_url"
  printf 'JWT_SECRET="%s"\n' "$alpha_a_40"
  printf 'SESSION_SECRET="%s"\n' "$alpha_b_36"
  printf 'OAUTH_CLIENT_SECRET="%s"\n' "$alpha_c_36"
  printf 'SENTRY_AUTH_TOKEN="sentry_auth_token_%s"\n' "$alpha_a_24"
  printf 'GRAFANA_API_KEY="grafana_token_%s"\n' "$alpha_a_24"
  printf 'OPENAI_API_KEY="openai_api_key_%s"\n' "$alpha_a_24"
  printf 'FIREBASE_SERVER_KEY="firebase_server_key_%s"\n' "$alpha_a_24"
  printf 'ANDROID_KEYSTORE_PASSWORD="android_keystore_password_%s"\n' "$alpha_a_24"
  printf '%s\n' "$pem_begin"
  printf '%s\n' 'placeholder-material-generated-for-test-only'
  printf '%s\n' "$pem_end"
} > "$output_file"
