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

Try It Out
==========

git clone git://github.com/nnutter/git-branchdir-manager.git
source git-branchdir-manager/git-branchdir-manager.sh

Recomended Install
==================

If you don't do this already you might consider creating a ~/.bashrc.d directory and loading all scripts in it with something like this in your ~/.bashrc:

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
