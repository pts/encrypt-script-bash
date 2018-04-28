#!/bin/bash --
#
# encrypt_script.bash: passphrase-based encryption of Bash shell scripts
# by pts@fazekas.hu at Sat Apr 21 17:02:15 CEST 2018
#
# Tested and works on Bash and Zsh. Needs /dev/tty (Linux has it.)
# TODO(pts): Make it work on macOS. Does it have /dev/tty?
#

function die() {
  echo "fatal: $*" >&2
  exit 1
}

if test "$1" = --help || test $# = 0; then
  echo "encrypt_script.bash: passphrase-based encryption of Bash shell scripts
This is free software, GNU GPL >=2.0. There is NO WARRANTY. Use at your risk.
Usage: $0 --out=<output-bash-script> [--ptype=<password-type>] [--] <passphrase-file> [...] < <input-bash-script>" >&2
  exit 0
fi

OUT=
test "${1#--out=}" = "$1" && die 'missing --out=...'
OUT="${1#*=}"
shift
PTYPE=bash-script
if test "${1#--ptype=*}" != "$1"; then
  PTYPE="${1#*=}"
  shift
fi
test "$1" = -- && shift
test $# = 0 && die 'missing <passphrase-file>'

D="$(command openssl enc -a -d -aes-256-cbc -k a -nosalt -md sha1 <<<'M1/LvAYWRMW2kWce+uoEBQ==' 2>/dev/null)"
test "$D" = unencumbered || die 'openssl enc -a -d -aes-256-cbc -md sha1 is broken'

D="$(command openssl rand -base64 57)"  # 76 base64 bytes.
test "$?" = 0 || die 'openssl rand failed'
test "$D" || die 'openssl rand returned empty output'
D="${D//
/}"

exec >"$OUT" || die 'error opening <input-bash-script>'

command chmod 755 -- "$OUT" || die "chmod failed"
echo "#!/bin/bash --
# Encrypted shell script. https://github.com/pts/encrypt-script-bash
function die() {
  echo \"fatal: \$*\" >&2
  exit 1
}
if ! type -p openssl 2>/dev/null >&2; then
  echo 'info: openssl not found for $PTYPE, installing' >&2
  command sudo apt-get install openssl
  type -p openssl 2>/dev/null >&2 || die 'openssl: command not found'
fi"
# unset is used to unexport, i.e. remove from the environment.
echo "unset PP EP D D1 C
D=\"\$(command openssl enc -a -d -aes-256-cbc -k a -nosalt -md sha1 <<<'M1/LvAYWRMW2kWce+uoEBQ==' 2>/dev/null)\"
test \"\$D\" = unencumbered || die 'openssl enc -a -d -aes-256-cbc -md sha1 is broken'
echo -n \"enter $PTYPE passphrase: \" >&2
read -s PP </dev/tty
echo >&2
test \"\$PP\" || exit 1
D=
for EP in \\"
for PF in "$@"; do
PP=
read PP <"$PF"
test "$PP" || die "empty or missing passphrase in file: $PF"
PE="$(command openssl enc -a -aes-256-cbc -kfile <(echo -n "$PP") -md sha1 <<<"$D $D")"
test "$?" = 0 || die 'openssl enc on passphrase failed'
test "$PE" || die 'openssl enc on passphrase returned empty output'
echo "'${PE//
/ }' \\"
done
echo "; do
  read D < <(command openssl enc -a -d -aes-256-cbc -kfile <(echo -n \"\$PP\") -md sha1 <<<\"\${EP// /
}\" 2>/dev/null)
  test \"\$?\" = 0 && D1=\"\${D%% *}\" && test \"\$D1\" = \"\${D#* }\" && test \"\$D\" = \"\$D1 \$D1\" && D=\"\$D1\" && break
  D=
done
test \"\$D\" || die 'incorrect $PTYPE passphrase'
C=\"unset C;\$(command openssl enc -a -d -aes-256-cbc -kfile <(echo -n \"\$D\") -md sha1 2>/dev/null <<'HEREND'"
(read LINE; test "${LINE#\#!}" = "$LINE" || LINE=; echo "$LINE"; command cat) |
    command openssl enc -a -aes-256-cbc -kfile <(echo -n "$D") -md sha1 || die "openssl enc on payload failed"
echo "HEREND
)\"
test \"\$?\" = 0 || die 'decrypt failed'
unset PP EP D D1
unset -f die
eval \"\$C\""
# The trailing eval above propagates the exit code. Good.
