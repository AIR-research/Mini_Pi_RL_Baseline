#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
destination="$project_dir/.vendor/isaacgym"

if [[ -f "$destination/python/setup.py" ]]; then
    printf 'Isaac Gym is already available at %s\n' "$destination"
else
    archive="${1:-}"

    if [[ -z "$archive" ]]; then
        download_dir="${HOME}/Downloads"
        if [[ -d "$download_dir" ]]; then
            archive="$(find "$download_dir" -maxdepth 1 -type f \
                \( -iname 'IsaacGym*Preview*4*.tar.gz' -o -iname 'IsaacGym*.tar.gz' \) \
                -print -quit)"
        fi
    fi

    if [[ -z "$archive" || ! -f "$archive" ]]; then
        cat >&2 <<'EOF'
Isaac Gym Preview 4 was not found.

1. Accept NVIDIA's license and download the Linux Preview 4 archive:
   https://developer.nvidia.com/isaac-gym/download
2. Run this command again, optionally passing the archive path:
   ./bootstrap-pixi.sh ~/Downloads/IsaacGym_Preview_4_Package.tar.gz
EOF
        exit 2
    fi

    case "$archive" in
        *.tar.gz|*.tgz) ;;
        *)
            printf 'Unsupported archive %s; expected a .tar.gz file.\n' "$archive" >&2
            exit 2
            ;;
    esac

    temp_dir="$(mktemp -d)"
    trap 'rm -rf -- "$temp_dir"' EXIT
    printf 'Extracting %s...\n' "$archive"
    tar -xzf "$archive" -C "$temp_dir"

    setup_file="$(find "$temp_dir" -type f -path '*/isaacgym/python/setup.py' -print -quit)"
    if [[ -z "$setup_file" ]]; then
        printf 'The archive does not contain isaacgym/python/setup.py.\n' >&2
        exit 2
    fi

    source_dir="${setup_file%/python/setup.py}"
    mkdir -p "$project_dir/.vendor"
    mv -- "$source_dir" "$destination"
    printf 'Installed Isaac Gym files at %s\n' "$destination"
fi

if command -v pixi >/dev/null 2>&1; then
    pixi_bin="$(command -v pixi)"
elif [[ -x "${HOME}/.pixi/bin/pixi" ]]; then
    pixi_bin="${HOME}/.pixi/bin/pixi"
else
    printf 'Pixi is not installed or is not on PATH: https://pixi.sh/latest/\n' >&2
    exit 2
fi

printf 'Installing the locked Pixi environment...\n'
cd "$project_dir"
"$pixi_bin" install --locked
printf '\nReady. Enter the environment with: pixi shell\n'
