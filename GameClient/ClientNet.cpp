#include "ClientNet.h"

void ClientNet::Start(std::string ip, std::string port) {
	slots.connect(netGameClient.sig_connected(), this,  &ClientNet::OnConnect);
	slots.connect(netGameClient.sig_disconnected(), this,  &ClientNet::OnDisconnect);
	slots.connect(netGameClient.sig_event_received(), this,  &ClientNet::OnEvent);
	netGameClient.connect(ip, port);
}

void ClientNet::Stop() {
	netGameClient.disconnect();

}

void ClientNet::Request(const clan::NetGameEvent &e) {
	netGameClient.send_event(e);
}

clan::Signal_v1<const clan::NetGameEvent&> &ClientNet::SigResponse() {
	return sigResponse;
}

void ClientNet::OnConnect() {
	sigResponse.invoke(clan::NetGameEvent("connect"));
}

void ClientNet::OnDisconnect() {
	sigResponse.invoke(clan::NetGameEvent("disconnect"));
}

void ClientNet::OnEvent(const clan::NetGameEvent &e) {
	std::string command = e.get_name();
	if (command != "connect" && command != "disconnect") {
		sigResponse.invoke(e);
	}
}

