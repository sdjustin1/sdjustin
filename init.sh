#!/bin/bash

if [[ !$LUCEE_VERSION ]]; then
	LUCEE_VERSION=6.2.0.321
fi

if [[ !$FUSELESS_VERSION ]]; then
	FUSELESS_VERSION="0.2.0"
fi

if [ -f "jars/lucee-$LUCEE_VERSION.jar" ]; then
	echo "lucee-$LUCEE_VERSION.jar already in jars folder, skipping download"
else 
	#download lucee jar
	echo "Downloading lucee-$LUCEE_VERSION.jar"
	curl --location -o jars/lucee-$LUCEE_VERSION.jar https://cdn.lucee.org/lucee-$LUCEE_VERSION.jar
fi


if [ -f "jars/foundeo-fuseless-$FUSELESS_VERSION.jar" ]; then
	echo "foundeo-fuseless-$FUSELESS_VERSION.jar already in jars folder, skipping download"
else 
	#download lucee jar
	echo "Downloading foundeo-fuseless-$FUSELESS_VERSION.jar"
	curl --location -o jars/foundeo-fuseless-$FUSELESS_VERSION.jar https://github.com/foundeo/fuseless/releases/download/v$FUSELESS_VERSION/foundeo-fuseless-$FUSELESS_VERSION.jar
fi

echo ""
echo "Jars are in place, next make sure you have gradle installed: https://gradle.org/install/"

