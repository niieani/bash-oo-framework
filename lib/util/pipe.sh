# no dependencies

Pipe::Capture() {
  read -r -d '' $1 || true
}

Pipe::CaptureFaithful() {
  IFS= read -r -d '' $1 || true
}
