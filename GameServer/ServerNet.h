#pragma once
#include <string>
#include <map>
#include "Account.h"
#include <ClanLib/core.h>
#include <ClanLib/network.h>

class Account;
class ServerNet {
public:
	void Start(std::string port);
	void Stop();
	void Response(std::string name, const clan::NetGameEvent &e);
	clan::Signal_v2<std::string, const clan::NetGameEvent&> &SigRequest();
private:
	// Вопросы серверу от клиента
	void OnConnect(clan::NetGameConnection *connection);
	void OnDisconnect(clan::NetGameConnection *connection, const std::string &message);
	void OnEvent(clan::NetGameConnection *connection, const clan::NetGameEvent &e);
	void OnRegister(clan::NetGameConnection *connection, std::string name, std::string password);
	void OnLogin(clan::NetGameConnection *connection, std::string name, std::string password);
	void OnLogout(clan::NetGameConnection *connection);
	void OnRequest(clan::NetGameConnection *connection, const clan::NetGameEvent &e);
private:
	clan::NetGameServer netGameServer;
	std::map<std::string, Account*> accounts;
	clan::Signal_v2<std::string, const clan::NetGameEvent&> sigRequest;
	clan::SlotContainer slots;
};

