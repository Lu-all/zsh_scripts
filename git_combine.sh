if [ $1 = "-h" ]; then
    echo "Usage: git_combine"
    echo "Combine the current branch with the origin branch"
    exit 0
fi

git config pull.rebase false
git stash
git merge origin
git stash pop