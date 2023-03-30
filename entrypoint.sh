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

# Synthesize variables.

RELEASE_REPOSITORY_NAME=$(basename ${GITHUB_REPOSITORY})
RELEASE_VERSION=${GITHUB_REF_NAME}
RELEASE_ITERATION="0"
RELEASE_DATE=$(date +%Y-%m-%d)
OUTFILE="${GITHUB_WORKSPACE}/${INPUT_FILENAME}"
NEW_BRANCH_NAME="make-go-version-file.yaml/${RELEASE_VERSION}"

# Check if file is already up-to-date.

FIRST_LINE="// ${RELEASE_VERSION}"

if [ -f ${OUTFILE} ]; then
    echo ">>> Step: 0a"
    echo "$(head -n 1 ${OUTFILE})"
    EXISTING_FIRST_LINE=$(head -n 1 ${OUTFILE})
    echo ">>> Step: 0b"
    if [ "${FIRST_LINE}" = "${EXISTING_FIRST_LINE}" ]; then
        echo "${FIRST_LINE}" is already up to date.
        exit 0
    fi
    echo ">>> Step: 0c"
fi

#------------------------------------------------------------------------------
# Make a Pull Request for main branch.
#------------------------------------------------------------------------------

echo ">>> git checkout -b \"${NEW_BRANCH_NAME}\""
git checkout -b "${NEW_BRANCH_NAME}"
git status

# Write the file.

echo "${FIRST_LINE}" > ${OUTFILE}
echo "// Created by make-go-version-file.yaml on $(date)" >> ${OUTFILE}
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

# Delete tag on GitHub.  Similar to --delete.

#echo "git push origin :${GITHUB_REF}"
#git push origin ":${GITHUB_REF}"
#git status
#echo ">>> Step: 2"

echo ">>> git add ${OUTFILE}"
git add ${OUTFILE}
git status

echo ">>> git commit -m \"make-go-version-file.yaml updated ${INPUT_FILENAME} for versioned release: ${RELEASE_VERSION}\""
git commit -m "make-go-version-file.yaml updated ${INPUT_FILENAME} for versioned release: ${RELEASE_VERSION}"
git status

echo ">>> git push --set-upstream origin \"${NEW_BRANCH_NAME}\""
git push --set-upstream origin "${NEW_BRANCH_NAME}"
git status

echo ">>> gh pr create --head \"${NEW_BRANCH_NAME}\" --title \"make-go-version-file.yaml updated ${INPUT_FILENAME} for versioned release: ${RELEASE_VERSION}\""
gh pr create \
    --head "${NEW_BRANCH_NAME}" \
    --title "make-go-version-file.yaml updated ${INPUT_FILENAME} for versioned release: ${RELEASE_VERSION}"

#echo "git tag --force --annotate \"${GITHUB_REF_NAME}\" --message \"Updated ${INPUT_FILENAME} for ${GITHUB_REF_NAME}.\""
#git tag --force --annotate "${GITHUB_REF_NAME}" --message "Updated ${INPUT_FILENAME} for ${GITHUB_REF_NAME}."
#git status
#echo ">>> Step: 6"

#echo "git push origin --tags"
#git push origin --tags
#git status
#echo ">>> Step: 7"



# git tag -a "v${GITHUB_REF_NAME}" -m "Go module tag for version ${GITHUB_REF_NAME} by ${GITHUB_ACTOR}" ${GITHUB_WORKFLOW_SHA}
# git push origin --tags

echo ">>> Done"
