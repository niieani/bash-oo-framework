#!/usr/bin/env bash

## BOOTSTRAP ##
#source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/oo-framework.sh"

source <(VERSION=1.0.0; URL="https://github.com/niieani/bash-oo-framework/releases/download/$VERSION/oo-framework.sh"; RETRIES=3; hash curl 2>/dev/null && curl -sL --retry $RETRIES "$URL" || wget -t $RETRIES -O - -o /dev/null "$URL" || echo "echo 'An error occured while downloading the framework.' && exit 1")

echo Works.

yooko