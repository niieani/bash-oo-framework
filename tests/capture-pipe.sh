# shopt -s lastpipe

capturePipe() {
  read -r -d '' $1
}

capturePipeFaithful() {
  IFS= read -r -d '' $1
}

# declare -g awesome
# declare awesome
printf "test1234\n\ntest999\n\n" | capturePipe awesome
# echo "test999" | capturePipe awesome
echo $awesome
declare -p awesome