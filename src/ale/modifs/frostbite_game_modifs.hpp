#include "modifs.hpp"

namespace ale {

class FrostbiteGameModifs : public GameModifs {
public:
    FrostbiteGameModifs() {
        reset_registry_["full_igloo"] = [this](ALEInterface & ale) { this->full_igloo(ale); };
        step_registry_["ice_inactive"] = [this](ALEInterface & ale) { this->ice_inactive(ale); };
        step_registry_["no_birds"] = [this](ALEInterface & ale) { this->no_birds(ale); };
    }
private:
    void full_igloo(ALEInterface & ale) {
        // Sets iglo to full at the beginning of the game
        ale.setRAM(77, 15);
    }

    void ice_inactive(ALEInterface & ale) {
        // Sets the ice floes to inactive. This means while the player can still walk on them, they will not give points or contribute to the igloo building progress.
	ale.setRAM(43, 152);
	ale.setRAM(44, 152);
	ale.setRAM(45, 152);
	ale.setRAM(46, 152);
    }

    void no_birds(ALEInterface & ale) {
	// Removes all enemies
	for (int i = 92; i < 96; ++i) {
            ale.setRAM(i, 0);
	}
    }
};
    
}
