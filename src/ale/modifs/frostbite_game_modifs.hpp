#include "modifs.hpp"

namespace ale {

class FrostbiteGameModifs : public GameModifs {
public:
    FrostbiteGameModifs() {
        reset_registry_["full_igloo"] = [this](ALEInterface & ale) { this->full_igloo(ale); };
    }
private:
    void full_igloo(ALEInterface & ale) {
        // Sets iglo to full at the beginning of the game
        ale.setRAM(77, 15);
    }
};
    
}
