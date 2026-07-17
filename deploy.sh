#!/usr/bin/env bash
# Deploy ROHI landing page to Cloudflare Pages
set -euo pipefail
cd "$(dirname "$0")"

PROJECT_NAME="rohi"

echo "→ Deploying to Cloudflare Pages ($PROJECT_NAME)..."
npx wrangler pages deploy . --project-name="$PROJECT_NAME" --commit-dirty=true

echo ""
echo "✓ Live:"
echo "  https://rohi-9gm.pages.dev"
echo "  https://rohi.co.ke   (after nameservers are active)"
echo "  https://www.rohi.co.ke"
