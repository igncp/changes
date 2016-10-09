# compile src if there are unstaged changes (modifications or new files)
if [ $(git status --porcelain src | grep -E "^[  ]|\?" | wc -l) -ne "0" ]; then
  npm run build_cjs
fi

npm run build_spec && ./node_modules/.bin/mocha --opts spec/support/default.opts spec-js/observables/fromStringTransform-spec.js
