#!/usr/bin/bash

BUILDCONF_SEED_CONFIG=${1:-seed-config.yaml}
BUILDCONF_BRANCH=${BUILDCONF_BRANCH:-master}
BUILDCONF_URL=${BUILDCONF_URL:-https://github.com/rock-core/buildconf.git}

SCRIPT_DIR=$(dirname $(realpath -L $0))

echo "Using:"
echo "    BUILDCONF_SEED_CONFIG=$BUILDCONF_SEED_CONFIG"
echo "    BUILDCONF_URL=$BUILDCONF_URL"
echo "    BUILDCONF_BRANCH=$BUILDCONF_BRANCH"
echo "    PKG_BRANCH=$PKG_BRANCH"
echo "    PKG_NAME=$PKG_NAME"
echo "    PKG_PULL_REQUEST=$PKG_PULL_REQUEST"

git config --global user.email "rock-users@dfki.de"
git config --global user.name "Rock CI"

mkdir -p rock_test
cd rock_test

wget https://raw.githubusercontent.com/rock-core/autoproj/master/bin/autoproj_bootstrap

export AUTOPROJ_BOOTSTRAP_IGNORE_NONEMPTY_DIR=1
export AUTOPROJ_NONINTERACTIVE=1
ruby autoproj_bootstrap git $BUILDCONF_URL branch=$BUILDCONF_BRANCH --seed-config=$BUILDCONF_SEED_CONFIG

if [ ! -d  $SCRIPT_DIR/overrides.d ]; then
    mkdir -p $SCRIPT_DIR/overrides.d
else
    cp -R $SCRIPT_DIR/overrides.d autoproj/
fi

if [ -e autoproj/overrides.yml ]; then
    mv autoproj/overrides.yml autoproj/overrides.d/00-overrides.yml
fi

echo "Autobuild.displayed_error_line_count='ALL'" >> autoproj/init.rb
sed -i "s#rock\.core#${PKG_NAME}#g" autoproj/manifest
if [ "$PKG_PULL_REQUEST" = "false" ]; then
    echo -e "- ${PKG_NAME}:\n  branch: ${PKG_BRANCH}\n" > autoproj/overrides.d/99_pr_overrides.yml
fi

# Activate testing
source env.sh
autoproj test enable ${PKG_NAME}

## Update
source env.sh
autoproj update
autoproj osdeps

## Check if this a pull request and change to pull request
## accordingly
if [ "$PKG_PULL_REQUEST" != "false" ]; then
    echo "Using pull request: ${PKG_PULL_REQUEST}"
    cd "${PKG_NAME}"
    git fetch autobuild pull/${PKG_PULL_REQUEST}/head:test_pr
    git checkout test_pr
    cd -
    source env.sh
    autoproj osdeps
fi
source env.sh
amake
