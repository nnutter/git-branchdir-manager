What is git-branchdir-manager?
==============================

git-branchdir-manager creates separate working directories for each branch of a repo. It then helps you manage your repos and branches by providing tab completion to switch between them, create new branches, fold changes into your master branch, and remove branches.

Usage
=====

~~~
git-branchdir-manager <repo_name> init <repo_url>
git-branchdir-manager <repo_name> <branch_name> start
git-branchdir-manager <repo_name> <branch_name>
git-branchdir-manager <repo_name> <branch_name> finish
git-branchdir-manager <repo_name> <branch_name> rm
git-branchdir-manager <repo_name> <branch_name> lib
~~~

Configuration
=============

If you wish to override any of these setting export these variables in your `.bashrc` before you source git-branchdir-manager.sh.

`GB_BASE_DIR` (default = "$HOME/git") The base directory where your repos will be stored.  
`GB_DEV_BRANCH` (default = "master") The branch you wish to develop off of.  
`GB_DEV_REMOTE` (default = "origin") The remote you wish to develop off of.  
`GB_WORKFLOW` (default = "rebase") Whether you rebase or merge.  

Try It Out
==========

~~~
git clone git://github.com/nnutter/git-branchdir-manager.git
source git-branchdir-manager/git-branchdir-manager.sh
b $some_repo init $some_repo_url # b is default alias for git-branchdir-manager
~~~

Recomended Install
==================

If you don't do this already you might consider creating a `~/.bashrc.d` directory and loading all scripts in it with something like this in your `~/.bashrc`:

~~~
function load_dir {
   LOAD_DIR=${1}
   if [ -d $LOAD_DIR -a -r $LOAD_DIR -a -x $LOAD_DIR ]; then
       local i
       for i in $(find -L $LOAD_DIR -name '*.sh'); do
           source $i
       done
   fi
}

load_dir ${HOME}/.bashrc.d
~~~

Then actually "install" it by doing:

~~~
mkdir ${HOME}/.bashrc.d
cd ${HOME}/.bashrc.d
git clone git://github.com/nnutter/git-branchdir-manager.git
~~~

Synopsis
========

- **init**

    Initialize a new repo. This sets up a hidden "master" repo which is used to create the sparse repos (working directories).

- **start**

    Creates a new branch and working directory.

- **finish**

    Merges the branch into `$GB_MASTER_BRANCH` and pushes it to `origin/$GB_DEV_BRANCH`.

- **rm**

    Removes the branch and working directory. If there are unmerged commits or changes then you will be prompted to confirm the removal.

- **lib**

    Echos the "lib" directory in the branch so you can use it in includes. For example:

    `export PERL5LIB=$(b repo branch lib):$PERL5LIB`

TODO
====

- Per-repo configurations.
- Better names for start and finish.
- Configurable default directory.
- Rewrite guts in non-Bash?
