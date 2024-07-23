#!/usr/bin/bash

SEED_CONFIG=${1:-seed-config.yaml}
BUILDCONF_BRANCH=${2:-master}

git config --global user.email "rock-users@dfki.de"
git config --global user.name "Rock CI"


mkdir -p rock_test
cd rock_test

wget https://raw.githubusercontent.com/rock-core/autoproj/master/bin/autoproj_bootstrap

export AUTOPROJ_BOOTSTRAP_IGNORE_NONEMPTY_DIR=1
export AUTOPROJ_NONINTERACTIVE=1
ruby autoproj_bootstrap git https://github.com/rock-core/buildconf.git branch=$BUILDCONF_BRANCH --seed-config=$SEED_CONFIG

sed -i "s#rock\.core#${PKG_NAME}#g" autoproj/manifest
if [ "$PKG_PULL_REQUEST" = "false" ]; then \
    echo "Using branch: ${PKG_BRANCH}"; \
    echo "overrides:\n  - ${PKG_NAME}:\n    branch: ${PKG_BRANCH}" > autoproj/overrides.yml; \
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
if [ "$PKG_PULL_REQUEST" != "false" ]; then \
    echo "Using pull request: ${PKG_PULL_REQUEST}";
    cd "${PKG_NAME}";
    git fetch autobuild pull/${PKG_PULL_REQUEST}/head:test_pr;
    git checkout test_pr;
    cd -;
    source env.sh;
    autoproj osdeps;
fi
source env.sh
amake
