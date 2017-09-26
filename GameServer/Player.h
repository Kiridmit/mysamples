#pragma once
#include <string>
class Player
{
public:
	int location_id;
    int target_location_id;
    bool move;
	int move_distance;
	int hp;
	int attack;
	bool in_game;
	std::string name;
};

