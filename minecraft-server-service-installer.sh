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





###########################################################################
# Function that checks for a script update, download it and run it.       #
###########################################################################
Check_Script_Update () {
echo "Checking for script updates..."
mkdir -p /tmp/mitchellvanbijleveld/Minecraft-Server-Service/
curl --output /tmp/mitchellvanbijleveld/Minecraft-Server-Service/VersionInfo https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/VERSION --silent
. /tmp/mitchellvanbijleveld/Minecraft-Server-Service/VersionInfo
Online_ScriptVersion=$SCRIPT
Online_JarVersion=$JAR
Online_JarURL=$URL

if [[ $ScriptVersion < $Online_ScriptVersion ]]; then
    ScriptName="$0"
    echo -e "\x1B[1;33mScript not up to date ($ScriptVersion)! Downloading newest version ($Online_ScriptVersion)...\x1B[0m"
    curl --output "./$ScriptName" https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/minecraft-server-service-installer.sh --progress-bar
    echo
    echo "Restarting Script..."
    bash "./$ScriptName"
    exit
elif [[ $ScriptVersion > $Online_ScriptVersion ]]; then
    echo -e "\x1B[1;33mYour version of the script ($ScriptVersion) is newer than the server version ($Online_ScriptVersion).\x1B[0m"
else
    echo -e "\x1B[1;32mScript is up to date.\x1B[0m"
fi
echo
}
###########################################################################
