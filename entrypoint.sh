#!/bin/sh

set -e

export HOME="/github/workspace"
export NVM_DIR="/github/workspace/nvm"
export WRANGLER_HOME="/github/workspace"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | bash

# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

mkdir -p "$HOME/.wrangler"
chmod -R 770 "$HOME/.wrangler"

if [ -n "$INPUT_APITOKEN" ]
then
  echo "Using API token authentication"
  export CF_API_TOKEN="$INPUT_APITOKEN"
fi

if [ -n "$INPUT_APIKEY" ] || [ -n "$INPUT_EMAIL" ]
then
  echo "Using legacy email and API key authentication"
  export CF_EMAIL="$INPUT_EMAIL"
  export CF_API_KEY="$INPUT_APIKEY"
fi

if [ -z "$INPUT_APITOKEN" ] && [ -z "$INPUT_EMAIL" ] && [ -z "$INPUT_APIKEY" ]
then
  >&2 echo "Unable to find authentication details. Please pass in an 'apiToken' as an input to the action, or a legacy 'apiKey' and 'email'."
  exit 1
fi

if [ -z "$INPUT_WRANGLERVERSION" ]
then
  npm i @cloudflare/wrangler -g
else
  npm i "@cloudflare/wrangler@$INPUT_WRANGLERVERSION" -g
fi

if [ -n "$INPUT_WORKINGDIRECTORY" ]
then
  cd "$INPUT_WORKINGDIRECTORY"
fi

if [ -z "$INPUT_ENVIRONMENT" ]
then
  wrangler publish
else
  wrangler publish -e "$INPUT_ENVIRONMENT"
fi

if [ -n "$INPUT_WORKINGDIRECTORY" ]
then
  cd $HOME
fi
