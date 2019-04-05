#!/usr/bin/env bash

green="$(tput setaf 2)"
red="$(tput setaf 1)"
reset="$(tput sgr0)"
username="$(whoami)"

echo """
${red}############################################################################

WARNING! The user '${username}' will be deleted on  Wednesday, 04.10.2019, EOD for security reasons.${reset}

In order to continue using the DAC Server, you will need to create your own user by following the steps listed in this VET confluence page:

documentation link

For more details or questions, please contact Farkhod (farkhod.sadykov@companyname.com) or 

${red}
############################################################################${reset}
"""
## Set for /home/.ssh/rc
