#!/bin/bash
set -o errexit

curl -f https://raw.github.com/nnutter/git-branchdir-manager/master/bashrc >> ${HOME}/.bashrc
mkdir ${HOME}/.bashrc.d
cd ${HOME}/.bashrc.d
git clone git://github.com/nnutter/git-branchdir-manager.git ${HOME}/.bashrc.d/git-branchdir-manager
