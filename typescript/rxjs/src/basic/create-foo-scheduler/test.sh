# compile if there are unstaged changes (modifications or new files)
compile_if_changes() {
  DIR=$1
  CMD=$2

  if [ $(git status --porcelain $DIR | grep -E "^[  ]|^\?|^AM" | wc -l) -ne "0" ]; then
    eval "$CMD"
  fi
}

compile_if_changes src "npm run build_cjs"
compile_if_changes spec "npm run build_spec"

./node_modules/.bin/mocha --opts spec/support/default.opts spec-js/schedulers/FooScheduler-spec.js
