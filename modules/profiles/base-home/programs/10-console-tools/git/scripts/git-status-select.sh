#!/bin/sh

git_status_select() {
  if ! git rev-parse 1>/dev/null 2>&1; then
    echo "Error: Not inside a git repository." >&2
    return 1
  fi

  _sel_raws=$(
    git -c color.ui=always status --short --untracked-files=all |
      fzf --ansi \
        --multi \
        --header "Branch: $(git branch --show-current)" \
        --preview "echo {} | cut -c 4- | xargs git -c color.ui=always diff HEAD --"
  )

  if [ "$_sel_raws" = "" ]; then
    echo "No file was selected." >&2
    return 0
  fi

  _files=$(
    echo "$_sel_raws" |
      sed -E '/^[[:space:]]*[[:alpha:]]?D[[:space:]]+/d' |
      cut -c 4-
  )

  if [ "$_files" = "" ]; then
    echo "There are no valid files." >&2
    return 0
  fi

  echo "$_files" | while IFS="" read -r "file"; do
    echo "'$file'"
  done
}
