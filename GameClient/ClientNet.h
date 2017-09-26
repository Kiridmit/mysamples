#pragma once
#include <string>
#include <ClanLib/core.h>
#include <ClanLib/network.h>

class ClientNet {
public:
	void Start(std::string ip, std::string port);
	void Stop();
	void Request(const clan::NetGameEvent &e);
	clan::Signal_v1<const clan::NetGameEvent&> &SigResponse();
private:
	void OnConnect();
	void OnDisconnect();
	void OnEvent(const clan::NetGameEvent &e);
private:
    clan::NetGameClient netGameClient;
	clan::Signal_v1<const clan::NetGameEvent&> sigResponse;
	clan::SlotContainer slots;
};

