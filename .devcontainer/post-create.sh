#!/usr/bin/env bash
# =============================================================================
# post-create.sh — finish provisioning the SRE Agent labs dev container.
# Installs tools that ship best via apt / pip / npm / dotnet (the rest come
# from devcontainer "features"). Runs once, after the container is built.
# =============================================================================
set -euo pipefail

echo "==> Provisioning SRE Agent labs dev container..."

# --- jq: used by prereqs.sh and several lab/recipe scripts ---
if ! command -v jq >/dev/null 2>&1; then
  echo "  Installing jq..."
  sudo apt-get update -y
  sudo apt-get install -y --no-install-recommends jq
fi

# --- PyYAML: post-provision scripts read/generate agent config YAML ---
echo "  Installing PyYAML..."
python3 -m pip install --user --upgrade pyyaml \
  || python3 -m pip install --user --break-system-packages --upgrade pyyaml \
  || echo "PyYAML install failed — run: pip install pyyaml"

# --- Bicep: ensured through the Azure CLI (labs deploy main.bicep) ---
echo "  Ensuring Bicep is installed..."
az bicep install >/dev/null 2>&1 || echo " 'az bicep install' skipped (retry after az login)"

# --- azmcp: public Azure MCP SRE tools used by zava-learning agent config ---
echo "  Installing Azure MCP CLI (azmcp)..."
npm install -g @azure/mcp@latest \
  || echo "  azmcp install skipped — install later with: npm i -g @azure/mcp@latest"

echo ""
echo "==> Done. Installed toolchain:"
for tool in az azd git python3 node npm jq gh terraform pwsh dotnet kubectl helm docker; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf "    %-10s %s\n" "$tool" "$("$tool" --version 2>&1 | head -1)"
  else
    printf "    %-10s not found\n" "$tool"
  fi
done

echo ""
echo "Next: 'az login' then 'azd auth login', then open a lab in labs/ and run 'azd up'."
