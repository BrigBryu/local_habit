#!/bin/bash
# Convenience script to run Flutter commands with FVM
export PATH="$PATH:$HOME/.pub-cache/bin"
fvm flutter "$@"