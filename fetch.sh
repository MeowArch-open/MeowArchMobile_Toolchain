#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root="$repo_dir/.work/host-toolchain"
while [ "$#" -gt 0 ]; do
	case "$1" in
		--root) root=$2; shift 2 ;;
		-h|--help)
			echo 'usage: fetch.sh [--root DIR]'
			exit 0
			;;
		*) echo "unknown option: $1" >&2; exit 2 ;;
	esac
done

# shellcheck disable=SC1091
. "$repo_dir/toolchain.env"
mkdir -p "$root"
archive="$root/$MEOWARCH_TOOLCHAIN_ASSET"
url="https://github.com/MeowArch-open/MeowArchMobile_Toolchain/releases/download/host-x86_64-$MEOWARCH_TOOLCHAIN_VERSION/$MEOWARCH_TOOLCHAIN_ASSET"

if [ ! -f "$archive" ]; then
	curl --fail --location --retry 5 --retry-all-errors --output "$archive" "$url"
fi
printf '%s  %s\n' "$MEOWARCH_TOOLCHAIN_SHA256" "$archive" | sha256sum -c -
tar --zstd -xf "$archive" -C "$root"

cat >"$root/env.sh" <<EOF
export MEOWARCH_TOOLCHAIN_ROOT=$(printf '%q' "$root")
export PATH=\"\$MEOWARCH_TOOLCHAIN_ROOT/usr/bin:\$PATH\"
export CROSS_COMPILE=\"\$MEOWARCH_TOOLCHAIN_ROOT/usr/bin/aarch64-linux-gnu-\"
export CLANG_TRIPLE=aarch64-linux-gnu
export LLVM=1
EOF
echo "toolchain ready: $root"
