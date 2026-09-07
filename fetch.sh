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

valid=0
if [ -f "$archive" ] && printf '%s  %s\n' "$MEOWARCH_TOOLCHAIN_SHA256" "$archive" | sha256sum -c - >/dev/null 2>&1; then
	valid=1
fi
if [ "$valid" -eq 0 ]; then
	part="$archive.part"
	curl_args=(--fail --location --retry 5 --retry-all-errors --output "$part")
	[ -n "${MEOWARCH_PROXY:-}" ] && curl_args+=(--proxy "$MEOWARCH_PROXY")
	curl "${curl_args[@]}" "$url"
	printf '%s  %s\n' "$MEOWARCH_TOOLCHAIN_SHA256" "$part" | sha256sum -c -
	mv -f "$part" "$archive"
fi
tar --zstd -xf "$archive" -C "$root"

cat >"$root/env.sh" <<EOF
export MEOWARCH_TOOLCHAIN_ROOT=$(printf '%q' "$root")
export PATH=\"\$MEOWARCH_TOOLCHAIN_ROOT/usr/bin:\$PATH\"
export LD_LIBRARY_PATH=\"\$MEOWARCH_TOOLCHAIN_ROOT/usr/lib:\$MEOWARCH_TOOLCHAIN_ROOT/lib:\${LD_LIBRARY_PATH:-}\"
export CROSS_COMPILE=\"\$MEOWARCH_TOOLCHAIN_ROOT/usr/bin/aarch64-linux-gnu-\"
export CLANG_TRIPLE=aarch64-linux-gnu
export LLVM=1
EOF
echo "toolchain ready: $root"
