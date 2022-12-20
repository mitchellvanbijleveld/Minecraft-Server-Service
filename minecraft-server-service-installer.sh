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
# Custom Log Message Function that takes LogLevel in consideration.       #
###########################################################################
echo_Verbose() {
    if $ArgumentVerboseLogging; then
        echo "LOG $(date +"%Y-%m-%d %H:%M:%S") [DEBUG] : $1"
    fi
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
