#!/bin/sh
set -eu

# Input parameters.

FILENAME=$1
PACKAGE=$2

# Apply hotfix for 'fatal: unsafe repository' error.

git config --global --add safe.directory "${GITHUB_WORKSPACE}"

# Required git configuration.

git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"

# Make the tag.

echo "Filename: ${FILENAME}"
echo "Filename: ${PACKAGE}"

env | sort

cd "${GITHUB_WORKSPACE}" || exit

pwd

ls

# git tag -a "v${GITHUB_REF_NAME}" -m "Go module tag for version ${GITHUB_REF_NAME} by ${GITHUB_ACTOR}" ${GITHUB_WORKFLOW_SHA}
# git push origin --tags
