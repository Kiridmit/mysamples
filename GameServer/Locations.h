#pragma once
#include <string>

#include "Location.h"
class Locations
{
public:
	void seed_stars(int radius, int number);
public:
    std::vector<Location*> locations;
};