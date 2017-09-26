#pragma once
#include <string>
#include <ClanLib\network.h>

class Account {
public:
	clan::NetGameConnection *connection;
	std::string name;
    std::string password;
};