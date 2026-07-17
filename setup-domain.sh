#!/usr/bin/env bash
# One-time: add rohi.co.ke to Cloudflare and print nameservers.
# Requires an API token with Zone:Edit (Account → Create Token → Edit zone DNS template + Zone:Add)
#   export CLOUDFLARE_API_TOKEN=your_token_here
set -euo pipefail

DOMAIN="rohi.co.ke"
ACCOUNT_ID="8440547cc22b398e6c60f36b104b1b47"
PAGES_HOST="rohi-9gm.pages.dev"

if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  echo "Missing CLOUDFLARE_API_TOKEN"
  echo ""
  echo "Create one at: https://dash.cloudflare.com/profile/api-tokens"
  echo "  Use template: Edit zone DNS"
  echo "  Also enable: Zone → Zone → Edit (so zone can be created)"
  echo ""
  echo "Then run:"
  echo "  export CLOUDFLARE_API_TOKEN=..."
  echo "  ./setup-domain.sh"
  exit 1
fi

AUTH=(-H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" -H "Content-Type: application/json")

echo "→ Creating / fetching zone $DOMAIN ..."
EXISTING=$(curl -s "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" "${AUTH[@]}")
ZONE_ID=$(echo "$EXISTING" | python3 -c "import sys,json; r=json.load(sys.stdin).get('result') or []; print(r[0]['id'] if r else '')")

if [[ -z "$ZONE_ID" ]]; then
  CREATE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones" \
    "${AUTH[@]}" \
    --data "{\"name\":\"$DOMAIN\",\"account\":{\"id\":\"$ACCOUNT_ID\"},\"jump_start\":false}")
  echo "$CREATE" | python3 -m json.tool
  ZONE_ID=$(echo "$CREATE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('result',{}).get('id',''))")
  if [[ -z "$ZONE_ID" ]]; then
    echo "✗ Could not create zone. Check token permissions (Zone:Edit)."
    exit 1
  fi
fi

ZONE=$(curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID" "${AUTH[@]}")
echo "$ZONE" | python3 -c "
import sys,json
z=json.load(sys.stdin)['result']
print('')
print('Domain:', z['name'])
print('Status:', z['status'])
print('')
print('=== Put these on Cloudoon → Nameservers ===')
for ns in z.get('name_servers', []):
    print(ns)
print('')
"

echo "→ Ensuring DNS records point to Pages ($PAGES_HOST) ..."
# CNAME www → pages
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
  "${AUTH[@]}" \
  --data "{\"type\":\"CNAME\",\"name\":\"www\",\"content\":\"$PAGES_HOST\",\"proxied\":true,\"ttl\":1}" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('www:', 'ok' if d.get('success') else d.get('errors'))"

# CNAME apex → pages (Cloudflare supports CNAME flattening)
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
  "${AUTH[@]}" \
  --data "{\"type\":\"CNAME\",\"name\":\"@\",\"content\":\"$PAGES_HOST\",\"proxied\":true,\"ttl\":1}" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('apex:', 'ok' if d.get('success') else d.get('errors'))"

echo ""
echo "✓ After nameservers update at Cloudoon, wait for Active, then:"
echo "  https://rohi.co.ke"
echo "  https://www.rohi.co.ke"
