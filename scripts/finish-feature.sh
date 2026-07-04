#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" = "develop" ]; then
    echo -e "${RED}You are already on develop.${NC}"
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}Working tree is not clean.${NC}"
    echo "Commit or stash your changes first."
    exit 1
fi

echo "Current branch: $CURRENT_BRANCH"

echo "Switching to develop..."
git checkout develop

echo "Updating develop..."
git pull origin develop

echo "Merging..."
if ! git merge --no-ff "$CURRENT_BRANCH" -m "Merge branch '$CURRENT_BRANCH' into develop"; then

    echo ""
    echo -e "${RED}==============================================${NC}"
    echo -e "${RED} Merge conflict detected!${NC}"
    echo -e "${RED}==============================================${NC}"
    echo ""

    echo -e "${GREEN}Resolve the conflicts and continue manually:${NC}"
    echo ""
    echo "git status"
    echo "# resolve conflicts"
    echo "git add ."
    echo "git commit"
    echo "git push origin develop"
    echo ""

    exit 1
fi

echo "Pushing develop..."
git push origin develop

echo "Returning to $CURRENT_BRANCH..."
git checkout "$CURRENT_BRANCH"

echo ""
echo -e "${GREEN}Feature successfully merged into develop.${NC}"
echo -e "${GREEN}GitHub Actions will now deploy develop.${NC}"

echo ""
echo -e "${GREEN}Feature successfully merged into develop.${NC}"
echo -e "${GREEN}GitHub Actions will now deploy develop.${NC}"

REMOTE_URL=$(git remote get-url origin)

if [[ "$REMOTE_URL" =~ git@github.com:(.*)\.git ]]; then
    ACTIONS_URL="https://github.com/${BASH_REMATCH[1]}/actions"
elif [[ "$REMOTE_URL" =~ https://github.com/(.*)\.git ]]; then
    ACTIONS_URL="https://github.com/${BASH_REMATCH[1]}/actions"
fi

if [ -n "$ACTIONS_URL" ]; then
    echo "Opening GitHub Actions..."
    xdg-open "$ACTIONS_URL" >/dev/null 2>&1 &
fi