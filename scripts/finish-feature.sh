#!/bin/bash

set -e

CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" = "develop" ]; then
    echo "❌ You are already on develop."
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Working tree is not clean."
    echo "Commit or stash your changes first."
    exit 1
fi

echo "Current branch: $CURRENT_BRANCH"

echo "Switching to develop..."
git checkout develop

echo "Updating develop..."
git pull origin develop

echo "Merging '$CURRENT_BRANCH' into develop..."
git merge --no-ff "$CURRENT_BRANCH" -m "Merge branch '$CURRENT_BRANCH' into develop"

echo "Pushing develop..."
git push origin develop

echo "Returning to $CURRENT_BRANCH..."
git checkout "$CURRENT_BRANCH"

echo ""
echo "✅ Feature successfully merged into develop."
echo "🚀 GitHub Actions will now deploy develop."