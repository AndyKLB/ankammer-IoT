#!/bin/sh

set -e

echo "================================================="
echo "Common script installation: paquets update and curl installation"
echo "================================================="

echo ">>>> Updating Alpine paquets"
apk update
echo ">>>> Update success"

echo ">>>> Installing curl"
apk add curl --no-cache

