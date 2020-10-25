#!/bin/bash

# Docs by jazzy
# https://github.com/realm/jazzy
# ------------------------------

echo "Cleaning old files"
rm -rf docs
echo "Updating Bluetooth git submodule"
git submodule update --remote
echo "Copying assets"
cp ./Bluetooth/README.md .
cp -rf ./Bluetooth/Assets .
echo "Generating documentation"
cd Bluetooth
./generate-docs.sh
rm -rf .swiftpm
rm -rf *.json
rm -rf docs/docsets
cp -rf ./docs ../
cd ../
