#!/bin/sh
set -eu

# Input parameters.

INPUT_FILENAME=$1
INPUT_PACKAGE=$2

echo "Requested filename: ${INPUT_FILENAME}"
echo "Requested  package: ${INPUT_PACKAGE}"

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

RELEASE_REPOSITORY_NAME=$(basename ${GITHUB_REPOSITORY})
RELEASE_VERSION=${GITHUB_REF_NAME}
RELEASE_ITERATION="0"
RELEASE_DATE=$(date +%Y-%m-%d)
OUTFILE="${GITHUB_WORKSPACE}/${INPUT_FILENAME}"

# Check if file is already up-to-date.

FIRST_LINE="// ${RELEASE_VERSION}"
EXISTING_FIRST_LINE=$(head -n 1 ${OUTFILE})

if [ "${FIRST_LINE}" = "${EXISTING_FIRST_LINE}" ]; then
    echo "${FIRST_LINE}" is already up to date.
    exit 0
fi

# Write the file.

echo "${FIRST_LINE}"
echo "// Created by make-go-version-file.yaml on $(date)" > ${OUTFILE}
echo "package ${INPUT_PACKAGE}" >> ${OUTFILE}
echo "" >> ${OUTFILE}
echo "var githubDate            string = \"${RELEASE_DATE}\"" >> ${OUTFILE}
echo "var githubIteration       string = \"${RELEASE_ITERATION}\"" >> ${OUTFILE}
echo "var githubRef             string = \"${GITHUB_REF}\"" >> ${OUTFILE}
echo "var githubRefName         string = \"${GITHUB_REF_NAME}\"" >> ${OUTFILE}
echo "var githubRepository      string = \"${GITHUB_REPOSITORY}\"" >> ${OUTFILE}
echo "var githubRepositoryName  string = \"${RELEASE_REPOSITORY_NAME}\"" >> ${OUTFILE}
echo "var githubSha             string = \"${GITHUB_SHA}\"" >> ${OUTFILE}
echo "var githubVersion         string = \"${RELEASE_VERSION}\"" >> ${OUTFILE}
echo "" >> ${OUTFILE}

# Inspect the file.

echo ""
echo "Contents of ${OUTFILE}:"
echo ""
cat ${OUTFILE}

echo ""
git status
echo ">>> Step: 1"

echo "git checkout ${GITHUB_REF}"
git checkout "${GITHUB_REF}"
git status
echo ">>> Step: 2"

git add ${OUTFILE}
git status
echo ">>> Step: 3"

git commit -m "Create ${INPUT_FILENAME} for versioned release: ${RELEASE_VERSION}"
git status
echo ">>> Step: 4"

git push --delete origin "HEAD:${GITHUB_REF}"
git status
echo ">>> Step: 5"



# git tag -a "v${GITHUB_REF_NAME}" -m "Go module tag for version ${GITHUB_REF_NAME} by ${GITHUB_ACTOR}" ${GITHUB_WORKFLOW_SHA}
# git push origin --tags
