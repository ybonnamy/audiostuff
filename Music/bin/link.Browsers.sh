#!/bin/bash

# obsoleted by .config/pipewire/pipewire-pulse.conf.d/*
# https://gitlab.freedesktop.org/pipewire/wireplumber/-/issues/785

# wait for Chromium or Firefox streams
while true; do
    chromium_output=$(pw-dump | jq -r '.[] | select(.info.props."application.name" == "Chromium") | .id' | head -n 1)
    sinkchromium=$(pw-dump | jq -r '.[] | select(.info.props."node.name" == "SinkChromium") | .id' | head -n 1)

    if [ -n "$chromium_output" ] && [ -n "$sinkchromium=" ]; then
        pw-link "Chromium:output_FL" "SinkChromium:playback_FL"
        pw-link "Chromium:output_FR" "SinkChromium:playback_FR"
	pw-link -d "Chromium:output_FL" "SinkA:playback_FL"
        pw-link -d "Chromium:output_FR" "SinkA:playback_FR"
    fi

    firefox_output=$(pw-dump | jq -r '.[] | select(.info.props."application.name" == "Firefox") | .id' | head -n 1)
    sinkfirefox=$(pw-dump | jq -r '.[] | select(.info.props."node.name" == "SinkFirefox") | .id' | head -n 1)

    if [ -n "$firefox_output=" ] && [ -n "$sinkfirefox" ]; then
        pw-link "Firefox:output_FL" "SinkFirefox:playback_FL"
        pw-link "Firefox:output_FR" "SinkFirefox:playback_FR"
	pw-link -d "Firefox:output_FL" "SinkA:playback_FL"
        pw-link -d "Firefox Chrome:output_FR" "SinkA:playback_FR"
    fi

    googlechrome_output=$(pw-dump | jq -r '.[] | select(.info.props."application.name" == "Google Chrome") | .id' | head -n 1)
    sinkgooglechrome_output==$(pw-dump | jq -r '.[] | select(.info.props."node.name" == "SinkGoogleChrome") | .id' | head -n 1)

    if [ -n "$googlechrome_output" ] && [ -n "$sinkgooglechrome_output" ]; then
        pw-link "Google Chrome:output_FL" "SinkGoogleChrome:playback_FL"
        pw-link "Google Chrome:output_FR" "SinkGoogleChrome:playback_FR"
	pw-link -d "Google Chrome:output_FL" "SinkA:playback_FL"
        pw-link -d "Google Chrome:output_FR" "SinkA:playback_FR"
    fi

    sleep 1
done

