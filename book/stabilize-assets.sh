#!/usr/bin/env bash
#
# Quarto post-render hook: give the theme assets version-independent filenames.
#
# Quarto names the compiled theme bundle after a hash of its contents
# (site_libs/bootstrap/bootstrap-<hash>.min.css). The hash changes between
# Quarto releases, so contributors on different versions each emit a different
# filename. Every new one arrives as an *untracked* file, and `git commit -am`
# does not stage new files, so the HTML ends up published pointing at a
# stylesheet that is not in the repository and the page loses its layout.
#
# This hook renames those bundles to fixed names and rewrites every reference to
# them. Because the fixed name is a tracked file, a different Quarto version now
# produces an ordinary modification, which `git commit -am` does stage.
#
# It also rewrites references whose file is absent, so a page rendered by a
# contributor who forgot to commit their assets still points at the bundle the
# repository does have.
#
# Wired up in _quarto.yml as:
#
#     project:
#       post-render: bash stabilize-assets.sh
#
# Safe to run by hand, and idempotent:
#
#     QUARTO_PROJECT_OUTPUT_DIR=../docs bash book/stabilize-assets.sh

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="${QUARTO_PROJECT_OUTPUT_DIR:-$here/../docs}"

if [ ! -d "$out" ]; then
    echo "stabilize-assets: output directory '$out' not found; nothing to do" >&2
    exit 0
fi
out="$(cd "$out" && pwd)"

# collapse <dir> <glob> <stable name> <reference regex>
collapse() {
    local dir="$out/$1" glob="$2" stable="$3" re="$4"
    local newest=""

    if [ -d "$dir" ]; then
        # Newest wins, so a fresh render replaces the committed bundle.
        while IFS= read -r f; do
            [ -n "$f" ] || continue
            if [ -z "$newest" ] || [ "$f" -nt "$newest" ]; then newest="$f"; fi
        done < <(find "$dir" -maxdepth 1 -name "$glob" -type f 2>/dev/null)

        if [ -n "$newest" ]; then
            mv -f "$newest" "$dir/$stable"
            # Drop any other hashed copies; every reference now points at $stable.
            while IFS= read -r f; do
                [ -n "$f" ] && [ "$f" != "$dir/$stable" ] && rm -f "$f"
            done < <(find "$dir" -maxdepth 1 -name "$glob" -type f 2>/dev/null)
            echo "stabilize-assets: $(basename "$newest") -> $1/$stable"
        fi
    fi

    # Rewrite references even when no file was found: a page may cite a bundle
    # whose file was never committed, and the stable name is the one that exists.
    while IFS= read -r -d '' html; do
        if grep -qE "$re" "$html"; then
            sed -i -E "s|$re|$stable|g" "$html"
        fi
    done < <(find "$out" -name '*.html' -type f -print0)
}

collapse "site_libs/bootstrap" \
         "bootstrap-*.min.css" \
         "bootstrap.min.css" \
         "bootstrap-[0-9a-f]{8,}\.min\.css"

collapse "site_libs/quarto-html" \
         "quarto-syntax-highlighting-*.css" \
         "quarto-syntax-highlighting.css" \
         "quarto-syntax-highlighting-[0-9a-f]{8,}\.css"
