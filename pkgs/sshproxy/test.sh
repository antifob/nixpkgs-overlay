# ==================================================================== #
set -eu

PROGBASE=$(d=$(dirname -- "${0}"); cd "${d}" && pwd)
cd "${PROGBASE}"

LANG=C; export LANG

# -------------------------------------------------------------------- #

deps() {
	cat "${PROGBASE}/default.nix" | \
		xargs echo | \
		grep '^{' | \
		sed -e 's|^{\([^}]\{1,\}\).*|\1|' | \
		sed -e 's|,| |g'
}

pl() {
	cat << __EOF__
:l <nixpkgs>
import ./. { inherit $(deps); }
__EOF__
}

drv=$(pl | nix-repl 2>&1 | grep 'derivation /nix/store')
drv=$(printf '%s' "${drv}" | sed -e 's|.*\(/nix/store/[^ ]\{1,\}drv\).*|\1|')
bld=$(nix-build --no-out-link "${drv}")

[ X != X"${bld}" ]
[ -x "${PROGBASE}/result/bin/sshproxy" ]

printf 'ok\n'

rm -f "${PROGBASE}/result"
nix-store --delete "${bld}"

# ==================================================================== #
