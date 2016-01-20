#!/usr/bin/env bash

shopt -s lastpipe

Pipe::Capture() {
  read -r -d '' $1
}

# shopt -s expand_aliases
# alias Pipe::Capture="read -r -d ''"

Pipe::CaptureFaithful() {
  IFS= read -r -d '' $1
}

# declare -g awesome
# declare awesome=
printf "test1234\n\ntest999\n\n" | Pipe::Capture awesome
# echo "test999" | Pipe::Capture awesome
echo $awesome
declare -p awesome