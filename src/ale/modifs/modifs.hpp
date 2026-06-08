#ifndef MODIFS_HPP_
#define MODIFS_HPP_

#include <memory>
#include "ale/ale_interface.hpp"

namespace ale {

class GameModifs {
protected:
    using ModifHook = std::function<void(ALEInterface &)>;
    using ModifHookRegistry = std::unordered_map<std::string, ModifHook>;
public:
    virtual ~GameModifs() = default;

    void enable(const std::vector<std::string>& names) {
        active_step_hooks_.clear();
        active_reset_hooks_.clear();

        if (!names.size())
            return;

        std::map<std::string, std::pair<std::vector<ModifHook> *, ModifHookRegistry * > > prefix_map;
        prefix_map["step_"] = std::make_pair(&active_step_hooks_, &step_registry_);
        prefix_map["reset_"] = std::make_pair(&active_reset_hooks_, &reset_registry_);
        
        for (const auto& name : names) {
            size_t underscore_pos = name.find('_');
    
            if (underscore_pos == std::string_view::npos)
                throw std::invalid_argument(std::string("\"") + name + "\" is not a valid modif name. Valid modif name should start with a prefix, e.g. step_xxx or reset_yyy");
    
            size_t prefix_length = underscore_pos + 1;
            const auto prefix = name.substr(0, prefix_length);
            const auto prefix_it = prefix_map.find(prefix);

            if (prefix_it == prefix_map.end())
                throw std::invalid_argument(std::string("Unknown prefix=\"") + prefix + "\" within modif name \"" + name + "\""); 

            const ModifHookRegistry * registry = prefix_it->second.second;
            const auto unprefixed_name = name.substr(prefix_length);
            const auto registry_it = registry->find(unprefixed_name);
            
            if (registry_it == registry->end())
                throw std::runtime_error(std::string("Game modification \"") + name + "\" not found");
            
            prefix_it->second.first->push_back(registry_it->second);
        }
    }

    void apply_step_modifs(ALEInterface & ale) {
        for (const auto& fn : active_step_hooks_) {
            fn(ale);
        }
    }

    void apply_reset_modifs(ALEInterface & ale) {
        for (const auto& fn : active_reset_hooks_) {
            fn(ale);
        }
    }
protected:
    ModifHookRegistry step_registry_;
    ModifHookRegistry reset_registry_;
private:
    std::vector<ModifHook> active_step_hooks_;
    std::vector<ModifHook> active_reset_hooks_;
};

std::unique_ptr<GameModifs> create_game_modifs(const std::string& game_name);
    
}

#endif // MODIFS_HPP_
