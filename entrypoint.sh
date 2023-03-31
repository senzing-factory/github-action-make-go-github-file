#!/bin/sh
set -eu

# Function: write_file()

write_file() {
    echo "${FIRST_LINE}"                                                      > ${OUTFILE}
    echo "// Created by make-go-version-file.yaml on $(date)"                >> ${OUTFILE}
    echo "package ${INPUT_PACKAGE}"                                          >> ${OUTFILE}
    echo ""                                                                  >> ${OUTFILE}
    echo "var githubDate            string = \"${RELEASE_DATE}\""            >> ${OUTFILE}
    echo "var githubIteration       string = \"${RELEASE_ITERATION}\""       >> ${OUTFILE}
    echo "var githubRef             string = \"${GITHUB_REF}\""              >> ${OUTFILE}
    echo "var githubRefName         string = \"${GITHUB_REF_NAME}\""         >> ${OUTFILE}
    echo "var githubRepository      string = \"${GITHUB_REPOSITORY}\""       >> ${OUTFILE}
    echo "var githubRepositoryName  string = \"${RELEASE_REPOSITORY_NAME}\"" >> ${OUTFILE}
    echo "var githubSha             string = \"${GITHUB_SHA}\""              >> ${OUTFILE}
    echo "var githubVersion         string = \"${RELEASE_VERSION}\""         >> ${OUTFILE}
    echo ""                                                                  >> ${OUTFILE}
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

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
NEW_MAIN_BRANCH_NAME="make-go-version-file.yaml/main/${RELEASE_VERSION}"
NEW_TAG_BRANCH_NAME="make-go-version-file.yaml/tag/${RELEASE_VERSION}"

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
# Update the tagged version.
#------------------------------------------------------------------------------

# Get information from new release then delete the release.

RELEASE_BODY=$(gh release view --json body | jq -r .body)
RELEASE_NAME=$(gh release view --json name | jq -r .name)
RELEASE_TAGNAME=$(gh release view --json tagName | jq -r .tagName)

echo "   RELEASE_BODY: ${RELEASE_BODY}"
echo "   RELEASE_NAME: ${RELEASE_NAME}"
echo "RELEASE_TAGNAME: ${RELEASE_TAGNAME}"

echo ">>>>>>>> git tag --list"
git tag --list

echo ">>>>>>>> git branch --list"
git branch --list

echo ">>>>>>>> gh release delete \"${RELEASE_VERSION}\" --cleanup-tag"
gh release delete \
    "${RELEASE_VERSION}" \
    --cleanup-tag \
    --yes

echo ">>>>>>>> git tag --list"
git tag --list

echo ">>>>>>>> git branch --list"
git branch --list

# Make a new branch.

echo ">>>>>>>> git branch \"${NEW_TAG_BRANCH_NAME}\" \"${GITHUB_REF_NAME}\""
git branch "${NEW_TAG_BRANCH_NAME}" "${GITHUB_REF_NAME}"
git status

echo ">>>>>>>> git branch --list"
git branch --list

echo ">>>>>>>> git checkout \"${NEW_TAG_BRANCH_NAME}\""
git checkout "${NEW_TAG_BRANCH_NAME}"
git status

# Write the file into the branch.

write_file

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

echo ">>>>>>>> git push"
git push
git status

# Delete and recreate tag locally.

echo ">>>>>>>> git tag --delete \"${GITHUB_REF_NAME}\""
git tag --delete "${GITHUB_REF_NAME}"
git status

echo ">>>>>>>> git tag \"${GITHUB_REF_NAME}\""
git tag "${GITHUB_REF_NAME}"
git status

# Delete and recreate tag remotely.

#echo ">>>>>>>> git push origin \":${GITHUB_REF_NAME}\""
#git push origin ":${GITHUB_REF_NAME}"
#git status

echo ">>>>>>>> git push origin \"${GITHUB_REF_NAME}\""
git push origin "${GITHUB_REF_NAME}"
git status










echo ">>>>>>>> gh release view"
gh release view

# Replace tag on GitHub.

#echo ">>>>>>>> git push origin \":${GITHUB_REF}\"  (to delete tag on origin)"
#git push origin ":${GITHUB_REF}"
#git status

#echo ">>>>>>>> git tag --force --annotate \"${GITHUB_REF_NAME}\" --message \"Updated ${INPUT_FILENAME} for ${GITHUB_REF_NAME}.\""
#git tag --force --annotate "${GITHUB_REF_NAME}" --message "Updated ${INPUT_FILENAME} for ${GITHUB_REF_NAME}."
#git status

#echo ">>>>>>>> git push origin \"${GITHUB_REF}:${GITHUB_REF}\""
#git push origin "HEAD:${GITHUB_REF}"#
#git status


echo ">>>>>>>> gh release create \"${RELEASE_VERSION}\" --latest --target \"${GITHUB_REF_NAME}\" --notes \"${RELEASE_BODY}\""
gh release create \
    "${RELEASE_VERSION}" \
    --latest \
    --target "${GITHUB_REF_NAME}" \
    --notes "${RELEASE_BODY}"

# git tag -a "v${GITHUB_REF_NAME}" -m "Go module tag for version ${GITHUB_REF_NAME} by ${GITHUB_ACTOR}" ${GITHUB_WORKFLOW_SHA}
# git push origin --tags

echo ">>>>>>>> Done"

exit 0   # Debug

#------------------------------------------------------------------------------
# Make a Pull Request for main branch.
#------------------------------------------------------------------------------

# Make a new branch.

echo ">>>>>>>> git checkout -b \"${NEW_MAIN_BRANCH_NAME}\""
git checkout -b "${NEW_MAIN_BRANCH_NAME}"
git status

# Write the file into the branch.

write_file

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

echo ">>>>>>>> git push --set-upstream origin \"${NEW_MAIN_BRANCH_NAME}\""
git push --set-upstream origin "${NEW_MAIN_BRANCH_NAME}"
git status

# Create a Pull Request for the branch.

echo ">>>>>>>> gh pr create --head \"${NEW_MAIN_BRANCH_NAME}\" --title \"make-go-version-file.yaml updated ${INPUT_FILENAME} for versioned release: ${RELEASE_VERSION}\"  --body \"make-go-version-file.yaml updated ${INPUT_FILENAME} for versioned release: ${RELEASE_VERSION}\""
gh pr create \
    --head "${NEW_MAIN_BRANCH_NAME}" \
    --title "make-go-version-file.yaml: ${INPUT_FILENAME}@${RELEASE_VERSION}" \
    --body "make-go-version-file.yaml updated ${INPUT_FILENAME} for versioned release: ${RELEASE_VERSION}"

echo ">>>>>>>> Done"

