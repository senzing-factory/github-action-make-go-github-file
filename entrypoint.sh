#!/bin/sh
set -eu

# Input parameters.

INPUT_FILENAME=$1
INPUT_PACKAGE=$2

echo "  Input parameters: $@"
echo "Requested filename: ${INPUT_FILENAME}"
echo "Requested  package: ${INPUT_PACKAGE}"

# Apply hotfix for 'fatal: unsafe repository' error.

git config --global --add safe.directory "${GITHUB_WORKSPACE}"

# Required git configuration.

git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"

# Change directory to git repository.

cd "${GITHUB_WORKSPACE}" || exit

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
    EXISTING_FIRST_LINE=$(head -n 1 ${OUTFILE})
    if [ "${FIRST_LINE}" = "${EXISTING_FIRST_LINE}" ]; then
        echo "${OUTFILE} is up to date. No changes needed."
        exit 0
    fi
fi

#------------------------------------------------------------------------------
# Make a Pull Request for main branch.
#------------------------------------------------------------------------------

# Make a new branch.

echo ">>>>>>>> git checkout -b \"${NEW_BRANCH_NAME}\""
git checkout -b "${NEW_BRANCH_NAME}"
git status

# Write the file into the branch.

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

# Commit the file to the branch and push branch to origin.

echo ">>>>>>>> git add ${OUTFILE}"
git add ${OUTFILE}
git status

echo ">>>>>>>> git commit -m \"make-go-version-file.yaml updated ${INPUT_FILENAME} for versioned release: ${RELEASE_VERSION}\""
git commit -m "make-go-version-file.yaml updated ${INPUT_FILENAME} for versioned release: ${RELEASE_VERSION}"
git status

echo ">>>>>>>> git push --set-upstream origin \"${NEW_BRANCH_NAME}\""
git push --set-upstream origin "${NEW_BRANCH_NAME}"
git status

# Create a Pull Request for the branch.

echo ">>>>>>>> gh pr create --head \"${NEW_BRANCH_NAME}\" --title \"make-go-version-file.yaml updated ${INPUT_FILENAME} for versioned release: ${RELEASE_VERSION}\"  --body \"make-go-version-file.yaml updated ${INPUT_FILENAME} for versioned release: ${RELEASE_VERSION}\""
gh pr create \
    --head "${NEW_BRANCH_NAME}" \
    --title "make-go-version-file.yaml: ${INPUT_FILENAME}@${RELEASE_VERSION}" \
    --body "make-go-version-file.yaml updated ${INPUT_FILENAME} for versioned release: ${RELEASE_VERSION}"

#------------------------------------------------------------------------------
# Update the tagged version.
#------------------------------------------------------------------------------

# Checkout tag.

echo ">>>>>>>> git checkout -b \"${GITHUB_REF}\""
git checkout -b "${GITHUB_REF}"
git status

# Write the file into the branch.

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

# Replace tag on GitHub.

echo ">>>>>>>> git push origin \":${GITHUB_REF}\"  (to delete tag on origin)"
git push origin ":${GITHUB_REF}"
git status

echo ">>>>>>>> git tag --force --annotate \"${GITHUB_REF_NAME}\" --message \"Updated ${INPUT_FILENAME} for ${GITHUB_REF_NAME}.\""
git tag --force --annotate "${GITHUB_REF_NAME}" --message "Updated ${INPUT_FILENAME} for ${GITHUB_REF_NAME}."
git status

echo ">>>>>>>> git push origin --tags \"${GITHUB_REF_NAME}\""
git push origin --tags "${GITHUB_REF_NAME}"
git status

# git tag -a "v${GITHUB_REF_NAME}" -m "Go module tag for version ${GITHUB_REF_NAME} by ${GITHUB_ACTOR}" ${GITHUB_WORKFLOW_SHA}
# git push origin --tags

echo ">>>>>>>> Done"
