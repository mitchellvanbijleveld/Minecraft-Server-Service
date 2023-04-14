#include <cstdlib>
#include <iostream>
#include <string>

int main(int argc, char* argv[]) {
  std::string script_url = "https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/minecraft-server-service-installer.sh"; // replace with your script URL
  std::string download_command = "curl " + script_url + " -o script.sh"; // download the script using curl
  std::system(download_command.c_str()); // run the download command using system

  std::string run_command = "bash script.sh"; // run the script using bash

  // append any command line arguments to the run command
  for (int i = 1; i < argc; i++) {
    run_command += " " + std::string(argv[i]);
  }

  std::system(run_command.c_str()); // run the script using system

  return 0;
}
