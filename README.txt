encrypt_script.bash: passphrase-based encryption of Bash shell scripts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
encrypt_script.bash encrypts a Bash shell script with one or more
passphrases, creating a self-decrypting Bash shell script, which asks for
the passphrase, and if it matches any of the passphrases used for
encryption, then decrypts and executes the original script.

encrypt_script.bash and the encrypted scripts it creates use the openssl(1)
-command-line tool with the aes-256-cbc crypto. They also use Bash
(/bin/bash) and /dev/fd/... and /dev/tty . There is no other dependency.

encrypt_script.bash and the encrypted scripts don't create any temporary
files.

encrypt_script.bash and the encrypted scripts don't put passphrases into the
argv (so users running ps(1) can't inspect it).

encrypt_script.bash uses openssl(1) with a random salt by default, thus the
output file will be different even after rerunning for the same input.

__END__
