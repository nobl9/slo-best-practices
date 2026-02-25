#!/bin/sh
set -eu

# Concatenates all markdown files in nav order, strips MkDocs-specific
# syntax that Pandoc can't handle, and outputs a single combined.md.

DOCS_DIR="docs"
OUTPUT="combined.md"

FILES="
index.md
platform-configuration.md
slo-tiering.md
slo-lifecycle.md
ownership-governance.md
cicd-integration.md
integration-existing-systems.md
operational-playbooks.md
common-pitfalls.md
appendices.md
"

: > "$OUTPUT"

first=true
for name in $FILES; do
  file="$DOCS_DIR/$name"

  if [ ! -f "$file" ]; then
    echo "WARNING: $file not found, skipping" >&2
    continue
  fi

  # Insert page break between sections (not before the first file)
  if [ "$first" = true ]; then
    first=false
  else
    printf '\n\\newpage\n\n' >> "$OUTPUT"
  fi

  content=$(cat "$file")

  # index.md needs special handling: strip YAML front matter and hero-banner div
  if [ "$name" = "index.md" ]; then
    # Strip YAML front matter (opening --- to closing ---)
    content=$(echo "$content" | awk 'BEGIN{skip=0} NR==1 && /^---$/{skip=1; next} skip && /^---$/{skip=0; next} !skip')
    # Strip the hero-banner opening and closing div tags
    content=$(echo "$content" | grep -v '<div class="hero-banner"' | grep -v '</div>')
  fi

  # Strip :material-*: emoji shortcodes (used by mkdocs-material)
  content=$(echo "$content" | sed 's/ *:material-[a-z-]*: *//g')

  # Rewrite image paths from docs-relative to repo-root-relative
  content=$(echo "$content" | sed 's|(images/|(docs/images/|g')

  echo "$content" >> "$OUTPUT"
done

echo "Preprocessing complete: $OUTPUT"
