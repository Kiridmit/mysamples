#pragma once
#include <vector>
#include <string>
#include "Locations.h"
#include "ServerNet.h"
#include "Player.h"

class Location;

class Server {
public:
    void Start(); // ������ �������
    void Update(int ms); // �������� ������. ���� ���� ������� ���, ������ ���
    void Hod(); // ���
	void Request(std::string name, const clan::NetGameEvent &e);
	void Response(std::string name, const clan::NetGameEvent &e);
private:
	std::map<std::string,Player*> players;
	Locations locations; // ������ �������
    int timer; // ������ ���� (��)
    int timer_period; // ������ ������� (��)
    int hod;
	clan::Slot receiveSlot;
public:
	ServerNet server_net;

};

