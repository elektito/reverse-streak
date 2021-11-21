#!/bin/sh -e

GODOT=${GODOT:-godot-headless}
EXPORT_DIR=${EXPORT_DIR:-export}

NAME=$(grep config/name project.godot | sed 's#config/name=##' | tr -d '"')
NAME=$(echo $NAME | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

rm -rf $EXPORT_DIR
mkdir $EXPORT_DIR

mkdir $EXPORT_DIR/html5
$GODOT --export "HTML5"
mv $EXPORT_DIR/html5/$NAME.html $EXPORT_DIR/html5/index.html
cd $EXPORT_DIR; zip -r $NAME-web.zip html5/; cd -
rm -r $EXPORT_DIR/html5

$GODOT --export "Linux/X11"

$GODOT --export "Mac OSX"

$GODOT --export "Windows Desktop"
