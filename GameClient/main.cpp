#include <string>
#include <vector>
#include <ClanLib\core.h>
#include <ClanLib\application.h>
#include <ClanLib\display.h>
#include <ClanLib\network.h>
#include "Client.h"

int main(const std::vector<std::string> &args) {
	clan::SetupCore setup_core;
	clan::SetupNetwork setup_network;

	Client client;
	client.Start();
	return 0;
}

clan::Application app(&main, true);