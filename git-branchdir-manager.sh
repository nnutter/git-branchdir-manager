alias b='git-branch'
complete -F _gb_complete b
complete -F _gb_complete git-branch

function _gb_env {
    if [ -z "$GB_BASE_DIR" ]; then
        GB_BASE_DIR="$HOME/git"
    fi
    if [ -z "$GB_DEV_SRC_BRANCH" ]; then
        GB_DEV_SRC_BRANCH="origin/master"
    fi
}

function _gb_help {
    echo "Usage:"
    echo "  git-branch <repo_name> init <repo_url>"
    echo "  git-branch <repo_name> <new_branch_name> new"
    echo "  git-branch <repo_name> <exiting_branch_name>"
    echo "  git-branch <repo_name> <exiting_branch_name> merge"
    echo "  git-branch <repo_name> <exiting_branch_name> rm"
    echo "  git-branch <repo_name> <exiting_branch_name> lib"
}

function _gb_repos {
    _gb_env
    if [ -d "$GB_BASE_DIR" ]; then
        find "$GB_BASE_DIR" -mindepth 1 -maxdepth 2 -type d -name master | sed -e "s|$GB_BASE_DIR/||" -e "s|/master||"
    fi
}

function _gb_repo_master_dir {
    _gb_env
    local GB_REPO="$1"
    local GB_BRANCH="master"
    local GB_BRANCH_DIR="$GB_BASE_DIR/$GB_REPO/$GB_BRANCH"
    echo "$GB_BRANCH_DIR"
}

function _gb_branches {
    _gb_env
    local GB_REPO=$1
    local GB_REPO_DIR="$GB_BASE_DIR/$GB_REPO"
    if [ -d "$GB_REPO_DIR" ]; then
        find "$GB_REPO_DIR" -mindepth 1 -maxdepth 2 -type d -name .git | sed -e "s|$GB_REPO_DIR/||" -e "s|/.git||"
    fi
}

function _gb_branch_dir {
    _gb_env
    local GB_REPO="$1"
    local GB_BRANCH="$2"
    local GB_BRANCH_DIR="$GB_BASE_DIR/$GB_REPO/$GB_BRANCH"
    echo "$GB_BRANCH_DIR"
}

function _gb_lib_path {
    _gb_env
    local GB_REPO="$1"
    local GB_BRANCH="$2"
    local GB_BRANCH_DIR="$GB_BASE_DIR/$GB_REPO/$GB_BRANCH"
    local GB_LIB_DIR

    if [ -d "$GB_BRANCH_DIR/lib/perl" ]; then
        GB_LIB_DIR="$GB_BRANCH_DIR/lib/perl"
    else
        if [ -d "$GB_BRANCH_DIR/lib" ]; then
            GB_LIB_DIR="$GB_BRANCH_DIR/lib"
        fi
    fi
    echo "$GB_LIB_DIR"
}

function _gb_cd_lib_dir {
    local GB_BRANCH_DIR=$1
    if [ -d "$GB_BRANCH_DIR/lib/perl/Genome" ]; then
        cd "$GB_BRANCH_DIR/lib/perl/Genome"
    else
        if [ -d "$GB_BRANCH_DIR/lib" ]; then
            cd "$GB_BRANCH_DIR/lib"
        fi
    fi
}

function _gb_cd_branch {
    _gb_env
    local GB_REPO="$1"
    local GB_BRANCH="$2"
    local GB_BRANCH_DIR="$GB_BASE_DIR/$GB_REPO/$GB_BRANCH"
    local GB_DO_CD_BRANCH=1

    if [ ! -d "$GB_BRANCH_DIR" ]; then
        GB_DO_CD_BRANCH=0
        echo "ERROR: Branch directory does not exist ($GB_BRANCH_DIR)."
        echo -n "Do you wish to create the branch (y/n)? "
        local response
        read -n 1 response && echo
        if [ "$response" == "y" ]; then
            _gb_new_branch "$GB_REPO" "$GB_BRANCH"
        fi
    fi

    if (( $GB_DO_CD_BRANCH )); then
        cd "$GB_BRANCH_DIR"
    fi

    _gb_cd_lib_dir "$GB_BRANCH_DIR"
}

function _gb_rm_branch {
    _gb_env

    local GB_REPO="$1"
    local GB_BRANCH="$2"
    local GB_BRANCH_DIR="$GB_BASE_DIR/$GB_REPO/$GB_BRANCH"
    local GB_DO_RM_BRANCH=1

    if [ ! -d "$GB_BRANCH_DIR" ]; then
        GB_DO_RM_BRANCH=0
        echo "ERROR: Branch directory does not exist ($GB_BRANCH_DIR)."
    fi

    PRIOR_DIR=$(pwd)
    if [ -d "$GB_BRANCH_DIR" ]; then
        cd "$GB_BRANCH_DIR"
    fi

    local GB_UPSTREAM_BRANCH=$(git config --get branch.$GB_BRANCH.merge | sed 's/^refs\/heads\///')
    local GB_UPSTREAM_REMOTE=$(git config --get branch.$GB_BRANCH.remote)
    if [ -z "$GB_UPSTREAM_BRANCH" ] || [ -z "$GB_UPSTREAM_REMOTE" ]; then
        GB_DO_RM_BRANCH=0
        echo "ERROR: Unable to determine upstream branch."
        echo "git config --get branch.$GB_BRANCH.merge | sed 's/^refs\/heads\///'"
        echo "git config --get branch.$GB_BRANCH.remote"
    fi

    if (( $GB_DO_RM_BRANCH )); then
        if (( $(git log --oneline $GB_UPSTREAM_REMOTE/$GB_UPSTREAM_BRANCH..HEAD | wc -l) )); then
            echo "ERROR: Unpushed changes in repo:"
            git log --oneline $GB_UPSTREAM_REMOTE/$GB_UPSTREAM_BRANCH..$GB_BRANCH | cat
            echo -n "Do you wish to remove this branch (y/n)? "
            local response
            read -n 1 response && echo
            if [ "$response" != "y" ]; then
                GB_DO_RM_BRANCH=0
            fi
        fi
    fi

    if (( $GB_DO_RM_BRANCH )); then
        if (( $(git status -s | wc -l) )); then
            echo "ERROR: Uncommitted changes in repo:"
            git status -s
            echo -n "Do you wish to remove this branch (y/n)? "
            local response
            read -n 1 response && echo
            if [ "$response" != "y" ]; then
                GB_DO_RM_BRANCH=0
            fi
        fi
    fi

    if (( $GB_DO_RM_BRANCH )); then
        if (( $(git branch | grep -P "\b$GB_BRANCH\b" | wc -l) )); then
            if (( $(git branch | grep -P "\* $GB_BRANCH\b" | wc -l) )); then
                git checkout master
            fi
            git branch -D "$GB_BRANCH"
        fi

        echo "Removing '$GB_BRANCH_DIR'..."
        sleep 1
        rm -rf "$GB_BRANCH_DIR"
    fi

    if [ -d "$PRIOR_DIR" ]; then
        cd $PRIOR_DIR
    else
        cd
    fi
}

function _gb_new_branch {
    _gb_env
    local GB_REPO="$1"
    local GB_BRANCH="$2"
    local GB_MASTER_DIR="$GB_BASE_DIR/$GB_REPO/master"
    local GB_BRANCH_DIR="$GB_BASE_DIR/$GB_REPO/$GB_BRANCH"
    local GB_DO_NEW_BRANCH=1
    if [ ! -d "$GB_MASTER_DIR" ]; then
        GB_DO_NEW_BRANCH=0
        echo "ERROR: Master directory does not exist ($GB_MASTER_DIR)."
    fi
    if [ -d "$GB_BRANCH_DIR" ]; then
        GB_DO_NEW_BRANCH=0
        echo "ERROR: Branch directory already exists ($GB_BRANCH_DIR)."
    fi
    if (( $GB_DO_NEW_BRANCH )); then
        local GB_GIT_NEW_WORKDIR
        if (( $(which git-new-workdir | wc -l) )); then
            GB_GIT_NEW_WORKDIR=$(which git-new-workdir)
        else
            local GB_TMP_GIT_NEW_WORKDIR="/tmp/git-new-workdir"
            echo "WARNING: git-new-workdir not installed, downloading to $GB_TMP_GIT_NEW_WORKDIR"
            local GB_GIT_NEW_WORKDIR_URL="https://raw.github.com/gitster/git/master/contrib/workdir/git-new-workdir"
            curl -s -o "$GB_TMP_GIT_NEW_WORKDIR" "$GB_GIT_NEW_WORKDIR_URL"
            GB_GIT_NEW_WORKDIR="/bin/sh $GB_TMP_GIT_NEW_WORKDIR"
        fi
        cd $GB_MASTER_DIR
        git pull --ff-only || git pull --rebase
        $GB_GIT_NEW_WORKDIR $GB_MASTER_DIR $GB_BRANCH_DIR
        cd $GB_BRANCH_DIR
        git checkout -b $GB_BRANCH --track "$GB_DEV_SRC_BRANCH"
        git merge master
    fi
    _gb_cd_lib_dir "$GB_BRANCH_DIR"
}

function _gb_merge_branch {
    _gb_env
    local GB_REPO="$1"
    local GB_BRANCH="$2"
    _gb_cd_branch "$GB_REPO" "master"
    git pull --ff-only || git pull --rebase
    git merge --no-ff "$GB_BRANCH"
}

function _gb_init_repo {
    _gb_env
    local GB_REPO="$1"
    local GB_REPO_URL="$2"
    local GB_REPO_BASE_DIR="$GB_BASE_DIR/$GB_REPO"
    local GB_REPO_MASTER_DIR="$GB_REPO_BASE_DIR/master"
    local GB_DO_INIT=1
    if [ -z "$GB_REPO_URL" ]; then
        _gb_help
        GB_DO_INIT=0
    fi
    if [ -d "$GB_REPO_MASTER_DIR" ]; then
        echo "ERROR: Repo master dir already exists ($GB_REPO_MASTER_DIR)."
        GB_DO_INIT=0
    fi
    if (( $GB_DO_INIT )); then
        mkdir -p "$GB_REPO_BASE_DIR"
        git clone "$GB_REPO_URL" "$GB_REPO_MASTER_DIR"
    fi
    _gb_cd_branch "$GB_REPO" "master"
}

function _gb_complete {
    COMPREPLY=()
    if (( ${#COMP_WORDS[@]} == 2 )); then
        local cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=($(compgen -W "$(_gb_repos)" -- $cur))
    fi
    if (( ${#COMP_WORDS[@]} == 3 )); then
        local cur=${COMP_WORDS[COMP_CWORD]}
        local GB_REPO=${COMP_WORDS[1]}
        if [ -d "$(_gb_repo_master_dir "$GB_REPO")" ]; then
            COMPREPLY=($(compgen -W "$(_gb_branches $GB_REPO)" -- $cur))
        else
            COMPREPLY=($(compgen -W "init" -- $cur))
        fi
    fi
    if (( ${#COMP_WORDS[@]} == 4 )); then
        local cur=${COMP_WORDS[COMP_CWORD]}
        local GB_REPO=${COMP_WORDS[1]}
        local GB_BRANCH=${COMP_WORDS[2]}
        if [ -d "$(_gb_branch_dir "$GB_REPO" "$GB_BRANCH")" ]; then
            COMPREPLY=($(compgen -W "cd lib merge rm" -- $cur))
        else
            if [ "$GB_BRANCH" != "init" ]; then
                COMPREPLY=($(compgen -W "new" -- $cur))
            fi
        fi
    fi
}

function _gb_fix {
    _gb_env
    local GB_REPO="$1"
    local GB_REPO_DIR="$GB_BASE_DIR/$GB_REPO"

    cd "$GB_REPO_DIR/master"
    if (( $(git status -s | wc -l) )); then
        echo "ERROR: Uncommitted changes in repo:"
        git status -s
        echo ""
        echo "Commit or remove your changes and then run fix again."
        return 255
    fi

    cd "$GB_REPO_DIR"
    mv master .gb_master
    cd "$GB_REPO_DIR/.gb_master/"
    git checkout -b gb_master -t "$GB_DEV_SRC_BRANCH"
    perl ~nnutter/scripts/fix_broken_symlinks "$GB_REPO_DIR"
    cd "$GB_REPO_DIR"
    echo "Now add a 'export GB_DEV=1' to your .bashrc (before you source git-branch.sh) until I've updated the stable version."
}

function git-branch {
    _gb_env
    local GB_REPO="$1"
    local GB_DO_ACTION=1;
    local GB_ACTION
    local GB_BRANCH
    case $# in
        0)
            GB_ACTION="help"
            ;;
        1)
            GB_ACTION="ls"
            ;;
        2)
            GB_BRANCH="$2"
            GB_ACTION="cd"
            ;;
        3)
            GB_BRANCH="$2"
            GB_ACTION="$3"
            ;;
        *)
            echo "ERROR: Too many arguments specified."
            GB_DO_ACTION=0
            ;;
    esac

    if [ "$GB_BRANCH" == "init" ]; then
        GB_BRANCH="$3"
        GB_ACTION="init"
    fi

    if [ "$GB_BRANCH" == "fix" ]; then
        GB_BRANCH=""
        GB_ACTION="fix"
    fi

    if [ "$GB_BRANCH" == "rm" ] || [ "$GB_BRANCH" == "new" ] ||  [ "$GB_BRANCH" == "init" ] || [ "$GB_BRANCH" == "merge" ] || [ "$GB_BRANCH" == "lib" ]; then
        GB_DO_ACTION=0
        echo "ERROR: No branch argument specified."
    fi

    for item in $*; do
        if [ "$item" == "--help" ] || [ "$item" == "-h" ]; then
            GB_ACTION="help"
            GB_DO_ACTION=1
        fi
    done

    if (( $GB_DO_ACTION )); then
        case $GB_ACTION in
            help)
                _gb_help
                ;;
            ls)
                _gb_branches "$GB_REPO"
                ;;
            cd)
                _gb_cd_branch "$GB_REPO" "$GB_BRANCH"
                ;;
            rm)
                _gb_rm_branch "$GB_REPO" "$GB_BRANCH"
                ;;
            new)
                _gb_new_branch "$GB_REPO" "$GB_BRANCH"
                ;;
            merge)
                _gb_merge_branch "$GB_REPO" "$GB_BRANCH"
                ;;
            init)
                local GB_REPO_URL="$GB_BRANCH"
                _gb_init_repo "$GB_REPO" "$GB_REPO_URL"
                ;;
            lib)
                _gb_lib_path "$GB_REPO" "$GB_BRANCH"
                ;;
            fix)
                _gb_fix "$GB_REPO"
                ;;
            *)
                echo "ERROR: Unrecognized action ($GB_ACTION)."
                ;;
        esac
    fi
}

function git-track {
    local TRACK_BRANCH="$1"
    local CURRENT_BRANCH=$(git branch 2> /dev/null | grep ^\* | sed 's/^\* //')
    echo -n "Are you sure you wish to replace the current working directory with $TRACK_BRANCH's (y/n)? "
    local response
    read -n 1 response && echo
    if [ "$response" == "y" ]; then
        git branch --set-upstream "$CURRENT_BRANCH" "$TRACK_BRANCH"
        git reset --hard "$TRACK_BRANCH"
    fi
}
