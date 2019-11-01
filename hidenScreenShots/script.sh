#!/usr/bin/env bash

## Script to take a screenshot in background.
## nohup sh "$PWD"/hidenScreenShots/script.sh &

## Script will take screenshots and save inside this directory
SCRIPT_HOME="$HOME/example"

## If you would like to change delay berween screenshots change the value
TIME_DELAY='15'



## Some collors
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

## Warning user to run properlly run the script
echo "${red}WARNING: This script should run with nohup command"

## Function for mac laptop only
function startTakingScreenShotsForMac() {

  ## Script will run the loop for ever you will need to kill this process manually
  while [[ true ]]; do

    ## Taking the actual screen shot
    screencapture -x "$SCRIPT_HOME/$(date '+%Y-%m-%d-%H-%M-%S').jpg"
    sleep "$TIME_DELAY"
    echo "${green}Taked screenshot:${reset} ${red}$SCRIPT_HOME/$(date '+%Y-%m-%d-%H-%M-%S').jpg${reset}"
  done
}

## Checking the operating system
if [[  $OSTYPE == "darwin"* ]]; then

  ## If the scripts home directory exist script will start taking screenshots
  if [[ -d "$SCRIPT_HOME" ]]; then

    ## Calling the function so script can start taking the screenshots
    startTakingScreenShotsForMac
  else

    ## if the folder does not exist
    mkdir "$SCRIPT_HOME"
    echo "Created: $SCRIPT_HOME"
    startTakingScreenShotsForMac
  fi

else
  echo "${red}Sorry this script is not supports $OSTYPE ${reset}"
fi
