ARG BASE_IMAGE="ubuntu:22.04"
FROM $BASE_IMAGE

MAINTAINER 2maz "https://github.com/2maz"

## BEGIN BUILD ARGUMENTS
# Arguments for creation of the Docker imaged,
# passed via --build-arg

# Mandatory arguments
ARG PKG_NAME=
RUN test -n "$PKG_NAME"
ENV PKG_NAME=${PKG_NAME}

# Optional arguments
ARG PKG_BRANCH="master"
ENV PKG_BRANCH=${PKG_BRANCH}

ARG PKG_PULL_REQUEST="false"
ENV PKG_PULL_REQUEST=${PKG_PULL_REQUEST}

ARG SEED_CONFIG=".ci/autoproj-config.yml"
ARG DOCKER_DIR="rock-github-workflow/docker"

ARG BUILDCONF_URL=
ENV BUILDCONF_URL=${BUILDCONF_URL}

ARG BUILDCONF_BRANCH=
ENV BUILDCONF_BRANCH=${BUILDCONF_BRANCH}
## END ARGUMENTS

ADD ${DOCKER_DIR} /scripts

RUN bash /scripts/setup.image.sh docker
USER docker
WORKDIR /home/docker

# Use the existing seed configuration
COPY --chown=docker ${SEED_CONFIG} /scripts/seed-config.yml
RUN bash /scripts/setup.autoproj.sh /scripts/seed-config.yml

