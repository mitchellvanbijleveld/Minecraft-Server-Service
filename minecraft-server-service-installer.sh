#!/bin/bash

##### Color Coding // Dev Comments
# \x1B[1;32m     Green / OK
# \x1B[0m        White / Clear / None
# \x1B[1;31m     Red / ERROR
# \x1B[1;33m     Orange / WARNING

###########################################################################
# Script Information.                                                     #
###########################################################################
ScriptName="Mitchell's Minecraft Server Service Installation Script"
ScriptDescription="Bash script that helps installing a Minecraft Server on Linux as a system service."
ScriptDeveloper="Mitchell van Bijleveld"
ScriptDeveloperWebsite="https://mitchellvanbijleveld.dev/"
ScriptVersion="2022 12 16 23 51 - beta"
ScriptCopyright="© 2022"

Show_Version_Info() {
    echo "$ScriptName"
    echo "$ScriptDescription"
    echo
    echo "Script Developer  : $ScriptDeveloper"
    echo "Developer Website : $ScriptDeveloperWebsite"
    echo
    echo "Version $ScriptVersion - $ScriptCopyright $ScriptDeveloper"
    echo
}
###########################################################################
