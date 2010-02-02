#!/bin/bash
# Super duper rudimentary buildscript, since I'd like to toy with not using
# XCode 100% of the time. Will expand soon.
export APP="ARKitDemo"
export BUILD_CONFIGURATION="Release"

cd $APP
rm -fr build
rm -fr Payload
rm -fr "$APP.ipa"

xcodebuild -project $APP.xcodeproj -configuration $BUILD_CONFIGURATION -sdk iphoneos3.1.2 -parallelizeTargets clean build

mkdir -p Payload/Payload
cp -Rp "build/$BUILD_CONFIGURATION-iphoneos/$APP.app" Payload/Payload
ditto -c -k Payload "$APP.ipa"
cp "$APP.ipa" ~/Desktop/

rm -fr build
rm -fr Payload
rm -fr "$APP.ipa"