#!/bin/sh
set -eu

# Input parameters.

INPUT_FILENAME=$1
INPUT_PACKAGE=$2
INPUT_VERSION=$3

echo "Requested filename: ${INPUT_FILENAME}"
echo "Requested package: ${INPUT_PACKAGE}"
echo "Requested package: ${INPUT_VERSION}"

# Apply hotfix for 'fatal: unsafe repository' error.

git config --global --add safe.directory "${GITHUB_WORKSPACE}"

# Required git configuration.

git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"

# Change directory to git repository.

cd "${GITHUB_WORKSPACE}" || exit

# FIXME: Debug information.

env | sort
pwd

# Synthesize variables for file.

RELEASE_REPOSITORY_NAME=${GITHUB_REPOSITORY}
RELEASE_BUILD=${GITHUB_REF_NAME}
RELEASE_ITERATION="0"
OUTFILE="${GITHUB_WORKSPACE}/${INPUT_FILENAME}"

# Write the file.

echo "// Created by make-go-version-file.yaml on $(date)" > ${OUTFILE}
echo "package ${INPUT_PACKAGE}" >> ${OUTFILE}
echo "" >> ${OUTFILE}
echo "var githubRef             string = \"${GITHUB_REF}\"" >> ${OUTFILE}
echo "var githubRefName         string = \"${GITHUB_REF_NAME}\"" >> ${OUTFILE}
echo "var githubRepository      string = \"${GITHUB_REPOSITORY}\"" >> ${OUTFILE}
echo "var githubRepositoryName  string = \"${RELEASE_REPOSITORY_NAME}\"" >> ${OUTFILE}
echo "var githubSha             string = \"${GITHUB_SHA}\"" >> ${OUTFILE}
echo "var githubVersion         string = \"${INPUT_VERSION}\"" >> ${OUTFILE}
echo "var githubIteration       string = \"${RELEASE_BUILD}\"" >> ${OUTFILE}
echo "" >> ${OUTFILE}

# Inspect the file.

echo "\nContents of ${OUTFILE}:\n"
cat ${OUTFILE}
echo "\n"

# git tag -a "v${GITHUB_REF_NAME}" -m "Go module tag for version ${GITHUB_REF_NAME} by ${GITHUB_ACTOR}" ${GITHUB_WORKFLOW_SHA}
# git push origin --tags
