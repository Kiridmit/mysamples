#pragma once
#include <string>
#include <vector>

class Location {
public:
	std::string name;
    std::string type;
    double size;
    bool respawn;
    int hp_boost;
    double x;
    double y;
};