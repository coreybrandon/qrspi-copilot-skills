#!/bin/bash
# QRSPI shared utilities — sourced by skill instructions via the bash tool
# Usage: source ~/.copilot/scripts/qrspi-utils.sh
#
# Targets macOS: uses the BSD `stat`/`date` shipped with macOS. If Homebrew's
# GNU coreutils are earlier in PATH, `/usr/bin/stat` is used explicitly below
# so BSD flag syntax (`-f`) keeps working regardless of PATH ordering.

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required but not installed. Install it with: brew install jq" >&2
  return 1 2>/dev/null || exit 1
fi

# Derive repo name from git remote origin or current directory basename
qrspi_repo_name() {
  local url
  url=$(git remote get-url origin 2>/dev/null || true)
  if [[ -n "$url" ]]; then
    basename "${url%.git}"
  else
    basename "$(pwd)"
  fi
}

# Return path to a specific feature's spec directory
# Usage: qrspi_spec_dir [feature-name]
#   If feature-name omitted, reads from manifest in current spec context
qrspi_spec_dir() {
  local repo feature
  repo=$(qrspi_repo_name)
  if [[ -n "${1:-}" ]]; then
    feature="$1"
  else
    feature=$(qrspi_feature_name)
  fi
  echo ".copilot-qrspi/${repo}/specs/${feature}"
}

# Read current feature name from manifest.json in the spec directory
# Requires QRSPI_SPEC_DIR to be set or a feature name argument
qrspi_feature_name() {
  if [[ -n "${QRSPI_SPEC_DIR:-}" ]]; then
    jq -r '.feature' "${QRSPI_SPEC_DIR}/manifest.json"
  else
    echo "ERROR: QRSPI_SPEC_DIR not set and no feature name provided" >&2
    return 1
  fi
}

# Read manifest.json and return phase statuses as JSON
# Usage: qrspi_read_manifest <spec-dir>
qrspi_read_manifest() {
  local spec_dir="${1:?Usage: qrspi_read_manifest <spec-dir>}"
  if [[ ! -f "${spec_dir}/manifest.json" ]]; then
    echo "ERROR: No manifest.json found at ${spec_dir}" >&2
    return 1
  fi
  cat "${spec_dir}/manifest.json"
}

# Update a phase's status in manifest.json
# Usage: qrspi_update_manifest <spec-dir> <phase> <status>
qrspi_update_manifest() {
  local spec_dir="${1:?Usage: qrspi_update_manifest <spec-dir> <phase> <status>}"
  local phase="${2:?}"
  local status="${3:?}"
  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  local tmp="${spec_dir}/manifest.json.tmp"
  if [[ "$status" == "complete" ]]; then
    jq --arg phase "$phase" --arg status "$status" --arg now "$now" \
      '.phases[$phase].status = $status | .phases[$phase].completed_at = $now' \
      "${spec_dir}/manifest.json" > "$tmp"
  else
    jq --arg phase "$phase" --arg status "$status" \
      '.phases[$phase].status = $status' \
      "${spec_dir}/manifest.json" > "$tmp"
  fi
  mv "$tmp" "${spec_dir}/manifest.json"
}

# Verify a prerequisite phase is complete, exit with message if not
# Usage: qrspi_check_prereq <spec-dir> <phase>
qrspi_check_prereq() {
  local spec_dir="${1:?Usage: qrspi_check_prereq <spec-dir> <phase>}"
  local phase="${2:?}"
  local exists
  exists=$(jq -r --arg p "$phase" '.phases | has($p)' "${spec_dir}/manifest.json")
  if [[ "$exists" != "true" ]]; then
    echo "ERROR: Phase '${phase}' is not a recognized phase in this manifest. Check for a typo in the phase name." >&2
    return 1
  fi
  local status
  status=$(jq -r --arg p "$phase" '.phases[$p].status' "${spec_dir}/manifest.json")
  if [[ "$status" != "complete" ]]; then
    echo "ERROR: Phase '${phase}' is not complete (status: ${status}). Invoke the qrspi-${phase} skill first." >&2
    return 1
  fi
}

# Find the spec directory for the current repo by looking for manifests
# Returns the most recently modified spec dir, or empty if none
qrspi_find_active_spec() {
  local repo
  repo=$(qrspi_repo_name)
  local base=".copilot-qrspi/${repo}/specs"
  if [[ ! -d "$base" ]]; then
    echo ""
    return
  fi
  # Find the most recently modified manifest (BSD/macOS stat syntax; use
  # /usr/bin/stat explicitly in case Homebrew coreutils shadow it in PATH)
  local latest
  latest=$(find "$base" -name manifest.json -exec /usr/bin/stat -f '%m %N' {} \; 2>/dev/null | sed 's|/manifest\.json$||' | sort -rn | head -1 | awk '{print $2}')
  echo "${latest:-}"
}

# Slugify a string: lowercase, replace non-alphanumeric with hyphens, trim to max length
# Usage: qrspi_slugify <string> [max-length]
qrspi_slugify() {
  local input="${1:?}"
  local max="${2:-50}"
  echo "$input" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z0-9]/-/g' \
    | sed 's/--*/-/g' \
    | sed 's/^-//;s/-$//' \
    | cut -c1-"$max"
}
