#pragma once
#include <string>
#include <vector>

class Location {
public:
    std::string name;
	std::string type;
	int x;
	int y;
	int size;
    int hp_boost;
    std::vector<int> links;
};