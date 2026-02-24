#!/usr/bin/env bash
set -euo pipefail

# Concatenates all markdown files in nav order, strips MkDocs-specific
# syntax that Pandoc can't handle, and outputs a single combined.md.

DOCS_DIR="docs"
OUTPUT="combined.md"

FILES=(
  "$DOCS_DIR/index.md"
  "$DOCS_DIR/platform-configuration.md"
  "$DOCS_DIR/slo-tiering.md"
  "$DOCS_DIR/slo-lifecycle.md"
  "$DOCS_DIR/ownership-governance.md"
  "$DOCS_DIR/cicd-integration.md"
  "$DOCS_DIR/integration-existing-systems.md"
  "$DOCS_DIR/operational-playbooks.md"
  "$DOCS_DIR/common-pitfalls.md"
  "$DOCS_DIR/appendices.md"
)

: > "$OUTPUT"

for i in "${!FILES[@]}"; do
  file="${FILES[$i]}"

  if [ ! -f "$file" ]; then
    echo "WARNING: $file not found, skipping" >&2
    continue
  fi

  # Insert page break between sections (not before the first file)
  if [ "$i" -gt 0 ]; then
    printf '\n\\newpage\n\n' >> "$OUTPUT"
  fi

  content=$(cat "$file")

  # index.md needs special handling: strip YAML front matter and hero-banner div
  if [ "$file" = "$DOCS_DIR/index.md" ]; then
    # Strip YAML front matter (opening --- to closing ---)
    content=$(echo "$content" | awk 'BEGIN{skip=0} NR==1 && /^---$/{skip=1; next} skip && /^---$/{skip=0; next} !skip')
    # Strip the hero-banner opening and closing div tags
    content=$(echo "$content" | grep -v '<div class="hero-banner"' | grep -v '</div>')
  fi

  # Strip :material-*: emoji shortcodes (used by mkdocs-material)
  content=$(echo "$content" | sed 's/ *:material-[a-z-]*: *//g')

  echo "$content" >> "$OUTPUT"
done

echo "Preprocessing complete: $OUTPUT"
