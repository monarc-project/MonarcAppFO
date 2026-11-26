#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
bash scripts/check_node.sh

# package.json pins immutable commits belonging to the tested frontend releases.
while read -r name specification; do
    repository="${specification#git+}"
    revision="${repository##*#}"
    repository="${repository%#*}"
    if [[ ! "$name" =~ ^ng_(anr|client|backoffice)$ || ! "$revision" =~ ^[0-9a-f]{40}$ ]]; then
        echo "Frontend dependencies must name an ng_* module and an exact Git commit." >&2
        exit 1
    fi
    target="node_modules/$name"
    if [[ -L "$target" ]]; then
        echo "$target uses local sources. Use switch_repo_sources.sh remote to select releases." >&2
        exit 1
    fi
    if [[ ! -d "$target" ]]; then
        mkdir -p node_modules
        git clone --config core.fileMode=false "$repository" "$target"
    fi
    if [[ -d "$target/.git" ]]; then
        if [[ -n "$(git -C "$target" status --porcelain --untracked-files=no)" ]]; then
            echo "$target has tracked changes; commit or preserve them before installing releases." >&2
            exit 1
        fi
        if [[ "$(git -C "$target" rev-parse HEAD)" != "$revision" ]]; then
            git -C "$target" fetch --depth 1 origin "$revision"
            git -C "$target" checkout --detach FETCH_HEAD
        fi
        printf '%s\n' "$revision" > "$target/.monarc-source-ref"
    elif [[ ! -f "$target/.monarc-source-ref" || "$(cat "$target/.monarc-source-ref")" != "$revision" ]]; then
        echo "$target cannot be verified against the pinned frontend revision." >&2
        exit 1
    fi
    echo "$name: $revision"
done < <(php -r '
    $package = json_decode(file_get_contents("package.json"), true, 512, JSON_THROW_ON_ERROR);
    foreach ($package["dependencies"] as $name => $specification) {
        if (str_starts_with($name, "ng_")) {
            echo $name, " ", $specification, PHP_EOL;
        }
    }
')

for target in node_modules/ng_client node_modules/ng_backoffice; do
    if [[ -d "$target" ]]; then
        (cd "$target" && npm ci --no-audit --no-fund)
    fi
done
