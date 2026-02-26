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

# Start with the cover banner image as the title page
printf '![](docs/images/cover-banner.png)\n' > "$OUTPUT"

first=true
for name in $FILES; do
  file="$DOCS_DIR/$name"

  if [ ! -f "$file" ]; then
    echo "WARNING: $file not found, skipping" >&2
    continue
  fi

  # Insert page break between sections
  printf '\n\\newpage\n\n' >> "$OUTPUT"

  content=$(cat "$file")

  # index.md: strip front matter, title heading, hero div, and the
  # horizontal rule after the hero. The cover banner image replaces all of it.
  if [ "$name" = "index.md" ]; then
    content=$(echo "$content" | awk '
      NR==1 && /^---$/ { fm=1; next }
      fm && /^---$/    { fm=0; next }
      fm               { next }
      /^# Nobl9 SLO Deployment Best Practices Guide$/ { next }
      /<div class="hero-banner"/ { hero=1; next }
      hero && /<\/div>/          { hero=0; next }
      hero                       { next }
      !started && /^$/           { next }
      !started && /^---$/        { next }
      { started=1; print }
    ')
  fi

  # Strip :material-*: emoji shortcodes (used by mkdocs-material)
  content=$(echo "$content" | sed 's/ *:material-[a-z-]*: *//g')

  # Rewrite image paths from docs-relative to repo-root-relative
  content=$(echo "$content" | sed 's|(images/|(docs/images/|g')

  echo "$content" >> "$OUTPUT"
done

echo "Preprocessing complete: $OUTPUT"
