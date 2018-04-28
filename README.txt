encrypt_script.bash: passphrase-based encryption of Bash shell scripts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
encrypt_script.bash encrypts a Bash or Zsh shell script with one or more
passphrases, creating a self-decrypting Bash or Zsh shell script, which asks
for the passphrase, and if it matches any of the passphrases used for
encryption, then decrypts and executes the original script.

encrypt_script.bash and the encrypted scripts it creates use the openssl(1)
command-line tool with the aes-256-cbc crypto. They also use Bash
(/bin/bash, also works with Zsh) and /dev/tty . There is no other dependency.

encrypt_script.bash and the encrypted scripts don't create any temporary
files.

encrypt_script.bash and the encrypted scripts don't put passphrases into the
argv or to the environment (so users running ps(1) can't inspect it).

encrypt_script.bash uses openssl(1) with a random salt by default, thus the
output file will be different even after rerunning for the same input.

The encrypted scripts need Bash (rather than e.g. Busybox sh or Dash) to
run, because they use the <<< and <(...) redirections, which are not
supported by Busybox sh or Dash. Bash versions tested and found working:
4.1.5 (2009) ... 4.4.19 (2018). The encrypted scripts also work with Zsh,
tested and found working: 4.3.10 (2009) ... 5.4.2 (2018).

How secure are scripts encrypted by encrypt_script.sh?

* good: The used aes-256-cbc crypto is secure.
* good: The passphrase doesn't show up in argv or environment variables, so
  other processes running in the same system can't easily inspect it with
  /proc (but root can create a memory dump to inspect it).
* bad: The key derivation scheme is weak, a dictionary attack is much faster
  than on `gpg --symmetric'.
* bad: There is no integrity protection, so the middle of the encrypted
  script can be modified without knowing the passphrase, and this won't be
  detected at extraction time. (By modifying 1 bytes, 20 or more bytes in
  the decrypted stream may get ruined.) `gpg --symmetric --force-mdc` does
  provide integrity protection.

Encrypted scripts are not binary-safe. They are safe if the script to be
encrypted doesn't contain the 0 byte (ASCII NUL). Bash ignores this byte in
some context such as here-documents (<<'END'). Zsh doesn't ignore it.

openssl version compatibility:

* OpenSSL 0.9.8k 25 Mar 2009: OK (default is -md md5)
* OpenSSL 1.0.2o  27 Mar 2018: OK (default is -md md5)
* OpenSSL 1.1.0g  2 Nov 2017: OK (default is not -md sha256)

__END__
