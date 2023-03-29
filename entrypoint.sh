#!/bin/sh
set -eu

# Input parameters.

INPUT_FILENAME=$1
INPUT_PACKAGE=$2

echo "Requested filename: ${INPUT_FILENAME}"
echo "Requested package: ${INPUT_PACKAGE}"

# Apply hotfix for 'fatal: unsafe repository' error.

git config --global --add safe.directory "${GITHUB_WORKSPACE}"

# Required git configuration.

git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"

# Make the tag.

env | sort

cd "${GITHUB_WORKSPACE}" || exit

pwd

# Synthesize variables for file.

RELEASE_REPOSITORY=${GITHUB_REPOSITORY}
RELEASE_BUILD=${GITHUB_REF_NAME}
RELEASE_ITERATION="0"
OUTFILE="${GITHUB_WORKSPACE}/${INPUT_FILENAME}"

# Write the file.

echo "Created by make-go-version-file.yaml on $(date)" > ${OUTFILE}
echo "package ${INPUT_PACKAGE}" >> ${OUTFILE}
echo "" >> ${OUTFILE}
echo "var githubRef ${GITHUB_REF}" >> ${OUTFILE}
echo "var githubRefName ${GITHUB_REF_NAME}" >> ${OUTFILE}
echo "var githubRepository ${GITHUB_REPOSITORY}" >> ${OUTFILE}
echo "var githubSha ${GITHUB_SHA}" >> ${OUTFILE}
echo "var githubVersion ${RELEASE_BUILD}" >> ${OUTFILE}
echo "var githubIteration ${RELEASE_BUILD}" >> ${OUTFILE}
echo "" >> ${OUTFILE}

# Inspect the file.

cat ${OUTFILE}

# git tag -a "v${GITHUB_REF_NAME}" -m "Go module tag for version ${GITHUB_REF_NAME} by ${GITHUB_ACTOR}" ${GITHUB_WORKFLOW_SHA}
# git push origin --tags
