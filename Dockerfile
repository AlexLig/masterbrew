# Development Dockerfile for masterbrew
# Author: Alex Ligkas <alexligk@outlook.com>
#
# This Dockerfile builds a development-ready Docker Image for masterbrew.
# THIS DOCKERFILE SHOULD BE USED ONLY FOR DEVELOPMENT PURPOSES!

# Stage 0: Common ENV variables for all build stages
# https://github.com/moby/moby/issues/37345
FROM node:12.18.3-stretch-slim

# Working directory
ENV WORKDIR_APP="/usr/src/app"
ENV WORKDIR_NODE_MODULES="/build"
# Port on which masterbrew will be exported
ENV PORT_EXPOSE="8080"
# Port on which masterbrew will be exported when debbuging
ENV DEBUG_PORT_EXPOSE="9229"

# User and group
ENV RUN_USER="masterbrew"
ENV RUN_GROUP="masterbrew"
# Run in development environment
ENV NODE_ENV="development"

# Mitigate `Error: spawn ps ENOENT` errors on file reloads
# stretch-slim-based images do not include procps
RUN apt-get update && apt-get install -y procps

# Directory to store node dependencies
WORKDIR $WORKDIR_NODE_MODULES

# Create node_modules directory. This is necessary to run npm
# as an unprivileged user, since we are going to chown it afterwards.
RUN mkdir "$WORKDIR_NODE_MODULES/node_modules"
RUN mkdir "$WORKDIR_APP"

# Include package files. Do not include all source code
# to avoid triggering builds on each code change.
COPY package*.json ./
RUN chown -R "$RUN_USER:$RUN_GROUP" "$WORKDIR_NODE_MODULES"
RUN chown -R "$RUN_USER:$RUN_GROUP" "$WORKDIR_APP"

# Add entrypoint script
# * Creates a symlink in $WORKDIR_APP to node_modules directory
COPY "docker/entrypoint-dev.sh" "/entrypoint-dev.sh"

# Run build as unprivileged user for security reasons,
# and to avoid additional chown operations that take time.
USER $RUN_USER

# Install all dependencies
RUN npm install
# Clean npm caches
RUN npm cache clean --force

# Use a clean directory
WORKDIR $WORKDIR_APP

# Port to expose masterbrew
EXPOSE $PORT_EXPOSE

# Port to expose masterbrew when debugging to attach debugger
EXPOSE $DEBUG_PORT_EXPOSE

# Run application
# Requires source code to be mounted under /usr/src/app
ENTRYPOINT ["/entrypoint-dev.sh"]
