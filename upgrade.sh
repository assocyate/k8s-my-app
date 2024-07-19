#!/bin/bash

# Exit on the first error
set -e

# Get the version tag from the script's first argument
VERSION_TAG=$1

# Check if the version tag is provided
if [ -z "$VERSION_TAG" ]; then
  echo "Version tag is required"
  exit 1
fi

# Print out the current version to the console
echo "Releasing version: $VERSION_TAG"

# Define Docker Hub username and repository
DOCKER_USERNAME=darkglobal
DOCKER_REPO=nginx
DOCKER_REPO_VERSION=1.27.0

# Build a new version of the Docker image
#docker build -t $DOCKER_USERNAME/$DOCKER_REPO:$VERSION_TAG .
docker tag $DOCKER_REPO:$DOCKER_REPO_VERSION $DOCKER_USERNAME/$DOCKER_REPO:$VERSION_TAG

# Push the Docker image to Docker Hub
docker push $DOCKER_USERNAME/$DOCKER_REPO:$VERSION_TAG

# Create a temporary folder
TEMP_DIR=$(mktemp -d)

# Clone the GitOps repository
git clone git@github.com:assocyate/k8s-my-app.git $TEMP_DIR

# Navigate to the cloned repository
cd $TEMP_DIR

# Update the image tag in the deployment file
sed -i "s|image: $DOCKER_USERNAME/$DOCKER_REPO:.*|image: $DOCKER_USERNAME/$DOCKER_REPO:$VERSION_TAG|g" my-app/1-deployment.yaml

# Commit the changes to the GitOps repo
git add my-app/1-deployment.yaml
git commit -m "Update image to $VERSION_TAG"

# Push the changes to the remote repository
#git push origin main
git push origin main
# Clean up the temporary folder
rm -rf $TEMP_DIR

echo "Version $VERSION_TAG released and GitOps repo updated successfully."

