#!/bin/bash
STACK_DIR="/home2/yangyq/qiyang-imx6-android6.0-sdk/yyy"
COMMITS_DIR="$STACK_DIR/commits"

if [ ! -d "$STACK_DIR" ]; then
  mkdir -p "$STACK_DIR"
fi

if [ ! -d "$COMMITS_DIR" ]; then
  mkdir -p "$COMMITS_DIR"
fi

push() {
  for file in "$@"; do
    if [ -f "$file" ]; then
      cp "$file" "$STACK_DIR/"
      echo "$(realpath -- "$file")" >> "$STACK_DIR/stack.list"
    else
      echo "File $file does not exist."
    fi
  done
}

pop() {
  if [ ! -f "$STACK_DIR/stack.list" ] || [ ! -s "$STACK_DIR/stack.list" ]; then
    echo "Stack is empty."
    return
  fi

  last_file=$(tail -n 1 "$STACK_DIR/stack.list")
  if [ -f "$STACK_DIR/$(basename -- "$last_file")" ]; then
    mv -- "$STACK_DIR/$(basename -- "$last_file")" "$(dirname -- "$last_file")/"
    sed -i '$ d' "$STACK_DIR/stack.list"
    echo "File $(basename -- "$last_file") popped from stack."
  else
    echo "Error: File $(basename -- "$last_file") not found in stack."
  fi
}

drop() {
  if [ ! -f "$STACK_DIR/stack.list" ] || [ ! -s "$STACK_DIR/stack.list" ]; then
    echo "Stack is empty."
    return
  fi

  last_file=$(tail -n 1 "$STACK_DIR/stack.list")
  if [ -f "$STACK_DIR/$(basename -- "$last_file")" ]; then
    rm -- "$STACK_DIR/$(basename -- "$last_file")"
    sed -i '$ d' "$STACK_DIR/stack.list"
    echo "File $(basename -- "$last_file") dropped from stack."
  else
    echo "Error: File $(basename -- "$last_file") not found in stack."
  fi
}

commit() {
  commit_id=$(date +%s)
  commit_dir="$COMMITS_DIR/$commit_id"
  mkdir "$commit_dir"
  cp "$STACK_DIR"/* "$commit_dir/"
  echo "$2" > "$commit_dir/message.txt"
  echo "Commit $commit_id created with message: $2"
}

checkout() {
  commit_id="$1"
  file_name="$2"
  if [ ! -d "$COMMITS_DIR/$commit_id" ]; then
    echo "Commit $commit_id does not exist."
    return
  fi

  if [ ! -f "$COMMITS_DIR/$commit_id/$file_name" ]; then
    echo "File $file_name does not exist in commit $commit_id."
    return
  fi

  cp "$COMMITS_DIR/$commit_id/$file_name" .
  echo "File $file_name checked out from commit $commit_id."
}
list-commits() {
  echo "Available commits:"
  for commit_dir in "$COMMITS_DIR"/*; do
    commit_id=$(basename "$commit_dir")
    message=$(cat "$commit_dir/message.txt")
    echo "$commit_id - $message"
  done
}

show-commit() {
  commit_id="$1"
  commit_dir="$COMMITS_DIR/$commit_id"
  if [ ! -d "$commit_dir" ]; then
    echo "Commit $commit_id does not exist."
    return
  fi
  echo "Commit $commit_id:"
  echo "Message: $(cat "$commit_dir/message.txt")"
  echo "Files:"
  ls "$commit_dir" | grep -v 'message.txt'
}

case "$1" in
  push)
    shift
    push "$@"
    ;;
  pop)
    pop
    ;;
  drop)
    drop
    ;;
  commit)
    shift
    commit "$(date +%s)" "$@"
    ;;
  checkout)
    checkout "$2" "$3"
    ;;
  list-commits)
    list-commits
    ;;
  show-commit)
    show-commit "$2"
    ;;
  *)
    echo "Usage: $0 {push|pop|drop|commit|checkout|list-commits|show-commit}"
    ;;
esac
