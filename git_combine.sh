if [ $1 = "-h" ]; then
    echo "Usage: git_combine"
    echo "Combine the current branch with the origin branch"
    exit 0
fi

# rebase = false
git config pull.rebase false
# Create stash
git stash
# Merge from origin
git merge origin
# Recover changes from stash
git stash pop
