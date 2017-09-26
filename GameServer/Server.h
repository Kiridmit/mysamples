#pragma once
#include <vector>
#include <string>
#include "Locations.h"
#include "ServerNet.h"
#include "Player.h"

class Location;

class Server {
public:
    void Start(); // запуск сервера
    void Update(int ms); // обновить таймер. Если пора сделать ход, делает ход
    void Hod(); // ход
	void Request(std::string name, const clan::NetGameEvent &e);
	void Response(std::string name, const clan::NetGameEvent &e);
private:
	std::map<std::string,Player*> players;
	Locations locations; // массив локаций
    int timer; // таймер хода (мс)
    int timer_period; // период таймера (мс)
    int hod;
	clan::Slot receiveSlot;
public:
	ServerNet server_net;

};

