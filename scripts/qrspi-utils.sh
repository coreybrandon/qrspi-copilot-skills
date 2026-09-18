#!/bin/bash
# QRSPI shared utilities — sourced by skill instructions via the bash tool
# Usage: source ~/.copilot/scripts/qrspi-utils.sh
#
# Targets macOS: uses the BSD `stat`/`date` shipped with macOS. If Homebrew's
# GNU coreutils are earlier in PATH, `/usr/bin/stat` is used explicitly below
# so BSD flag syntax (`-f`) keeps working regardless of PATH ordering.

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
# Usage: qrspi_spec_dir <feature-name>
#   Use qrspi_find_active_spec instead when no feature name is known.
qrspi_spec_dir() {
  local feature="${1:?Usage: qrspi_spec_dir <feature-name>}"
  local repo
  repo=$(qrspi_repo_name)
  echo ".copilot-qrspi/${repo}/specs/${feature}"
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
  # jq's exit status must be checked explicitly (no global set -e in this
  # sourced library) so a failed update never overwrites manifest.json with
  # a truncated/empty tmp file.
  if [[ "$status" == "complete" ]]; then
    if ! jq --arg phase "$phase" --arg status "$status" --arg now "$now" \
      '.phases[$phase].status = $status | .phases[$phase].completed_at = $now' \
      "${spec_dir}/manifest.json" > "$tmp"; then
      echo "ERROR: Failed to update manifest.json for phase '${phase}'" >&2
      rm -f "$tmp"
      return 1
    fi
  else
    if ! jq --arg phase "$phase" --arg status "$status" \
      '.phases[$phase].status = $status' \
      "${spec_dir}/manifest.json" > "$tmp"; then
      echo "ERROR: Failed to update manifest.json for phase '${phase}'" >&2
      rm -f "$tmp"
      return 1
    fi
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
