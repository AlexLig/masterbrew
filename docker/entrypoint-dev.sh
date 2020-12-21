#!/bin/sh

set -x
set -e

ln -snf /build/node_modules /usr/src/app/node_modules
# npm run start:dev
npm run start:debug