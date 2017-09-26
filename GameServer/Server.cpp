#include "server.h"
#include <string>
#include <iostream>

#define DEBUG(x) std::cout << x << std::endl

void Server::Start() {	
    DEBUG("Server: starting");
    timer_period = 10000;
    timer = 0;
    hod = 0;
    locations.seed_stars(500, 10);
	receiveSlot = server_net.SigRequest().connect(this, &Server::Request);
	server_net.Start("36963");
	DEBUG("Server: started");

	while(true)
	{
		clan::KeepAlive::process(10);
		Update(10);
	}
}

void Server::Update(int ms) {
    timer += ms;
    if ( timer > timer_period )
    {
        timer -= timer_period;
        Hod();
    }
}

void Server::Hod() {
    hod++;
    for (std::map<std::string, Player*>::iterator i = players.begin(); i != players.end(); i++) {
        Player *player = i->second;
        if (player->in_game) {
            if (player->move) {
                player->location_id = player->target_location_id;
                player->move = false;
            }
        }
    }
    DEBUG("Server: hod " << hod);
}

void Server::Request(std::string name, const clan::NetGameEvent &e) {
	std::string command = e.get_name();
	Player *player = players[name];     
	if (command == "connect") {
		if (!player) {
			player = new Player();
			player->name = name;
			player->attack = 100;
			player->hp = 100;
			player->in_game = true;
			player->location_id = 0;
            player->move = false;
			player->move_distance = 50;
			players[name] = player;
			DEBUG("Server: player " << name << " connected");
		} else {
			player->in_game = true;
		}
		return;
	} else if (!player || !player->in_game) 
		return;

	// ≈сли игрок в игре:
	if (command == "disconnect") {
		player->in_game = false;
		DEBUG("Server: player " << name << " disconnect");
		return;
	}

	if (command == "starinfo") {
		int star_id = e.get_argument(0);
		Location *location = locations.locations[star_id];
		DEBUG("Server: starinfo ");
		Response(name, clan::NetGameEvent("starinfo", 
			star_id, 
			location->name, 
			(int)location->x, 
			(int)location->y)); //сюда добавить игроков
		return;
	}
    if (command == "hod") {
        DEBUG("Server: " << name << ": hod");
        Response(name, clan::NetGameEvent("hod", hod));
        return;

    } 
    if (command == "mystar") {
        Response(name, clan::NetGameEvent("mystar", player->location_id));
        DEBUG("Server: " << name << " requested mystar: " << player->location_id);
        return;

    } 
    if (command == "move") {
        int star_id = e.get_argument(0);
        player->target_location_id = star_id;
        player->move = true;
        Response(name, clan::NetGameEvent("move", true));
        DEBUG("Server: " << name << " requested move: " << star_id);
        return;

    } 
    if (command == "nearstars") {
        clan::NetGameEvent ee("nearstars");
        for(int i = 0; i < locations.locations.size(); i++) {
            ee.add_argument(i);
        }
        Response(name, ee);
        DEBUG("Server: " << name << ": nearstars ");
        return;

    } 
}

void Server::Response(std::string name, const clan::NetGameEvent &e) {
	Player *player = players[name];
	if (player && player->in_game) {
		server_net.Response(name, e);
	}
}


//#define NET_STARINFO(name, star_id, star_name, star_x, star_y) Response( (name), clan::NetGameEvent("starinfo", (star_id), (star_name), (int)(star_x), (int)(star_y)))

// #define FOR_IN_MAP(type1,type2,obj,i) for (std::map<type1,type2>::iterator i = obj.begin(); i != obj.end(); i++)
// FOR_IN_MAP(std::string, Player*, players, i) {
//     Player *player = i->second;
//}