#!/usr/bin/env bash

## Script to take a screenshot in background.
## nohup sh "$PWD"/hidenScreenShots/script.sh &


SCRIPT_HOME="$HOME/result"
TIME_DELAY='15'


if [[ -d "$SCRIPT_HOME" ]]; then
  while [[ true ]]; do
    screencapture -x "$SCRIPT_HOME/$(date '+%Y-%m-%d-%H:%M').jpg"
    sleep "$TIME_DELAY"
  done
else
  mkdir "$SCRIPT_HOME"
fi
