#!/bin/bash
export GRADLE_OPTS="-Xmx4096m -Dorg.gradle.daemon=false"
gradle "$@"
