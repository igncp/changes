# currently all tests failing (with protractor 2.X and 3.X)
# due to a JS error

export DISPLAY=:10
sudo Xvfb :10 -screen 0 1366x768x24 -ac &
cd ~/repository

if [ ! -d node_modules/protractor/selenium ]; then
  ./node_modules/protractor/bin/webdriver-manager update
fi

npm run perf
