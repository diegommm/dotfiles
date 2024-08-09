#!/bin/sh

set -x
set -e

# creating SSH key
if [ ! -e ~/.ssh/id_rsa.pub ]; then
    ssh-keygen -t RSA -b 16384 -f ~/.ssh/id_rsa
fi

git config --global user.email "${email:?Define your email}"
git config --global user.name "${name:?Define your full name}"

# use SSH to sign commits, tags and pushes
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_rsa.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global push.gpgsign if-asked

# allow verifying our own signatures
cp ~/.ssh/id_rsa.pub ~/.ssh/allowed_signers
chmod 0600 ~/.ssh/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
