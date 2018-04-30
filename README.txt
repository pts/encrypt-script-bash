encrypt_script.bash: passphrase-based encryption of Bash shell scripts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
encrypt_script.bash encrypts a Bash or Zsh shell script with one or more
passphrases, creating a self-decrypting Bash or Zsh shell script, which asks
for the passphrase, and if it matches any of the passphrases used for
encryption, then decrypts (using gpg(1) or openssl(1)) and executes the
original script.

Example usage for creating an encrypted script:

  $ echo 'echo hi"!$@"; id "$@"' >plain.sh
  $ :>passphrase.in; chmod 600 passphrase.in
  $ echo secret >passphrase.in
  $ ./encrypt_script.bash --out=encrypted.sh passphrase.in <plain.sh
  $ ./encrypted.sh
  enter bash-script passphrase:
  fatal: incorrect bash-script passphrase
  $ ./encrypted.sh
  enter bash-script passphrase:
  hi!
  ...

If you can't afford any of gpg(1) or openssl(1) tp be installed on the
computer running the encrypted script, but you have Perl there, you may be
interested in https://github.com/pts/encrypt_script instead. Please note that
the crypto there is weak, e.g. it uses the RC4 cipher.

encrypt_script.bash and the encrypted scripts it creates use the gpg(1) (or
openssl(1) with -aes-256-cbc if --backend=openssl is specified) command-line
tool. They also use Bash (/bin/bash, also works with Zsh) and /dev/tty .
There is no other dependency.

encrypt_script.bash and the encrypted scripts don't create any temporary
files.

encrypt_script.bash and the encrypted scripts don't put passphrases into the
argv or to the environment (so users running ps(1) can't inspect it).

encrypt_script.bash uses gpg(1) (or openssl(1)) with a random salt, thus the
output file will be different even after rerunning for the same input.

The encrypted scripts need Bash (rather than e.g. Busybox sh or Dash) to
run, because they use the <<< and <(...) redirections, which are not
supported by Busybox sh or Dash. Bash versions tested and found working:
4.1.5 (2009) ... 4.4.19 (2018). The encrypted scripts also work with Zsh,
tested and found working: 4.3.10 (2009) ... 5.4.2 (2018).

Standard files (stdin, stdout and stderr), environment (except for a few
variables used for encryption) and arguments (argv, e.g. $1) are passed to
the script after decryption. The script filename and line number are not
passed around properly, the file name will be `eval', and line the line
number will have about 48 added to it.

How secure are scripts encrypted by encrypt_script.sh?

* good: The used aes-256-cbc crypto is secure.
* good: The passphrase doesn't show up in argv or environment variables, so
  other processes running in the same system can't easily inspect it with
  /proc (but root can create a memory dump to inspect it).
* good: Crypto is as secure as the default gpg settings where
  encrypt_script.bash is run (usually good).
* bad for --backend=openssl: The key derivation scheme is weak, a dictionary
  attack is much faster than with the default --backend=gpg .
* bad for --backend=openssl: There is no integrity protection, so the middle
  of the encrypted script can be modified without knowing the passphrase,
  and this won't be detected at extraction time. (By modifying 1 bytes, 20
  or more bytes in the decrypted stream may get ruined.) --backend=gpg does
  provide integrity protection.

Why is both encryption and decryption slow with --backend=gpg and newer GPG
(e.g. gpg-2.2.2): key derivation is slow. To make it faster and less secure
(i.e. more vulnerable to dictionary attacks), specify encrypt_script.bash
--s2k-count=... with a small number: the smaller the faster.

Encrypted scripts are not binary-safe. They are safe if the script to be
encrypted doesn't contain the 0 byte (ASCII NUL). Bash ignores this byte in
some context such as here-documents (<<'END'). Zsh doesn't ignore it.

gpg version compatibility:

* gpg-1.4.10 (2008): OK
* gpg-1.4.16 (2013): OK
* gpg-2.2.2 (2017): OK

openssl version compatibility:

* OpenSSL 0.9.8k 25 Mar 2009: OK (default is -md md5)
* OpenSSL 1.0.2o  27 Mar 2018: OK (default is -md md5)
* OpenSSL 1.1.0g  2 Nov 2017: OK (default is not -md sha256)

__END__
