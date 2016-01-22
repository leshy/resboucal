#!/bin/sh
echo "browserifying..."

node node_modules/browserify/bin/cmd.js -t debowerify -t ejsify clientside.js  -o static/js/bundle.js

echo "done: static/js/bundle.js"

if [ ! -z "$1" ]; then
  echo "packing..."
  node node_modules/uglify-js/bin/uglifyjs static/js/bundle.js \
    -o static/js/bundle.min.js_ \
    -c "dead_code=true,evaluate=true,join_vars=true,unused=true,drop_console=true" \
    -m "toplevel,sort"

  mv static/js/bundle.min.js_ static/js/bundle.min.js && rm static/js/bundle.js
  echo "done: static/js/bundle.min.js"
    
  node_modules/uglifycss/uglifycss static/css/main.css > static/css/main.min.css_
  mv static/css/main.min.css_ static/css/main.min.css
  echo "done: static/css/main.min.css"

  
fi

