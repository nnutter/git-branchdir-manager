What is git-branchdir-manager?
==============================

git-branchdir-manager creates separate working directories for each branch of a repo. It then helps you manage your repos and branches by providing tab completion to switch between them, create new branches, fold changes into your master branch, and remove branches.

Usage
=====

~~~
gbm <repo_name> init <repo_url>
gbm <repo_name> <branch_name>
gbm <repo_name> <branch_name> publish
gbm <repo_name> <branch_name> rm
gbm <repo_name> <branch_name> lib
~~~

Configuration
=============

If you wish to override any of these setting export these variables in your `.bashrc` before you source git-branchdir-manager.sh.

`GB_BASE_DIR` (default = "$HOME/gbm") The base directory where your repos will be stored.  
`GB_DEV_BRANCH` (default = "master") The branch you wish to develop off of.  
`GB_DEV_REMOTE` (default = "origin") The remote you wish to develop off of.  
`GB_WORKFLOW` (default = "rebase") Whether you rebase or merge.  

Install
=======

If you already have a .bashrc that is setup to load a directory of .bashrc files then just `git clone` in that directory. If you do not have this setup then running this will set that up and source git-branchdir-manager.sh. Feel free to peek at the [setup.sh source][1] and the [.bashrc addition][2].

~~~
bash >(curl https://raw.github.com/nnutter/git-branchdir-manager/master/setup.sh)
~~~

Repo Subcommands
================

- **init**

    Initialize a new repo. This sets up a hidden "master" repo which is used to create the sparse repos (working directories).

Branchdir Subcommands
=====================

- **publish**

    Merges the branch into `$GB_MASTER_BRANCH` and pushes it to `origin/$GB_DEV_BRANCH`.

- **rm**

    Removes the branch and working directory. If there are unmerged commits or changes then you will be prompted to confirm the removal.

- **lib**

    Echos the "lib" directory in the branch so you can use it in includes. For example:

    `export PERL5LIB=$(b repo branch lib):$PERL5LIB`

TODO
====

- Per-repo configurations.
- Configurable default directory.
- Rewrite guts in non-Bash?

[1]: https://github.com/nnutter/git-branchdir-manager/blob/master/setup.sh
[2]: https://github.com/nnutter/git-branchdir-manager/blob/master/bashrc
