import subprocess

####################################################################################################
##### Script Information.                         ##################################################
####################################################################################################
ScriptName = "Mitchell's Minecraft Server Service Installation Script"
ScriptDescription = "Python script that helps installing a Minecraft Server on Linux as a system service."
ScriptDeveloper = "Mitchell van Bijleveld"
ScriptDeveloperWebsite = "https://mitchellvanbijleveld.dev/"
Script_Version = "2023.04.28-14.51-beta"
ScriptCopyright = "© 2023"
##### Mitchell van Bijleveld's Script Updater.    ##################################################
Internal_ScriptName = "Minecraft-Server-Service"  # So I want to get rid of this.
URL_VERSION = "https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/VERSION"
URL_SCRIPT = "https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/minecraft-server-service-installer.sh"
####################################################################################################
####################################################################################################
####################################################################################################

####################################################################################################
##### Set Default Variables.                      ##################################################
####################################################################################################
FolderPath_BaseTemp = "/tmp/mitchellvanbijleveld"
FolderPath_Temp = f"{FolderPath_BaseTemp}/Minecraft-Server"
FolderPath_BaseLogs = "/var/log/mitchellvanbijleveld"
FolderPath_Logs = f"{FolderPath_BaseLogs}/Minecraft-Server"
FolderPath_BaseProgramFiles = "/opt/mitchellvanbijleveld"
FolderPath_ProgramFiles = f"{FolderPath_BaseProgramFiles}/Minecraft-Server"
PackagesDPKG = "jq screen openjdk-17-jdk"
PackagesRPM = "jq epel-release screen java-17-openjdk"
Banner_TerminalWidth = int(subprocess.check_output(['tput', 'cols']).strip()) - 32
####################################################################################################
####################################################################################################
####################################################################################################
