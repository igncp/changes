cd ~/repository

if [ ! -d node_modules/protractor/selenium ]; then
  ./node_modules/protractor/bin/webdriver-manager update
fi

npm run perf
