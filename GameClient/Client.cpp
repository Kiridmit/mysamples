#include "Client.h"
#include <iostream>
#include <string>

#define DEBUG(x) std::cout << x << std::endl

void Client::Start() {
	responseSlot = client_net.SigResponse().connect(this, &Client::Response);
	in_game = false;
	DEBUG("Put server ip:");
	std::string ip;
	ip = "localhost";
	//std::cin >> ip;
	DEBUG("Connection...");
    
	Sleep(1000); clan::KeepAlive::process(1000);
	client_net.Start(ip, "36963");
    
	Sleep(1000); clan::KeepAlive::process(1000);
	Request(clan::NetGameEvent("register", "vasja", "pass"));
    
	Sleep(1000); clan::KeepAlive::process(1000);
	Request(clan::NetGameEvent("login", "vasja", "pass"));

	Sleep(1000); clan::KeepAlive::process(1000);
	Request(clan::NetGameEvent("starinfo", 0));

    Sleep(1000); clan::KeepAlive::process(1000);
	Request(clan::NetGameEvent("logout"));
	
	
	while(true)
	{
		clan::KeepAlive::process(1000);
        UserInpit();
		Update(10);
	}
}

void Client::Response(const clan::NetGameEvent &e) {
	std::string command = e.get_name();
	if (command == "connect") {
		DEBUG("Connected");

	} else if (command == "disconnect") {
		DEBUG("Disconnected");
	
	} else if (command == "register") {
		bool ok = e.get_argument(0);
		DEBUG((ok ? "Register success" : "Register unsuccess"));
	
	} else if (command == "login") {
		bool ok = e.get_argument(0);
		if (ok) {
			in_game = true;
		}
		DEBUG((ok ? "Login success" : "Login unsuccess"));

	} else if (command == "logout") {
		bool ok = e.get_argument(0);
		if (ok) {
			in_game = false;
		}
		DEBUG((ok ? "Logout success" : "Logout unsuccess"));
	
	} else if (command == "starinfo") {
		int star_id = e.get_argument(0);
		std::string star_name = e.get_argument(1);
		int star_x = e.get_argument(2);
		int star_y = e.get_argument(3);
		DEBUG("Receive starinfo: " << star_id << " " << star_name << " " << star_x << " " << star_y);

    } else if (command == "hod") {
        int hod = e.get_argument(0);
        DEBUG("Receive Hod = " << hod);
    }

    if (command == "mystar") {
        int star_id = e.get_argument(0);
        DEBUG("Receive mystar = " << star_id);
        return;
    } 
    if (command == "move") {
        bool ok = (int)e.get_argument(0);
        DEBUG("Receive move " << (ok ? "OK" : "Fail"));
        return;
    } 
    if (command == "nearstars") {
        int num_near_stars = e.get_argument_count();
        DEBUG("Receive nearstars:");
        for (int i = 0; i < num_near_stars; i++) {
            int star_id = e.get_argument(i);
            DEBUG("\t" << star_id);
        }
        return;
    } 
}

void Client::Request(const clan::NetGameEvent &e) {
	client_net.Request(e);
}

void Client::Update(int ms) {
	return;
}

void Client::UserInpit() {
        
    std::string command;
    std::cin >> command;
    if (command == "help") {
        DEBUG("Enter login [name] [pass]; logout;");
    
	} else if (command == "register") {
        std::string name, pass;
        std::cin >> name >> pass;
		Request(clan::NetGameEvent("register", name, pass));
    
	} else if (command == "login") {
        std::string name, pass;
        std::cin >> name >> pass;
		Request(clan::NetGameEvent("login", name, pass));
    
	} else if (command == "logout") {
		Request(clan::NetGameEvent("logout"));
    
	} else if (command == "exit") {
        exit(0);
    
	} else if (command == "starinfo") {
        int starid;
        std::cin >> starid;
		Request(clan::NetGameEvent("starinfo", starid));

    } else if (command == "hod") {
        Request(clan::NetGameEvent("hod"));

    } else if (command == "mystar") {
        Request(clan::NetGameEvent("mystar"));

    } else if (command == "move") {
        int starid;
        std::cin >> starid;
        Request(clan::NetGameEvent("move",starid));

    } else if (command == "nearstars") {
        Request(clan::NetGameEvent("nearstars"));

    } 
}




//#define NET_REGISTER(name,pass) client_net.Request(clan::NetGameEvent("register", name, pass))
//#define NET_LOGIN(name,pass)    client_net.Request(clan::NetGameEvent("login", name, pass))
//#define NET_LOGOUT()            client_net.Request(clan::NetGameEvent("logout"))
//#define NET_STARINFO(star_id)   client_net.Request(clan::NetGameEvent("starinfo", star_id))
