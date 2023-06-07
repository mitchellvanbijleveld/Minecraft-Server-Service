#include <cstdlib>
#include <iostream>
#include <string>

int main(int argc, char* argv[]) {
  std::string script_url = "https://github.mitchellvanbijleveld.dev/Minecraft-Server-Service/minecraft-server-service-installer.sh";
  std::string download_command = "curl " + script_url + " -o script.sh";
  std::system(download_command.c_str());

  std::string run_command = "bash script.sh";
  std::string run_command_original = "script.sh";

  for (int i = 1; i < argc; i++) {
    run_command += " " + std::string(argv[i]);
  }
  std::system(run_command.c_str());
  
  std::string rm_command = "rm -rf script.sh";
  std::system(rm_command.c_str());

  return 0;
}
