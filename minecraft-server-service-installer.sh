#!/bin/bash
####################################################################################################
##### Script Information.                         ##################################################
####################################################################################################
ScriptName="Mitchell's Minecraft Server Service Installation Script"
ScriptDescription="Bash script that helps installing a Minecraft Server on Linux as a system service."
ScriptDeveloper="Mitchell van Bijleveld"
ScriptDeveloperWebsite="https://mitchellvanbijleveld.dev/"
ScriptVersion="2023.04.15-00.13-beta"
ScriptCopyright="© 2023"
##### Mitchell van Bijleveld's Script Updater.    ##################################################
Internal_ScriptName="Minecraft-Server-Service"
URL_VERSION="https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/VERSION"
URL_SCRIPT="https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/minecraft-server-service-installer.sh"
####################################################################################################
####################################################################################################
####################################################################################################


####################################################################################################
##### Set Default Variables.                      ##################################################
####################################################################################################
LogExtraMessages=false
####################################################################################################
####################################################################################################
####################################################################################################

# Import the Function Importer.
eval "$(curl https://github.mitchellvanbijleveld.dev/Bash-Functions/import_Functions.sh --silent)"

##### Before starting the script, check if the --verbose option is passed.
if [[ "$@" == *"--verbose"* ]]; then
    # If --verbose, then set the corresponding verbose variables. LogExtraMessages is usded to print more messages then normal.
    #logStyle=Verbose changes the terminal output to a verbose style with timestamps.
    LogExtraMessages=true
    LogStyle=Verbose
    
    # If --verbose, then import the functions with terminal output.
    import_Functions echo_Replaced print_ScriptInfo script_Updater
else
    # if not --verbose, then import the functions without terminal output.
    import_Functions echo_Replaced print_ScriptInfo script_Updater --silent
fi

# 025
#########################
# 050
##################################################
# 075
###########################################################################
# 100
####################################################################################################


####################################################################################################
# Print Help Information to the terminal.         ##################################################
Show_Help() {
    echo "How to use the script: 'bash minecraft-server-service-installer.sh [options]'"
    echo
    echo "The following options are available:"
    echo "     --allow-unsupported-os             :     Allow installation of the Minecraft server on unsupported operating systems."
    echo "                                              Make sure all required packages are already installed because the script won't check."
    echo "     --auto-install                     :     Do not ask for installation permissions for required packages."
    echo "     --check-os                         :     Check if your OS and OS Version are supported by the script."
    echo "     --check-packages                   :     Check if packages are installed. This will also check OS Support (--check-os)"
    echo "     --help                             :     Show this Help."
    echo "     --server-version=[...]             :     To install a custom server, put a server version string like 1.19.4 here. Defaults to latest."
    echo "                                              For example: 'bash minecraft-server-service-installer.sh --server-version=1.19.4'"
    echo "     --show-server-versions             :     Show the available server versions."
    echo "     --skip-wait                        :     Skip the 6 seconds wait timer before starting the script."
    echo "     --verbose                          :     Enable Verbose Logging during the execution of the script."
    echo "     --version                          :     Show Version Information about the script."
    echo "     --wait-after-step                  :     Ask for confirmation to continue after completing a step."
    echo
    echo "To Start/Stop/Enable/Disable the Minecraft Server Service:"
    echo "Start the server                        :     systemctl start minecraft-server"
    echo "Stop the server                         :     systemctl stop minecraft-server"
    echo "Enable server at system boot            :     systemctl enable minecraft-server"
    echo "Disable server at system boot           :     systemctl disable minecraft-server"
    echo
}
####################################################################################################





####################################################################################################
# Check the OS Name and OS Version. Return if the OS is supported.         #########################
Check_OS_Support() {
    # Set Supported OS to false.
    SupportedOS=false

    # Read the OS Release file.
    echo_Verbose "Reading '/etc/os-release'..." # using this file because it's present on almost all linux distos

    if [ -e /etc/os-release ]; then
        . /etc/os-release
        # Set the OS_ID and OS_Version variables.
        echo_Verbose "Setting OS_Name..."
        OS_Name=$NAME
        echo_Verbose "Setting OS_Version..."
        OS_Version=$VERSION

        echo_Verbose "Setting OS_ID..."
        OS_ID=$ID
        echo_Verbose "Setting OS_VersionID..."
        OS_VersionID=$VERSION_ID
    else
        # No Linux? Try macOS.
        if [ -e "/usr/bin/sw_vers" ]; then
            macOSVersionInfo=$("/usr/bin/sw_vers")
            OS_Name=$(/usr/bin/sw_vers | /usr/bin/grep ProductName | sed 's/ProductName://')
            echo_Verbose "Setting OS_Version..."
            OS_Version=$(/usr/bin/sw_vers | /usr/bin/grep ProductVersion | sed 's/ProductVersion://')
            echo_Verbose "Setting OS_ID..."
            if [ $OS_Name == "macOS" ]; then
                OS_ID="macos"
            fi
        fi

    fi

    # For debugging purposes, print the OS_ID and OS_Version variables.
    echo_Verbose "OS ID         : $OS_ID"
    echo_Verbose "OS Version ID : $OS_VersionID"
    echo_Verbose "OS Version    : $OS_Version"
    echo_Verbose "OS Name       : $OS_Name"

    echo_Verbose "Checking if OS matches list of supported operating systems..."
    case $OS_ID in
    debian | ubuntu | almalinux | rocky | centos) #List of supported operating systems / distributions.
        echo_Verbose "Your OS '$OS_ID' is supported. Checking if your OS version is supported as well..."

        case $OS_ID in
        debian)
            case $OS_VersionID in
            "9"* | "10"* | "11"*)
                echo_Verbose "Your version '$OS_VersionID' of $OS_ID is supported!"
                SupportedOS=true
                ;;
            *)
                echo_Verbose "Unfortunately, your version '$OS_VersionID' of $OS_ID is not supported. Please us a supported version of your OS to use this script."
                echo_Verbose
                ;;
            esac
            ;;
        ubuntu)
            case $OS_VersionID in
            "20.04"* | "22.04"*)
                echo_Verbose "Your version '$OS_VersionID' of $OS_ID is supported!"
                SupportedOS=true
                ;;
            *)
                echo_Verbose "Unfortunately, your version '$OS_VersionID' of $OS_ID is not supported. Please us a supported version of your OS to use this script."
                echo_Verbose
                ;;
            esac
            ;;
        almalinux | rocky)
            case $OS_VersionID in
            "8."* | "9."*)
                echo_Verbose "Your version '$OS_VersionID' of $OS_ID is supported!"
                SupportedOS=true
                ;;
            *)
                echo_Verbose "Unfortunately, your version '$OS_VersionID' of $OS_ID is not supported. Please us a supported version of your OS to use this script."
                echo_Verbose
                ;;
            esac
            ;;
        centos) # Stream, btw.
            case $OS_VersionID in
            8 | 9) # doesn't need a dot because it's a 'rolling release' as in stream.
                echo_Verbose "Your version '$OS_VersionID' of $OS_ID is supported!"
                SupportedOS=true
                ;;
            *)
                echo_Verbose "Unfortunately, your version '$OS_VersionID' of $OS_ID is not supported. Please us a supported version of your OS to use this script."
                echo_Verbose
                ;;
            esac
            ;;
        *)
            echo "\x1B[1;31mNo valid OS detected.\x1B[0m"
            ;;
        esac
        #####

        ;;

    macos)
        echo "Support for macOS is coming later."
        echo_Verbose "OS Not yet Supported..."
        ;;
    *)
        echo_Verbose "OS Not Supported..."
        ;;
    esac

    echo "Detected OS: $OS_Name $OS_Version."

    echo_Verbose "Printing information about OS Support..."
    if $SupportedOS; then
        echo "\x1B[1;32mYour OS and Version are supported.\x1B[0m"
    else
        echo "\x1B[1;31m  Unfortunately, your OS is not supported.\x1B[0m"
        if $ArgumentAllowUnsupportedOS; then
            echo "\x1B[1;33m  Script is allowed to continue on an unsupported OS because the '--allow-unsupported-os' flag is passed. Continuing...\x1B[0m"
        else
            echo "\x1B[1;31m  Please use this script on a supported OS or pass the '--allow-unsupported-os' option.\x1B[0m"
            echo
            exit
        fi
    fi
    echo
}
####################################################################################################



####################################################################################################
####################################################################################################
##### Check if requested packages is installed.   ##################################################
####################################################################################################
Check_Package() {
    # this function will check if the requested package has been installed or not.
    # If it's not installed, then install the package.

    echo_Verbose "Checking if package '$1' is installed..."
    
    # Switching OS_ID to check the packages depending on the OS.
    case $OS_ID in
    debian | ubuntu) # Check for the required packages on Debian and Ubuntu.
        echo_Verbose "Checking Package Status via 'dpkg' for '$1'..."
        dpkg --status $1 &>/dev/null
        ;;
    almalinux | rocky | centos) # Check for the required packegs on Almalinux and Rocky.
        echo_Verbose "Checking Package Status via 'rpm' for '$1'..."
        rpm --query $1 &>/dev/null
        ;;
    *)
        echo "Your OS is not supported. Therefore the script cannot check for the required package..."
        exit 1
        ;;
    esac

    # Check if package is insatlled with exit code = 0
    if [[ $? == 0 ]]; then
        echo "\x1B[1;32mThe requested package '$1' is already installed!\x1B[0m"
    else
        echo "\x1B[1;33mThe requested package '$1' has not been installed yet.\x1B[0m"

        # Check if this is a check-only or not.
        if ! $ScriptOption_CheckPackagesOnly; then
            if $ScriptOption_AutoInstall; then
                Boolean_InstallPackage=true
            else
                echo -n "Do you want to install the required package '$1' now? "
                read -p "Please answer [yes/no]: " yn
                case $yn in
                [Yy]*)
                    Boolean_InstallPackage=true
                    ;;
                [Nn]*)
                    echo "Not installing the package."
                    echo
                    exit
                    ;;
                *)
                    echo
                    echo "Please answer the question below."
                    ;;
                esac
            fi
            
            if $Boolean_InstallPackage; then
                case $OS_ID in
                debian | ubuntu) # Check for the required packages on Debian and Ubuntu.
                    apt-get install $1 --assume-yes
                    ;;
                almalinux | rocky | centos) # Check for the required packegs on Almalinux and Rocky.
                    yum install $1 --assumeyes
                    ;;
                *)
                    echo "Unable to find a way to install packages on your system."
                    exit 1
                    ;;
                esac
            fi
        fi
        # Checking if installation was successful
        if [[ ! $? == 0 ]]; then
            echo "Unable to install $1! Your base system has a problem; please check your default OS's package repositories because $1 should work."
            exit 1
        fi
    fi
}

####################################################################################################
####################################################################################################
####################################################################################################







####################################################################################################
# Check Packages on detected Operating System.    ##################################################
Check_Packages(){

if $ScriptOption_CheckPackagesOnly; then
    Check_OS_Support
fi

case $OS_ID in
debian | ubuntu) # Check for the required packages on Debian and Ubuntu.
    # Before checking, run apt-get update
    echo "Running 'apt-get update' to make sure all available packages are listed..."
    if $LogExtraMessages; then
      apt-get update
    else
      LogFileTimeStamp=$(date +"D%Y%m%dT%H%M")
      LogFileName="$LogFileTimeStamp.AptGetUpdate.log"
      apt-get update >"$LogDirectory$LogFileName"
    fi
    echo
    for ApplicationX in $PackagesDPKG; do
        Check_Package $ApplicationX
    done
    ;;

almalinux | rocky | centos) # Check for the required packegs on Almalinux and Rocky.
    for ApplicationX in $PackagesRPM; do
        Check_Package $ApplicationX
    done
    ;;

*)
    echo "Your OS is unsupported. Can't check for installed packages..."
    echo
    ;;
esac
}





####################################################################################################
# Print Latest 10 Available Minecraft Server Versions    ###########################################
echo_Verbose "Downloading the Minecraft Version Manifest JSON File..."
# Download the Minecraft Version Manifest JSON.
manifest=$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json)

####################################################################################################
# Get Latest 10 Available Minecraft Server Versions    #############################################
Get_MostRecentMinecraftVersions () {
  # Fetch the 10 most recent release versions
  echo_Verbose "Getting latest 10 versions of Minecraft Servers..."
  versions=$(printf "%s" "$manifest" | jq -r '.versions | .[] | select(.type=="release") | .id' | head -n 10)
  echo_Verbose "Setting servers string..."
  versions_formatted=$(printf "%s" "$versions" | tr '\n' ' ' | sed 's/ $/./;s/ / \/ /g')    
}
####################################################################################################


####################################################################################################
# Print Latest 10 Available Minecraft Server Versions    ###########################################
Print_AvailableServerVersions () {
  echo "The 10 most recent released versions are: $versions_formatted"
  echo "Use '--server-version=[...]' with one of the versions listed above."
  echo
}
####################################################################################################


####################################################################################################
# Check The Custom Selected Server Version     #####################################################

Check_CustomServerVersion () {
  echo_Verbose "Checkig if the custom server version is found in the latest 10 releases..."
  if printf "%s" "$versions_formatted" | grep -q "\\<$CustomServerVersion\\>"; then
    echo_Verbose "Custom server version found!"
  else
    echo "\x1B[1;31mServer Version '$CustomServerVersion' has not not been found. Script will exit since it can't download a server jar file...\x1B[0m"
    Print_AvailableServerVersions
    exit
  fi
}


####################################################################################################
# Check if the script is executed with options/arguments. Set Variables.   #########################
####################################################################################################
##### Set Script Variables                                                #
LogDirectory="/var/log/mitchellvanbijleveld/$Internal_ScriptName/"         #
PackagesDPKG="jq screen openjdk-17-jdk"                                   #
PackagesRPM="epel-release screen java-17-openjdk"                         #
###########################################################################
##### Default Arguments to False.            #####
ArgumentAllowUnsupportedOS=false             # 1 #
ArgumentAutoInstall=false                    # 2 #
ArgumentOnlyCheckOS=false                    # 3 #
ArgumentOnlyCheckPackages=false              # 4 #
ArgumentShowHelp=false                       # 5 #
ArgumentShowVersionInfo=false                # 6 #
ArgumentSkipWaitTimer=false                  # 7 #
ArgumentWaitAfterStep=false                  # 9 #

# NEW VERSION OF VARIABLES
ScriptOption_AutoInstall=false
ScriptOption_CheckPackagesOnly=false
ScriptOption_CustomServerVersion=false
ScriptOption_ShowServerVersions=false
##################################################

# Check the arguments.
ScriptArguments=" $@ "
echo_Verbose ".$ScriptArguments."
for ArgumentX in $@; do
    echo_Verbose "Found an option: '$ArgumentX'!"
    case $ArgumentX in
    "--allow-unsupported-os")
        ArgumentAllowUnsupportedOS=true
        ;;
    "--auto-install")
        ScriptOption_AutoInstall=true
        ;;
    "--check-os")
        ArgumentOnlyCheckOS=true
        ;;
    "--check-packages")
        ScriptOption_CheckPackagesOnly=true
        ;;
    "--help")
        ArgumentShowHelp=true
        ;;
    "--version")
        ArgumentShowVersionInfo=true
        ;;
    "--server-version"*)
        ScriptOption_CustomServerVersion=true
        CustomServerVersion=$(printf '%s' "$ArgumentX" | sed 's/--server-version=//')
        echo_Verbose "Custom Server Version Selected: $CustomServerVersion"
        ;;
    "--show-server-versions")
        ScriptOption_ShowServerVersions=true
        ;;
    "--skip-wait")
        ArgumentSkipWaitTimer=true
        ;;
    "--verbose")
        #LogExtraMessages=true
        #LogStyle=Verbose
        echo
        ;;
    "--wait-after-step")
        ArgumentWaitAfterStep=true
        ;;
    *) # Wild Card.
        echo "Checking command '$ArgumentX' went wrong since it is not valid. Exiting..."
        exit
        ;;
    esac
done

# Before checking all the arguments, make sure the script will continue if it does not need to exit after an argument (such as --help or --version).
ExitScriptAfterCommand=false

if $ArgumentAllowUnsupportedOS; then # 6 #
    # Do nothing.
    echo -n
fi

if $ArgumentAutoInstall; then # 1 #
    # Do nothing.
    echo -n
fi

if $ArgumentOnlyCheckOS; then # 2 #
    Check_OS_Support
    ExitScriptAfterCommand=true
fi

if $ArgumentShowHelp; then # 3 #
    Show_Help
    ExitScriptAfterCommand=true
fi

if $ArgumentShowVersionInfo; then # 4 #
    print_ScriptInfo
    ExitScriptAfterCommand=true
fi

if $ArgumentSkipWaitTimer; then # 5 #
    # Do nothing.
    echo -n
fi

if $LogExtraMessages; then # 7 #
    # Do nothing.
    echo -n
fi

if $ArgumentWaitAfterStep; then # 8 #
    # Do nothing.
    echo -n
fi

if $ScriptOption_CheckPackagesOnly; then #  #
    Check_Packages
    ExitScriptAfterCommand=true
fi

if $ScriptOption_CustomServerVersion; then
  Get_MostRecentMinecraftVersions
  Check_CustomServerVersion
fi

if $ScriptOption_ShowServerVersions; then
    Get_MostRecentMinecraftVersions
    Print_AvailableServerVersions
    ExitScriptAfterCommand=true
fi



if $ExitScriptAfterCommand; then
    exit
fi


echo_Verbose "Arguments are set as follows:"
echo_Verbose "ArgumentAllowUnsupportedOS      : $ArgumentAllowUnsupportedOS"
echo_Verbose "ArgumentAutoInstall             : $ArgumentAutoInstall"
echo_Verbose "ArgumentOnlyCheckOS             : $ArgumentOnlyCheckOS"
echo_Verbose "ArgumentOnlyCheckPackages       : $ArgumentOnlyCheckPackages"
echo_Verbose "ArgumentShowHelp                : $ArgumentShowHelp"
echo_Verbose "ArgumentShowVersionInfo         : $ArgumentShowVersionInfo"
echo_Verbose "ArgumentSkipWaitTimer           : $ArgumentSkipWaitTimer"
echo_Verbose "LogExtraMessages.               : $LogExtraMessages"
echo_Verbose "ArgumentWaitAfterStep=false     : $ArgumentWaitAfterStep"
echo_Verbose

echo_Verbose "Log directory is set to $LogDirectory..."

echo_Verbose "Setting default arguments to false before checking passed arguments..."
####################################################################################################





####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
# ACTUAL START OF THE SCRIPT!                     ##################################################

#Check if the script is ran by root
SYSTEM_USER_NAME=$(id -u -n) # Used -u -n to make it compatible with macOS.
if [ $SYSTEM_USER_NAME == "root" ]; then
    # Just print an empty line.
    echo -n
else
    echo "\x1B[1;31mYou are not running this script as root. Script will exit.\x1B[0m"
    echo
    exit
fi
clear



##### Check for script updates...
Check_Script_Update $@





####################################################################################################
# Prepare the start of the script by clearing the terminal.                #########################
# Before doing anything, clear the terminal.
if ! $ArgumentSkipWaitTimer; then
    for i in {5..1}; do
        echo "Waiting $i seconds before the script starts... Cancel script by pressing 'Control + C' (^C)."
        sleep 1
    done
fi
echo "Starting Script."
sleep 1

# Clearing the terminal output before showing anything that is script related.
clear
####################################################################################################





####################################################################################################
# Function that enables a check before contuing to the next step.          #########################
Print_Next_Step_Confirmation_Question() {
    while true; do
        echo "     $1"
        read -p "     Do you want to continue? [yes/no] " yn
        case $yn in
        [Yy]*)
            echo
            break
            ;;
        [Nn]*)
            echo
            exit
            ;;
        *)
            echo
            echo "Please answer the question."
            ;;
        esac
    done
}

sleep 1
####################################################################################################





####################################################################################################
##### Step 00 - Check OS Name and OS Version.     ##################################################
####################################################################################################
echo "####################################################################################################"
print_ScriptInfo
echo "####################################################################################################"
echo "Welcome to the Minecraft Server As A Service Installation Script."
echo "This script will help you to install the Minecraft Server with an easy to follow step-by-step installation wizard."
mkdir -p $LogDirectory

echo

if $ArgumentWaitAfterStep; then # 8 #
    Print_Next_Step_Confirmation_Question "The script has been successfully initialized."
fi

####################################################################################################
sleep 0.5





####################################################################################################
##### Step 1 - Check OS Name and OS Version.      ##################################################
echo "####################################################################################################"
echo "Step 1 - Check if your operating system and version are supported by the script."
echo
Check_OS_Support

if $ArgumentWaitAfterStep; then # 8 #
    Print_Next_Step_Confirmation_Question "Your OS and OS Version are supported."
fi
####################################################################################################
sleep 0.5





####################################################################################################
##### Step 02 - Check for required packages.      ##################################################
echo "####################################################################################################"
echo "Step 2 - Checking if the required packages are installed and if not, install the packages."
echo

Check_Packages

if $ArgumentWaitAfterStep; then # 8 #
    Print_Next_Step_Confirmation_Question "Your system has the required packages installed."
fi
####################################################################################################
sleep 0.5





download_ServerJAR () {

  # Download the Minecraft Version Manifest JSON.
  echo_Verbose "Downloading the Minecraft Version Manifest JSON File..."
  manifest=$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json)

  echo_Verbose "Checking if custom server version is set..."
  # Check if $CustomServerVersion is set.
  if [[ $1 = "" ]]; then
    # If $CustomServerVersion is empty, download the latest server version.
    echo_Verbose "No custom server version set. Downloading latest version JSON file..."
    # Get the URL of the latest release version JSON file
    version_url=$(printf "%s" "$manifest" | jq -r '.versions[] | select(.type == "release") | .url' | head -n 1)
    echo_Verbose "Download completed."
  else
    echo_Verbose "\x1B[1;33mCustom Server Version: $CustomServerVersion.\x1B[0m"

    # Get the URL of the version JSON file for the selected version
    echo_Verbose "Get the custom server version JSON file..."
    version_url=$(printf "%s" "$manifest" | jq -r --arg version "$CustomServerVersion" '.versions | .[] | select(.id == $version) | .url')
    echo_Verbose "Download completed."
  fi
  
  # Download release version JSON file
  echo_Verbose "Downloading release version JSON file..."
  version_manifest=$(curl -s $version_url)
  echo_Verbose "Download completed."

  # Get the version of the selected release
  echo_Verbose "Get the version of the server..."
  version=$(printf "%s" "$version_manifest" | jq -r '.id')

  # Get the URL of the server jar file
  echo_Verbose "Getting the server download url..."
  server_url=$(printf "%s" "$version_manifest" | jq -r '.downloads.server.url')

  # Download the server jar file
  echo_Verbose "Downloading server jar file..."
  
  if [[ $1 = "" ]]; then  
    echo "Downloading Latest Server Version: $version."
  else
    echo "\x1B[1;33mDownloading custom server version: $CustomServerVersion.\x1B[0m" 
  fi
  
  curl --output /etc/mitchellvanbijleveld/minecraft-server/minecraft-server.jar $server_url --progress-bar
  echo_Verbose "Downlaod completed."

  echo_Verbose "Server jar file for version $version downloaded successfully."
  
  echo_Verbose "Checking if the server JAR file is in place..."
  if [ -e /etc/mitchellvanbijleveld/minecraft-server/minecraft-server.jar ]; then
      # Get the expected sha1 value
      echo_Verbose "Getting expected sha1 value from JSON file..."
      expected_sha1=$(printf "%s" "$version_manifest" | jq -r '.downloads.server.sha1')

      # Calculate the actual sha1 value
      echo_Verbose "Calculate actual sha1 value from downloaded server JAR file..."
      actual_sha1=$(sha1sum /etc/mitchellvanbijleveld/minecraft-server/minecraft-server.jar | awk '{ print $1 }')

      # Compare the expected and actual sha1 values
      echo_Verbose "Comparing sha1 values..."
      if [ "$expected_sha1" == "$actual_sha1" ]; then
        echo_Verbose "Server jar file for version $version downloaded successfully and has the expected sha1 value."
      else
        echo "\x1B[1;31mServer jar file for version $version downloaded but has an unexpected sha1 value. Exiting...\x1B[0m"
        echo
        exit
      fi
    else
      echo "\x1B[1;31mCould not save Java jar file. Exiting...\x1B[0m"
      exit
    fi

}





####################################################################################################
##### Step 03 - Minecraft Server.                 ##################################################
echo "####################################################################################################"
echo "Step 3 - Downloading service file and Minecraft Server ."
echo

if $ArgumentAutoInstall; then
  echo "autoinstalling"
else
  echo "not autoinstalling"
fi

read -p "The script will now download the service file and the server jar file. Do you want to proceed? [yes/no] " yn
    case $yn in
    [Yy]*)
        
LogFileTimeStamp=$(date +"D%Y%m%dT%H%M")
LogFileName="$LogFileTimeStamp.DownloadService.log"
echo "Downloading Minecraft Server Service File..."
curl --output /etc/systemd/system/minecraft-server.service https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/minecraft-server.service --progress-bar
echo
echo_Verbose "Download completed"
if [ ! -e /etc/systemd/system/minecraft-server.service ]; then
    echo "\x1B[1;31mCould not save service file. Exiting...\x1B[0m"
    echo
    exit
fi
echo_Verbose "Creating directory '/etc/mitchellvanbijleveld/minecraft-server'..."
mkdir -p /etc/mitchellvanbijleveld/minecraft-server
LogFileTimeStamp=$(date +"D%Y%m%dT%H%M")
LogFileName="$LogFileTimeStamp.DownloadServerJar.log"

download_ServerJAR $CustomServerVersion

echo
echo_Verbose "Running 'systemctl daemon-reload'..."
systemctl daemon-reload
        ;;
        
        
    *)
        echo "OK exit"
        echo
        exit
        ;;
    esac

##### Agree To Minecraft EULA
Agree_To_EULA(){
echo "eula=true" >/etc/mitchellvanbijleveld/minecraft-server/eula.txt
        EulaText=$(cat /etc/mitchellvanbijleveld/minecraft-server/eula.txt)
        if [ $EulaText == "eula=true" ]; then
            echo -n # Print empty newline
        else
            echo "\x1B[1;31mCould not save eula file. Exiting...\x1B[0m"
            exit
        fi
        echo "\x1B[1;32mAdded 'eula=true' to '/etc/mitchellvanbijleveld/minecraft-server/eula.txt'.\x1B[0m"
        echo
}
#####
if $ArgumentAutoInstall; then
  Agree_To_EULA
else
  read -p "Do you agree to the Minecraft (Server) EULA? [yes/no] " yn
    case $yn in
    [Yy]*)
        Agree_To_EULA;;
    *)
        echo "\x1B[1;33mPlease read the eula and add 'eula=true' to '/etc/mitchellvanbijleveld/minecraft-server/eula.txt'.\x1B[0m"
        echo "You can do so by executing the following command: 'eula=true >/etc/mitchellvanbijleveld/minecraft-server/eula.txt'."
        echo
        ;;
    esac
fi




if $ArgumentWaitAfterStep; then # 8 #
    Print_Next_Step_Confirmation_Question "The script has prepared the server."
fi


####################################################################################################
sleep 0.5





####################################################################################################
##### Step 04 - Service Settings                  ##################################################
# Set Variables for this step.
ServerStarted=false
ConnectToScreenAfterExit=false

echo "####################################################################################################"
echo "Step 04 - Configuring Minecraft Server Service."
echo

echo "The Minecraft Server has successfully been installed as a system service."



##### Enable Start @ Boot
Enable_Server() {
    systemctl enable minecraft-server
    echo "\x1B[1;32mThe server has been enabled to start during boot.\x1B[0m"
    echo
}
#####
if $ArgumentAutoInstall; then
Enable_Server
else
read -p "Do you want to start the server automatically during startup [yes/no] " yn
case $yn in
[Yy]*)
Enable_Server;;
*)
    echo "\x1B[1;33mThe server has not been enabled to start during boot.\x1B[0m To do so in the future, run the command below:"
    echo "systemctl enable minecraft-server"
    echo
    ;;
esac
fi





##### Start Server
Start_Server() {
systemctl start minecraft-server
    ServerStatus=$(systemctl status minecraft-server | grep Active)
    echo_Verbose $ServerStatus
if [[ $ServerStatus == *'Active: active (running)'* ]]; then
        ServerStarted=true
        echo "\x1B[1;32mThe server has been started in the background within a Screen session.\x1B[0m"
    else
        echo "\x1B[1;31mThe Minecraft Server Service failed to start.\x1B[0m"
        exit
    fi
    echo
}
#####
if $ArgumentAutoInstall; then
    Start_Server
else
    read -p "Do you want to start the server now? [yes/no] " yn
    case $yn in
    [Yy]*)
        Start_Server;;
    *)
    echo "\x1B[1;33mThe server will not be started right now.\x1B[0m To start the server, run the following command:"
    echo "sudo systemctl start minecraft-server"
    echo
    ;;
esac
fi






##### Connect To The Server
Connect_To_Server(){
        echo "\x1B[1;32mWill connect to Screen session after exit.\x1B[0m"
        ConnectToScreenAfterExit=true
        echo
}
#####
if $ArgumentAutoInstall; then
Connect_To_Server
else
if $ServerStarted; then
    read -p "The server has been started. Do you want to connect to the Screen session to view the logs?? [yes/no] " yn
    case $yn in
    [Yy]*)
     Connect_To_Server;;
    *)
        echo "\x1B[1;33mWill not connect to Screen session after exit.\x1B[0m"
        echo
        ;;
    esac
fi
fi





if $ArgumentWaitAfterStep; then # 8 #
    Print_Next_Step_Confirmation_Question "Step 03"
fi

if $ConnectToScreenAfterExit; then
    echo "Connecting to Screen session within 6 seconds..."
    sleep 1
    echo "Connecting to Screen in 5..."
    sleep 1
    echo "Connecting to Screen in 4..."
    sleep 1
    echo "Connecting to Screen in 3..."
    sleep 1
    echo "Connecting to Screen in 2..."
    sleep 1
    echo "Connecting to Screen in 1..."
    sleep 1
    echo "Connecting to Screen!"
    echo
    screen -r MinecraftServer
fi
echo "The Script Finished."
echo

####################################################################################################
