#!/usr/bin/env bash

TOP_DIR=$(pwd)
echo "----TOP_DIR----"
echo $TOP_DIR
 
PRODUCT_NAME=MyFinder
CONFIGURATION=Release
BUILD_SCHEME=${PRODUCT_NAME}\Dmg

# 通过xcodeproj管理的项目
CLEAN_COMMAND="xcodebuild -project ${PRODUCT_NAME}.xcodeproj -scheme ${BUILD_SCHEME} -configuration ${CONFIGURATION} -sdk macosx"
BUILD_COMMAND="xcodebuild -project ${PRODUCT_NAME}.xcodeproj -scheme ${BUILD_SCHEME} -configuration ${CONFIGURATION} -sdk macosx"

$CLEAN_COMMAND clean 
$BUILD_COMMAND
 
echo "Build end"




