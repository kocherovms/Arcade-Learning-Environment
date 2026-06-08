#include "modifs.hpp"
#include "frostbite_game_modifs.hpp"

namespace ale {

using CreatorFunc = std::unique_ptr<GameModifs>(*)();
        
static const std::unordered_map<std::string, CreatorFunc> lookup = {
    {"frostbite", []() -> std::unique_ptr<GameModifs> { return std::make_unique<FrostbiteGameModifs>(); }}
};

class DummyGameModifs : public GameModifs {
public:
    DummyGameModifs() {}
};

std::unique_ptr<GameModifs> create_game_modifs(const std::string& game_name) {
    auto it = lookup.find(game_name);
    
    if (it != lookup.end())
        return it->second(); // Execute the associated lambda

    return std::unique_ptr<DummyGameModifs>();
}
    
}
