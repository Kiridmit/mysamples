#include "ServerNet.h"


void ServerNet::Start(std::string port) {
	slots.connect(netGameServer.sig_client_connected(), this, &ServerNet::OnConnect);
	slots.connect(netGameServer.sig_client_disconnected(), this, &ServerNet::OnDisconnect);
	slots.connect(netGameServer.sig_event_received(), this, &ServerNet::OnEvent);
	netGameServer.start(port);
}

void ServerNet::Stop() {
	netGameServer.stop();
}

void ServerNet::Response(std::string name, const clan::NetGameEvent &e) {
	Account *account = accounts[name];
	if (account) {
		clan::NetGameConnection *connection = account->connection;
		if (connection) {
			connection->send_event(e);
		}
	}
}

clan::Signal_v2<std::string, const clan::NetGameEvent&> &ServerNet::SigRequest() {
	return sigRequest;
}

void ServerNet::OnConnect(clan::NetGameConnection *connection) {
	std::cout << "ServerNet: Client connected" << std::endl;
}

void ServerNet::OnDisconnect(clan::NetGameConnection *connection, const std::string &message) {
	Account *account = (Account *)connection->get_data("account");
	if (account) {
		OnLogout(connection);
	}
	std::cout << "ServerNet: Client disconnected" << std::endl;
}

void ServerNet::OnEvent(clan::NetGameConnection *connection, const clan::NetGameEvent &e) {
	std::string command = e.get_name();
	if (command == "register") {
		OnRegister(connection, e.get_argument(0), e.get_argument(1));
	} else if (command == "login") {
		OnLogin(connection, e.get_argument(0), e.get_argument(1));
	} else if(command == "logout") {
		OnLogout(connection);
	} else {
		OnRequest(connection, e);
	}
}

void ServerNet::OnRegister(clan::NetGameConnection *connection, std::string name, std::string password) {
	Account *account = (Account *)connection->get_data("account");
	if (!account) {
		account = accounts[name];
		if (!account) {
			Account *account = new Account();
			account->connection = nullptr;
			account->name = name;
			account->password = password;
			accounts[name] = account;
			connection->send_event(clan::NetGameEvent("register", clan::NetGameEventValue(true)));
			std::cout << "ServerNet: register name: " << name << " pass: " << password << " successed" << std::endl;
			return;
		}
	}
	connection->send_event(clan::NetGameEvent("register", clan::NetGameEventValue(false)));
	std::cout << "ServerNet: register name: " << name << " pass: " << password << " failed" << std::endl;
}

void ServerNet::OnLogin(clan::NetGameConnection *connection, std::string name, std::string password) {
	Account *account = (Account *)connection->get_data("account");
	if (!account) {
		account = accounts[name];
		if (account) {
			if (!account->connection) {
				if (account->password == password) {
					account->connection = connection;
					connection->set_data("account", (void *)account);
					connection->send_event(clan::NetGameEvent("login", clan::NetGameEventValue(true)));
					std::cout << "ServerNet: login name: " << name << " pass: " << password << " successed" << std::endl;
					sigRequest.invoke(name, clan::NetGameEvent("connect"));
					return;
				}
			}
		}
	}
	connection->send_event(clan::NetGameEvent("login", clan::NetGameEventValue(false)));
	std::cout << "ServerNet: login name: " << name << " pass: " << password << " failed" << std::endl;
}

void ServerNet::OnLogout(clan::NetGameConnection *connection) {
	Account *account = (Account *)connection->get_data("account");
	if (account && account->connection) {
		account->connection = nullptr;
		connection->set_data("account", nullptr);
		connection->send_event(clan::NetGameEvent("logout", clan::NetGameEventValue(true)));
		std::cout << "ServerNet: logout name: " << account->name << " sucessed" << std::endl;
		sigRequest.invoke(account->name, clan::NetGameEvent("disconnect"));
		return;
	}
	connection->send_event(clan::NetGameEvent("login", clan::NetGameEventValue(false)));
	std::cout << "ServerNet: logout failed" << std::endl;
}

void ServerNet::OnRequest(clan::NetGameConnection *connection, const clan::NetGameEvent &e) {
	Account *account = (Account *)connection->get_data("account");
	if (account) {
		sigRequest.invoke(account->name, e);
	}
}
