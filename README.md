# MeowArch host cross-toolchain

This repository publishes the host (`x86_64`) binaries used to build the
AArch64 Kernel, UEFI, DTB and ESP stages. It is deliberately separate from
the ARM rootfs runtime.

The current bundle contains the Arch packages for:

```text
clang / llvm / lld
aarch64-linux-gnu-gcc
aarch64-linux-gnu-binutils
aarch64-linux-gnu-glibc
aarch64-linux-gnu-linux-api-headers
dtc / grub / mtools / dosfstools / e2fsprogs
make / cmake / meson / ninja / nasm
python / pip / virtualenv / setuptools / uuid
```

The payload is a GitHub Release asset rather than a Git blob. This keeps the
manifest repository small while still giving the Builder a fixed binary and
SHA-256. `fetch.sh` downloads and extracts it under the requested directory.

```sh
./toolchain/fetch.sh --root .work/host-toolchain
source .work/host-toolchain/env.sh
```

The Builder uses this toolchain for host cross-compilation. Rootfs/AUR
assembly remains a separate ARM-native stage because package build scripts can
execute target binaries.
