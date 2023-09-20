#!/bin/sh -eo -pipefail

# Reduce a semver tag name to a Metro's release branch naming convention, eg v0.1.2-alpha.3 -> 0.1.x
RELEASE_BRANCH=$(echo "$CIRCLE_TAG" | awk -F. '{print substr($1, 2) "." $2 ".x"}')
echo "Release branch: $RELEASE_BRANCH"

# Does a release branch contain this tag (hotfix workflow) (0 or 1)
TAG_ON_RELEASE_BRANCH=$(git branch -a --contains "$CIRCLE_TAG" | grep -cFx "  remotes/origin/$RELEASE_BRANCH" || true)
echo "Tag is on release branch $RELEASE_BRANCH: $TAG_ON_RELEASE_BRANCH"

# Does main contain this tag (0 or 1)
TAG_ON_MAIN=$(git branch -a --contains "$CIRCLE_TAG" | grep -cFx '  remotes/origin/main' || true)
echo "Tag is on main branch: $TAG_ON_MAIN"

if [ $TAG_ON_RELEASE_BRANCH -eq $TAG_ON_MAIN ]; then
    echo "Could not determine whether this tag is 'latest' or a hotfix. Aborting."
    exit 1
fi

TAG="latest"
[ "$TAG_ON_RELEASE_BRANCH" -eq 1 ] && TAG=$RELEASE_BRANCH
echo "Using --tag=$TAG"

npm run publish --tag="$TAG"
