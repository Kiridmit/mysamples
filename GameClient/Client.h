#pragma once
#include "ClientNet.h"

class ClientNet;

class Client {
public:
    void Start();
	void Response(const clan::NetGameEvent &e);
	void Request(const clan::NetGameEvent &e);
	void Update(int ms);
    void UserInpit();
private:
    bool in_game;
    int location_id;
	ClientNet client_net;
	clan::Slot responseSlot;
};