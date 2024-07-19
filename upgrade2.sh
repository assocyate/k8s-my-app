#!/bin/bash
set -e
VERSION=$1
echo "Upgrading to version $VERSION"
docker tag nginx:1.27.0 darkglobal/nginx:$VERSION
docker push darkglobal/nginx:$VERSION
TMP_DIR=$(mktemp -d)
git clone https://github.com/assocyate/k8s-my-app.git $TMP_DIR
cd $TMP_DIR/my-app
sed -i "" "s/nginx:v.*/nginx:$VERSION/g" 1-deployment.yaml
git add .
git commit -m "Upgrade to version $VERSION"
git push origin main
rm -rf $TMP_DIR
