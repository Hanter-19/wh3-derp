-- https://chadvandy.github.io/tw_modding_resources/WH3/campaign/campaign_manager.html#function:campaign_manager:add_faction_turn_start_listener_by_name
-- https://chadvandy.github.io/tw_modding_resources/WH3/campaign/core.html

--[[
campaign_manager:add_faction_turn_start_listener_by_name(
  string listener name,
  string faction name,
  function callback,
  boolean persistent
)
--]]

--[[
campaign_manager:add_immortal_character_defeated_listener(
  string listener name,
  function battle condition,
  function callback,
  [boolean fire if faction destroyed]
)
--]]

local derp = hanter_derp;
local const = hanter_derp.const;
local logger = derp.logger;
local function log(text)
    logger:log("!derp_listeners.lua",text);
end

-- Was Character (by CQI) involved in a battle? (can be primary/secondary attacker/defender)
local function was_character_by_cqi_invovled_in_pending_battle_cache(cqi)
    return cm:pending_battle_cache_char_is_involved(cm:get_character_by_cqi(cqi));
end


-- cm:get_region_data_at_position();

-- Get details of Character's (by CQI) involvement in a recent battle (the character must have survived it)
local function get_character_by_cqi_involvement_in_pending_battle_cache(cqi) 

    local name = logger:tostring_character_name_and_cqi(cqi);

    local was_attacker = false;
    local was_defender = false;
    local was_winner = false;
    local was_loser = false;
    local was_tied = false;
    local result = "result unknown";
    local role = "none";
    local importance = "primary";
    
    if cm:pending_battle_cache_num_attackers() > 0 then
        for i=1,cm:pending_battle_cache_num_attackers() do
            if cm:pending_battle_cache_get_attacker(i)==cqi then
                if i>1 then 
                    importance = "secondary";
                end
                if cm:pending_battle_cache_attacker_victory() then
                    was_winner = true;
                end
                if cm:pending_battle_cache_defender_victory() then
                    was_loser = true;
                end
                was_attacker = true;
                role = "attacker";
                break;
            end
        end
    end

    if was_attacker==false and cm:pending_battle_cache_num_defenders() > 0 then
        for i=1,cm:pending_battle_cache_num_defenders() do
            if cm:pending_battle_cache_get_defender(i)==cqi then
                if i>1 then 
                    importance = "secondary";
                end
                if cm:pending_battle_cache_attacker_victory() then
                    was_winner = true;
                end
                if cm:pending_battle_cache_defender_victory() then
                    was_loser = true;
                end
                was_defender = true;
                role = "defender"
                break;
            end
        end
    end

    if was_winner then
        result = "won";
    elseif was_loser then
        result = "lost";
    elseif was_attacker or was_defender then
        was_tied = true;
        result = "tied";
    end

    if not(was_attacker or was_defender) then
        log(name.." was not involved in the battle"); 
    else
        log(name.." was involved in the battle as a "..logger:tostring_square_brackets(importance)..logger:tostring_square_brackets(role).." and "..logger:tostring_square_brackets(result));
    end
    
    return {
        involved = was_attacker or was_defender,
        role = role,
        importance = importance,
        result = result,
    };
end

local function setup_listeners()

    -- Custom Event: Faction Leader completes a battle
    core:declare_lookup_listener(
        "character_completed_battle_character_subtype_key",
        "CharacterCompletedBattle",
        function(context) return context:character():character_subtype_key() end
    );
    core:add_lookup_listener_callback(
        "character_completed_battle_character_subtype_key",
        "derp_FactionLeaderCompletedBattle",
        -- "wh_main_emp_karl_franz",
        cm:get_faction(derp.const.player_faction):faction_leader():character_subtype_key(),
        function(context)
            log("Triggering ScriptedEventFactionLeaderCompletedBattle");
            get_character_by_cqi_involvement_in_pending_battle_cache(cm:get_faction(derp.const.player_faction):faction_leader():command_queue_index()); 
            core:trigger_custom_event(
                "ScriptedEventFactionLeaderCompletedBattle",
                {
                    ["pending_battle"] = context:pending_battle(),
                    ["character"] = context:character(),
                }
            );
        end,
        true
    );

    -- Custom Event: Ogre Camp Destroyed Dilemma Choice
    -- core:add_listener(
    --     "derp_ogre_camp_destroyed_dilemma_choice_custom",
    --     const.scriptevent_do_modify_fealty,
    --     true,
    --     function(context)
    --         -- Third choice may modify Elector Count fealty and add units to their army
    --     end,
    --     true
    -- )
end

cm:add_first_tick_callback(
    function()
        if cm:get_saved_value("hanter_derp_loaded") then
            log("DERP mod previously loaded.");
            -- return; -- listeners are not saved
        end

        log("Setting up listeners");
        setup_listeners();

        cm:set_saved_value("hanter_derp_loaded", true);
    end
);

-- Karl Franz defeats first Separatist Army
core:add_listener(
    "derp_KarlFranzDefeatsFirstSeparatistArmy",
    "ScriptedEventKarlFranzCompletedBattle",
    function(context)
        return cm:pending_battle_cache_faction_lost_battle("wh_main_emp_empire_separatists")
            and cm:pending_battle_cache_faction_won_battle(derp.const.player_faction)
    end,
    function(context)
        log("Karl Franz defeated first Separatist army");
    end,
    false
);