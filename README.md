# Minecraft Server
Minecraft Server as a service on your own Linux or macOS machine.

Disclaimer: This version is in alpha. You may encouter issues.

## Automatic installation
To make things easy, I created an automatic install script for you.

### Download Script
```
curl -O https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/minecraft-server-service-installer.sh
```

### Run Script
```
bash minecraft-server-service-installer.sh
```

## Manual Installation

### Prerequisites
Before the server can run, we need a few packages, depending on which operating system you are using.

All the commands below need to be run as the root user. So, either login with `su -` or `sudo -i` or even `suduo su -` depending on your operating system or use `sudo [command]` to run a command as root.

#### Debiab / Ubuntu
On Debian or Ubuntu systems we need the following packages: `screen` and `java`. We can do so by running the following command:
```
apt-get install screen openjdk-17-jdk -y
```

#### Rocky Linux / Almalinux / CentOS
On Rocky Linux, Almalinux or CentOS systems we need the following packages: `epel-release`, `screen` and `java`. We can do so by running the following command:

In order for us to be able to install `screen`, we first need to install `epel-release` by running the following command:
```
dnf install epel-release -y
```

Now we can install both `screen` and `java` by running the following command:
```
dnf install screen java-17-openjdk -y
```
### Installation Instructions
Below, you will find the step-by-step installation instructions.

#### Create Server Files Directory
The directory is used for the server files like the Java jar file, server properties and world data.
```
mkdir -p /etc/mitchellvanbijleveld/minecraft-server
```

#### Download the Minecraft Server Jar and Minecraft Server Service Files
```
wget -O /etc/mitchellvanbijleveld/minecraft-server/minecraft-server.jar https://[latest server url]/server.jar
wget -O /etc/systemd/system/minecraft-server.service https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/minecraft-server.service
```

#### Enable Server on system boot
```
sudo systemctl daemon-reload
sudo systemctl enable minecraft-server
```

#### Accept EULA
```
echo "eula=true" > /etc/mitchellvanbijleveld/minecraft-server/eula.txt
```

#### Start Minecraft Server Service
```
sudo systemctl start minecraft-server
```

#### Connect to Screen session
```
screen -r MinecraftServer
```

## To DO
- Add support for macOS.
- Add support for selecting the server version to be installed.
- Add support for changing the amount of RAM assigned to the server.
