#!/bin/bash

# Ensure folders are existing
if [ ! -d public/js ]; then
	mkdir public/js
else
	find -L public/js -type l -exec rm {} \;
fi

if [ ! -d public/css ]; then
	mkdir public/css
else
	find -L public/css -type l -exec rm {} \;
fi

if [ ! -d public/flags ]; then
	mkdir public/flags
else
	find -L public/flags -type l -exec rm {} \;
fi

if [ ! -d public/views/dialogs ]; then
	mkdir -p public/views/dialogs
else
	find -L public/views -type l -exec rm {} \;
fi

if [ ! -d public/views/partials ]; then
	mkdir -p public/views/partials
else
	find -L public/views -type l -exec rm {} \;
fi

if [ ! -d public/img ]; then
	mkdir public/img
else
	find -L public/img -type l -exec rm {} \;
fi

if [ ! -d public/js/copilot ]; then
	mkdir -p public/js/copilot
fi
find public/js/copilot -maxdepth 1 -type l -exec rm {} \; 2>/dev/null
rm -f public/js/copilot/CopilotWidget.js

if [ ! -d public/css/copilot ]; then
	mkdir -p public/css/copilot
fi
find public/css/copilot -maxdepth 1 -type l -exec rm {} \; 2>/dev/null
rm -f public/css/copilot/copilot.css

# Link modules resources. TODO: Replace with Grunt tasks to minify the JS and CSS.
cd public/views/ && find ../../node_modules/ng_client/views -name "*.html" -exec ln -s {} \; 2>/dev/null
cd dialogs/ && find ../../../node_modules/ng_client/views/dialogs -maxdepth 1 -name "*.html" -exec ln -s {} \; 2>/dev/null
cd ../../js/ && find ../../node_modules/ng_client/src -name "*" -exec ln -s {} \; 2>/dev/null
cd ../css/ && find ../../node_modules/ng_client/css -name "*" -exec ln -s {} \; 2>/dev/null
cd ../img/ && find ../../node_modules/ng_client/img -name "*" -exec ln -s {} \; 2>/dev/null
cd ../flags/ && find ../../node_modules/ng_client/node_modules/flag-icons/flags -mindepth 1 -type d -exec ln -s {} \; 2>/dev/null

cd ../js/
mkdir -p anr
cd anr && find ../../../node_modules/ng_anr/src -type f -name "*" -exec ln -s {} \; 2>/dev/null
cd ..

cd ../views/
mkdir -p anr
cd anr && find ../../../node_modules/ng_anr/views -type f -maxdepth 1 -name "*" -exec ln -s {} \; 2>/dev/null
cd ..

cd ../css/
mkdir -p anr
cd anr && find ../../../node_modules/ng_anr/css -type f -maxdepth 1 -name "*" -exec ln -s {} \; 2>/dev/null
cd ..

cd ../..

if [ -d vendor/monarc/copilot/public/dist ]; then
	ln -s ../../../vendor/monarc/copilot/public/dist/copilot-widget.js public/js/copilot/CopilotWidget.js 2>/dev/null
	ln -s ../../../vendor/monarc/copilot/public/dist/copilot.css public/css/copilot/copilot.css 2>/dev/null
elif [ -d vendor/monarc/copilot/public/src ]; then
	ln -s ../../../vendor/monarc/copilot/public/src/copilot-widget.js public/js/copilot/CopilotWidget.js 2>/dev/null
fi

pushd node_modules/ng_client
grunt concat
popd
