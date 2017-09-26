#include "Locations.h"
#include <iostream>

#define DEBUG(x) std::cout << x << std::endl

void Locations::seed_stars(int radius, int number)
{
    for ( int i = 0; i < number; i++) {
        Location star;
        star.type = "star";
        star.name = "noname_";
        star.name += star.type + "_" + std::to_string(i);
        star.hp_boost = rand() % 150 - 100;
        double r = rand()%(radius*10)/10.0; //убрать звЄзды с концов
        star.size = radius/r;
        double a;
        double k1 = (rand()%200/100.0 - 1)*exp(-pow(r-radius/2,2)/pow(radius/2,2)*2)*1; //добавить гауссово распределеделение по перпендикул€ру
        double k2 = (rand()%200/100.0 - 1)*exp(-pow(r-radius/2,2)/pow(radius/2,2)*2)*1; //

        if (i%5 == 0) {
            a = 2*3.14*(r/radius);
            star.x = r*cos(a) + k1;
            star.y = r*sin(a) + k2;
        } else if(i%5 == 1) {
           a = 2*3.14*(r/radius+0.3333);
           star.x = r*cos(a) + k1;
           star.y = r*sin(a) + k2;
       } else if(i%5 == 2) {
           a = 2*3.14*(r/radius+0.6666);
           star.x = r*cos(a) + k1;
           star.y = r*sin(a) + k2;
        } 
       else {
            double a = 2*3.14*i/number;
            star.x = r*cos(a);
            star.y = r*sin(a);
       }
       locations.push_back(star);
    }
}