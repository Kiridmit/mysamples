
//#include <iostream>
#include <ClanLib\core.h>
#include <ClanLib\application.h>
#include <string>
#include <vector>
#include <ClanLib\network.h>
#include "Server.h"

int main(const std::vector<std::string> &args) {
	clan::SetupCore setup_core;
	clan::SetupNetwork setup_network;
    //clan::ConsoleWindow console("asdsad");
    //clan::Console c();
    //clan::Console::write_line("dasdasdasasdads", " sdas", " ", 3.65);
    //console.display_close_message();
    std::cout << "asdasd";
    Server server;
    server.Start();
	return 0;
}

clan::Application app(&main, true);