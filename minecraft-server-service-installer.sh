#!/bin/bash

##### Color Coding // Dev Comments
# \x1B[1;32m     Green / OK
# \x1B[0m        White / Clear / None
# \x1B[1;31m     Red / ERROR
# \x1B[1;33m     Orange / WARNING

####################################################################################################
# Script Information.                             ##################################################
####################################################################################################
ScriptName="Mitchell's Minecraft Server Service Installation Script"
ScriptDescription="Bash script that helps installing a Minecraft Server on Linux as a system service."
ScriptDeveloper="Mitchell van Bijleveld"
ScriptDeveloperWebsite="https://mitchellvanbijleveld.dev/"
ScriptVersion="2023 01 04 22 55 - beta"
ScriptCopyright="© 2022"
####################################################################################################
# Mitchell van Bijleveld's Script Updater.        ##################################################
Internal_ScriptName="Minecraft-Server-Service"
URL_VERSION="https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/VERSION"
URL_SCRIPT="https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/minecraft-server-service-installer.sh"
####################################################################################################





###########################################################################
# 'source' external functions from GitHub (personal dev site).            #
###########################################################################
source <(curl https://github.mitchellvanbijleveld.dev/Bash-Functions/import_Functions.sh --silent)
import_Functions echo_Verbose print_ScriptInfo script_Updater
###########################################################################











###########################################################################
# Print Help Information about the script to the terminal.                #
###########################################################################
Show_Help() {
    echo "How to use the script: 'bash minecraft-server-service-installer.sh [options]'"
    echo
    echo "The following options are available:"
    echo "     --allow-unsupported-os             :     Allow installation of the server on unsupported operating systems."
    echo "                                              Make sure all required packages are already installed because the script won't check."
    echo "     --auto-install                     :     Do not ask for installation permissions for required packages."
    echo "     --check-os                         :     Check if your OS and OS Version are supported by the script."
    echo "     --check-packages                   :     Check if packages are installed. This will also check OS Support (--check-os)"
    echo "     --help                             :     Show this Help."
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
###########################################################################





###########################################################################
# Check the OS Name and OS Version. Return if the OS is supported.        #
###########################################################################
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
            echo -e "\x1B[1;31mNo valid OS detected.\x1B[0m"
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
        echo -e "\x1B[1;32m  Your OS and Version are supported.\x1B[0m"
    else
        echo -e "\x1B[1;31m  Unfortunately, your OS is not supported.\x1B[0m"
        if $ArgumentAllowUnsupportedOS; then
            echo -e "\x1B[1;33m  Allowing installation on an unsupported OS, continuing...\x1B[0m"
        else
            echo -e "\x1B[1;31m  Please use this script on a supported OS or pass the '--allow-unsupported-os' option.\x1B[0m"
            echo
            exit
        fi
    fi
    echo
}
###########################################################################





###########################################################################
# Check for Installed Packages on Debian                                  #
###########################################################################
Check_Required_Packages_DPKG() {

    # Set InstallPackage to false.
    InstallPackage=false
    PackageStatus=$(dpkg-query --list | grep "ii  $1")
    # echo $PackageStatus
    case $PackageStatus in
    "ii  $1"*)
        echo -e "\x1B[1;32mThe requested package '$1' is already installed, continuing...\x1B[0m"
        ;;
    *)
        echo -e "\x1B[1;33mThe requested package '$1' has not been installed yet.\x1B[0m"
        if $ArgumentAutoInstall; then
            echo "Automatically installing package '$1'..."
            InstallPackage=true
        else
            while [ $ArgumentAutoInstall == false ]; do
                read -p "Do you want to install the required package '$1' now? [yes/no] " yn
                case $yn in
                [Yy]*)
                    echo "Installing the package '$1'"
                    InstallPackage=true
                    break
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
            done
        fi
        ;;
    esac

    if $InstallPackage; then
        if $ArgumentVerboseLogging; then
            apt-get install $1 -y
        else
            LogFileTimeStamp=$(date +"D%Y%m%dT%H%M")
            LogFileName="$LogFileTimeStamp.PackageInstall.$1.log"
            apt-get install $1 -y >"$LogDirectory$LogFileName"

    # Set InstallPackage to false.
    InstallPackage=false
    PackageStatus=$(dpkg-query --list | grep "ii  $1")
    # echo $PackageStatus
    case $PackageStatus in
    "ii  $1"*)
                echo -e "\x1B[1;32mThe requested package '$1' has successfully been installed\x1B[0m"
                ;;
            *)
                echo
                echo -e "\x1B[1;31mSomething went wrong and I need to end the script here.\x1B[0m"
                exit
                ;;
            esac
        fi
    fi
    echo

}
###########################################################################





###########################################################################
# Check for Installed Packages on CentOS                                  #
###########################################################################
Check_Required_Packages_RPM() {
    # Set InstallPackage to false.
    InstallPackage=false

    PackageStatus=$(rpm -q $1)
    # echo $PackageStatus
    case $PackageStatus in
    "$1"*)
        echo -e "\x1B[1;32mThe requested package '$1' is already installed, continuing...\x1B[0m"
        ;;
    "package $1 is not installed")
        echo -e "\x1B[1;33mThe requested package '$1' has not been installed yet.\x1B[0m"
        if $ArgumentAutoInstall; then
            echo "Automatically installing package '$1'..."
            InstallPackage=true
        else
            while [ $ArgumentAutoInstall == false ]; do
                read -p "Do you want to install the required package '$1' now? [yes/no] " yn
                case $yn in
                [Yy]*)
                    echo "Installing the package '$1'"
                    InstallPackage=true
                    break
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
            done
        fi
        ;;
    *)
        echo -e "\x1B[1;31mCould not check for package status(ses).\x1B[0m"
        exit
        ;;
    esac

    if $InstallPackage; then
        if $ArgumentVerboseLogging; then
            dnf install $1 -y
        else
            LogFileTimeStamp=$(date +"D%Y%m%dT%H%M")
            LogFileName="$LogFileTimeStamp.PackageInstall.$1.log"
            dnf install $1 -y >"$LogDirectory$LogFileName"

            PackageStatus=$(rpm -q $1)
            # echo $PackageStatus
            case $PackageStatus in
            "$1"*)
                echo -e "\x1B[1;32mThe requested package '$1' has successfully been installed\x1B[0m"
                ;;
            *)
                echo
                echo -e "\x1B[1;31mSomething went wrong and I need to end the script here.\x1B[0m"
                exit
                ;;
            esac
        fi
    fi
    echo

}
###########################################################################




###########################################################################
# Check Packages on detected Operating System                             #
###########################################################################
Check_Packages(){

if $ArgumentOnlyCheckPackages; then
    Check_OS_Support
fi

case $OS_ID in
debian | ubuntu) # Check for the required packages on Debian and Ubuntu.
    # Before checking, run apt-get update
    LogFileTimeStamp=$(date +"D%Y%m%dT%H%M")
    LogFileName="$LogFileTimeStamp.AptGetUpdate.log"
    apt-get update >"$LogDirectory$LogFileName"
    for ApplicationX in $PackagesDPKG; do
        Check_Required_Packages_DPKG $ApplicationX
    done
    ;;

almalinux | rocky | centos) # Check for the required packegs on Almalinux and Rocky.
    for ApplicationX in $PackagesRPM; do
        Check_Required_Packages_RPM $ApplicationX
    done
    ;;

*)
    echo "Unsupported OS."
    ;;
esac
}





###########################################################################
# Check if the script is executed with options/arguments. Set Variables.  #
###########################################################################
##### Set Script Variables                                                #
LogDirectory="/var/log/mitchellvanbijleveld/mc-server-installer/"         #
PackagesDPKG="screen openjdk-17-jdk"                                      #
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
ArgumentVerboseLogging=false                 # 8 #
ArgumentWaitAfterStep=false                  # 9 #
##################################################

# Check the arguments.
ScriptArguments=" $@ "
echo_Verbose ".$ScriptArguments."
for ArgumentX in $@; do
    case $ArgumentX in
    "--allow-unsupported-os")
        echo_Verbose "--allow-unsupported-os"
        ArgumentAllowUnsupportedOS=true
        ;;
    "--auto-install")
        echo_Verbose "--auto-install"
        ArgumentAutoInstall=true
        ;;
    "--check-os")
        echo_Verbose "--check-os"
        ArgumentOnlyCheckOS=true
        ;;
    "--check-packages")
        echo_Verbose "--check-packages"
        ArgumentOnlyCheckPackages=true
        ;;
    "--help")
        echo_Verbose "--help"
        ArgumentShowHelp=true
        ;;
    "--version")
        echo_Verbose "--version"
        ArgumentShowVersionInfo=true
        ;;
    "--skip-wait")
        echo_Verbose "--skip-wait"
        ArgumentSkipWaitTimer=true
        ;;
    "--verbose")
        echo_Verbose "--verbose"
        ArgumentVerboseLogging=true
        ;;
    "--wait-after-step")
        echo_Verbose "--wait-after-step"
        ArgumentWaitAfterStep=true
        ;;
    *) # Wild Card.
        echo "Invalid Command. Exiting..."
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

if $ArgumentOnlyCheckPackages; then #  #
    Check_Packages
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

if $ArgumentVerboseLogging; then # 7 #
    # Do nothing.
    echo -n
fi

if $ArgumentWaitAfterStep; then # 8 #
    # Do nothing.
    echo -n
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
echo_Verbose "ArgumentVerboseLogging.         : $ArgumentVerboseLogging"
echo_Verbose "ArgumentWaitAfterStep=false     : $ArgumentWaitAfterStep"
echo_Verbose

echo_Verbose "Log directory is set to $LogDirectory..."

echo_Verbose "Setting default arguments to false before checking passed arguments..."
###########################################################################





###########################################################################
###########################################################################
###########################################################################
###########################################################################
###########################################################################
# ACTUAL START OF THE SCRIPT!                                             #
###########################################################################

#Check if the script is ran by root
SYSTEM_USER_NAME=$(id -u -n) # Used -u -n to make it compatible with macOS.
if [ $SYSTEM_USER_NAME == "root" ]; then
    # Just print an empty line.
    echo -n
else
    echo -e "\x1B[1;31mYou are not running this script as root. Script will exit.\x1B[0m"
    echo
    exit
fi
Check_Script_Update





###########################################################################
# Prepare the start of the script by clearing the terminal.               #
###########################################################################
# Before doing anything, clear the terminal.
if $ArgumentSkipWaitTimer; then
    # Do nothing if the skip wait timer is set to true.
    echo -n
else
    echo "Waiting 6 seconds before the script starts... Cancel script by pressing 'Control + C' (^C)."
    sleep 1
    echo "Waiting 5 seconds..."
    sleep 1
    echo "Waiting 4 seconds..."
    sleep 1
    echo "Waiting 3 seconds..."
    sleep 1
    echo "Waiting 2 seconds..."
    sleep 1
    echo "Waiting 1 second..."
    sleep 1
    echo "Starting Script."
fi

# Clearing the terminal output before showing anything that is script related.
clear
###########################################################################





###########################################################################
# Function that enables a check before contuing to the next step.         #
###########################################################################
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
###########################################################################





###########################################################################
##### Step 00 - Check OS Name and OS Version.                             #
###########################################################################
echo "Initializing Script..."
echo
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

###########################################################################
sleep 1





###########################################################################
##### Step 1 - Check OS Name and OS Version.                             #
###########################################################################
echo "####################################################################################################"
echo "Step 1 - Check if your operating system and version are supported by the script."
echo
Check_OS_Support

if $ArgumentWaitAfterStep; then # 8 #
    Print_Next_Step_Confirmation_Question "Your OS and OS Version are supported."
fi
###########################################################################
sleep 1





###########################################################################
##### Step 02 - Check for required packages.
###########################################################################
echo "####################################################################################################"
echo "Step 2 - Checking if the required packages are installed and if not, install the packages."
echo

Check_Packages

if $ArgumentWaitAfterStep; then # 8 #
    Print_Next_Step_Confirmation_Question "Your system has the required packages installed."
fi
###########################################################################
sleep 1





###########################################################################
##### Step 03 - Minecraft Server.
###########################################################################
echo "####################################################################################################"
echo "Step 3 - Downloading service file and Minecraft Server ."
echo

LogFileTimeStamp=$(date +"D%Y%m%dT%H%M")
LogFileName="$LogFileTimeStamp.DownloadService.log"
echo "Downloading Minecraft Server Service File..."
curl --output /etc/systemd/system/minecraft-server.service https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/minecraft-server.service --progress-bar
if [ -e /etc/systemd/system/minecraft-server.service ]; then
    echo -n # Print empty newline
else
    echo -e "\x1B[1;31mCould not save service file. Exiting...\x1B[0m"
    exit
fi
echo
echo_Verbose "Creating directory '/etc/mitchellvanbijleveld/minecraft-server'..."
mkdir -p /etc/mitchellvanbijleveld/minecraft-server
LogFileTimeStamp=$(date +"D%Y%m%dT%H%M")
LogFileName="$LogFileTimeStamp.DownloadServerJar.log"
echo "Downloading Minecraft Server Jar File (Version $Online_JarVersion)..."
curl --output /etc/mitchellvanbijleveld/minecraft-server/minecraft-server.jar $Online_JarURL --progress-bar
if [ -e /etc/mitchellvanbijleveld/minecraft-server/minecraft-server.jar ]; then
    echo -n # Print empty newline
else
    echo -e "\x1B[1;31mCould not save Java jar file. Exiting...\x1B[0m"
    exit
fi
echo
echo_Verbose "Running 'systemctl daemon-reload'..."
systemctl daemon-reload





##### Agree To Minecraft EULA
Agree_To_EULA(){
echo "eula=true" >/etc/mitchellvanbijleveld/minecraft-server/eula.txt
        EulaText=$(cat /etc/mitchellvanbijleveld/minecraft-server/eula.txt)
        if [ $EulaText == "eula=true" ]; then
            echo -n # Print empty newline
        else
            echo -e "\x1B[1;31mCould not save eula file. Exiting...\x1B[0m"
            exit
        fi
        echo -e "\x1B[1;32mAdded 'eula=true' to '/etc/mitchellvanbijleveld/minecraft-server/eula.txt'.\x1B[0m"
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
        echo -e "\x1B[1;33mPlease read the eula and add 'eula=true' to '/etc/mitchellvanbijleveld/minecraft-server/eula.txt'.\x1B[0m"
        echo "     You can do so by executing the following command: 'eula=true >/etc/mitchellvanbijleveld/minecraft-server/eula.txt'."
        ;;
    esac
fi




if $ArgumentWaitAfterStep; then # 8 #
    Print_Next_Step_Confirmation_Question "The script has prepared the server."
fi


###########################################################################
sleep 1





###########################################################################
##### Step 04 - Service Settings
###########################################################################
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
    echo -e "\x1B[1;32mThe server has been enabled to start during boot.\x1B[0m"
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
    echo -e "\x1B[1;33mThe server has not been enabled to start during boot.\x1B[0m To do so in the future, run the command below:"
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
        echo -e "\x1B[1;32mThe server has been started in the background within a Screen session.\x1B[0m"
    else
        echo -e "\x1B[1;31mThe Minecraft Server Service failed to start.\x1B[0m"
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
    echo -e "\x1B[1;33mThe server will not be started right now.\x1B[0m To start the server, run the following command:"
    echo "sudo systemctl start minecraft-server"
    echo
    ;;
esac
fi






##### Connect To The Server
Connect_To_Server(){
        echo -e "\x1B[1;32mWill connect to Screen session after exit.\x1B[0m"
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
        echo -e "\x1B[1;33mWill not connect to Screen session after exit.\x1B[0m"
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

###########################################################################
