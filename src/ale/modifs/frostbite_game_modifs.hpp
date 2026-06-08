#include "modifs.hpp"

namespace ale {

class FrostbiteGameModifs : public GameModifs {
public:
    FrostbiteGameModifs() {
        reset_registry_["last_life"] = [this](ALEInterface & ale) { this->last_life(ale); };
        reset_registry_["full_igloo"] = [this](ALEInterface & ale) { this->full_igloo(ale); };
        reset_registry_["one_remaining_igloo"] = [this](ALEInterface & ale) { this->one_remaining_igloo(ale); };
        reset_registry_["half_igloo"] = [this](ALEInterface & ale) { this->half_igloo(ale); };
        reset_registry_["bailey_right_at_the_igloo_door"] = [this](ALEInterface & ale) { this->bailey_right_at_the_igloo_door(ale); };
        reset_registry_["bailey_very_near_igloo_door"] = [this](ALEInterface & ale) { this->bailey_very_near_igloo_door(ale); };
        reset_registry_["bailey_near_igloo_door"] = [this](ALEInterface & ale) { this->bailey_near_igloo_door(ale); };
	reset_registry_["temperature_10"] = [this](ALEInterface & ale) { this->temperature_10(ale); };
	reset_registry_["temperature_20"] = [this](ALEInterface & ale) { this->temperature_20(ale); };

        step_registry_["ice_inactive"] = [this](ALEInterface & ale) { this->ice_inactive(ale); };
        step_registry_["no_birds"] = [this](ALEInterface & ale) { this->no_birds(ale); };
    }
private:
    void last_life(ALEInterface & ale) {
	ale.setRAM(76, 0);
    }
    
    void full_igloo(ALEInterface & ale) {
        ale.setRAM(77, 15);
    }

    void one_remaining_igloo(ALEInterface & ale) {
        ale.setRAM(77, 14);
    }

    void three_remaining_igloo(ALEInterface & ale) {
        ale.setRAM(77, 12);
    }

    void half_igloo(ALEInterface & ale) {
        ale.setRAM(77, 7);
    }

    void bailey_right_at_the_igloo_door(ALEInterface & ale) {
	ale.setRAM(102, 124);
    }

    void bailey_very_near_igloo_door(ALEInterface & ale) {
	auto pos = ale.environment->getEnvironmentRNG().next();
	pos = 108 + pos % (137 - 108);
	ale.setRAM(102, pos);
    }

    void bailey_near_igloo_door(ALEInterface & ale) {
	auto pos = ale.environment->getEnvironmentRNG().next();
	pos = 95 + pos % (150 - 95);
	ale.setRAM(102, pos);
    }
    
    void temperature_10(ALEInterface & ale) {
	ale.setRAM(101, 10);
    }

    void temperature_20(ALEInterface & ale) {
	ale.setRAM(101, 32);
    }
    
    void ice_inactive(ALEInterface & ale) {
	ale.setRAM(43, 152);
	ale.setRAM(44, 152);
	ale.setRAM(45, 152);
	ale.setRAM(46, 152);
    }

    void no_birds(ALEInterface & ale) {
	for (int i = 92; i < 96; ++i) {
            ale.setRAM(i, 0);
	}
    }
};
    
}
