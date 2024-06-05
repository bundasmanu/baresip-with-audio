#!/bin/bash

set -e

# Use the provided argument or the default Macbook Speakers device
device="${1:-"MacBook Pro Speakers"}"

# Use the provided argument or the default location to pulse default.pa file
default_file_path="${2:-"/opt/homebrew/etc/pulse/default.pa"}"

echo "Executing script, please wait until stops..."

## install pulseaudio
HOMEBREW_NO_AUTO_UPDATE=1 brew install pulseaudio

## start pulseaudio
brew services start pulseaudio

## Use pactl list sinks and parse the output to find the sink number with the desired description
sink_number=$(pactl list sinks | awk -v device="$device" '
    $1 == "Sink" && $2 ~ /^#/{ sink=$2 }
    $1 == "Description:" && $0 ~ device { print sink }
')

## Get only the sink number of the MacBook Pro Speakers device
sink_number=${sink_number#\#}

echo "$sink_number"

## now set the default sink device
pactl set-default-sink $sink_number

## Resolve the symbolic link to get the actual file
resolved_file_path=$(readlink "$default_file_path")
if [ -z "$resolved_file_path" ]; then
    resolved_file_path="$default_file_path"
else
    resolved_file_path=$(dirname "$default_file_path")/$resolved_file_path
fi

## now update default.pa file, to allow TCP connections without authentication
if ! grep -q "^load-module module-native-protocol-tcp auth-anonymous=1" "$resolved_file_path"; then
    sed -i.bak -e '/^#load-module module-native-protocol-tcp/a\
load-module module-native-protocol-tcp auth-anonymous=1\
' "$resolved_file_path"
fi

## restart pulseaudio
brew services restart pulseaudio
