local derp = hanter_derp;
local logger = hanter_derp.logger;
local const = hanter_derp.const;
local function log(text)
    hanter_derp.logger:log("!!hanter_derp_utils.lua",text);
end

hanter_derp.utils = {
    get_first_player_force_cqi_from_pending_battle_cache = function()
        for i=1,cm:pending_battle_cache_num_attackers() do
            if cm:pending_battle_cache_get_attacker_faction_name(i)==const.player_faction then
                local _,mf_cqi,_ = cm:pending_battle_cache_get_attacker(i);
                log("First player force in pending_battle_cache is "..logger:tostring_square_brackets("ATTACKER").." with cqi="..logger:tostring_square_brackets(mf_cqi));
                return mf_cqi;
            end
        end
        for i=1,cm:pending_battle_cache_num_defenders() do
            if cm:pending_battle_cache_get_defender_faction_name(i)==const.player_faction then
                local _,mf_cqi,_ = cm:pending_battle_cache_get_defender(i);
                log("First player force in pending_battle_cache is "..logger:tostring_square_brackets("DEFENDER").." with cqi="..logger:tostring_square_brackets(mf_cqi));
                return mf_cqi;
            end
        end
    end,

    -- Get the Effect value that will be used to match the entry in db/effects_tables
    -- Note that each entry has to be hardcoded in the DB, and currently only the values -2,-1,1,2 are supported
    get_fealty_effect_dummy = function(faction_key,value)
        local shortname = derp.map.ec_faction_map[faction_key].shortname;
        local change;

        if shortname == nil then
            log("[ERROR] get_fealty_effect_dummy() Unable to find short_name for faction_key "..logger:tostring_square_brackets(faction_key).." and value "..logger:tostring_square_brackets(value));
            return nil
        end
        
        if value < 0 then
            change = "minus_"..tostring(math.abs(value));
        else
            change = "plus_"..tostring(math.abs(value));
        end

        return "derp_effect_fealty_"..shortname.."_"..change.."_dummy";

    end,

    -- Apply the Imperial Mandate effect bundle
    enable_imperial_mandate = function(character)
        -- default is Faction Leader
        character = character or cm:get_faction(const.player_faction):faction_leader();
        cm:remove_effect_bundle_from_character(const.effect_bundle_imperial_mandate, character);
        cm:apply_effect_bundle_to_character(const.effect_bundle_imperial_mandate, character,-1);
    end,

    get_ogre_camp_mercenaries_reward = function()
        local options = weighted_list:new();
        weighted_list:add_item("wh3_main_ogr_cav_mournfang_cavalry_2",1);
        weighted_list:add_item("wh3_main_ogr_inf_leadbelchers_0",1);
        weighted_list:add_item("wh3_main_ogr_inf_maneaters_3",1);
        return weighted_list:random_select();
    end,

    get_ec_state_troop_rescue_inf_reward_and_faction = function()
        local options = weighted_list:new();
        options:add_item({unit="wh2_dlc13_emp_inf_greatswords_ror_0",num=1,faction="wh_main_emp_empire"},1);
        options:add_item({unit="wh2_dlc13_emp_inf_spearmen_ror_0",num=1,faction="wh2_dlc13_emp_golden_order"},1);
        options:add_item({unit="wh2_dlc13_emp_inf_handgunners_ror_0",num=1,faction="wh_main_emp_hochland"},1);
        options:add_item({unit="wh2_dlc13_emp_inf_swordsmen_ror_0",num=1,faction="wh_main_emp_middenland"},1);
        options:add_item({unit="wh2_dlc13_emp_inf_halberdiers_ror_0",num=1,faction="wh_main_emp_nordland"},1);
        options:add_item({unit="wh2_dlc13_emp_inf_crossbowmen_ror_0",num=1,faction="wh_main_emp_stirland"},1);
        return options:random_select();
    end,

    get_ec_state_troop_rescue_reward_by_faction = function(faction_key)

        local map = {
            ["wh_main_emp_empire"] = {unit="wh2_dlc13_emp_inf_greatswords_ror_0",num=1},
            ["wh2_dlc13_emp_golden_order"] = {unit="wh2_dlc13_emp_inf_spearmen_ror_0",num=2},
            ["wh_main_emp_averland"] = {unit="wh2_dlc13_emp_cav_pistoliers_ror_0",num=1},
            ["wh_main_emp_hochland"] = {unit="wh2_dlc13_emp_inf_handgunners_ror_0",num=1},
            ["wh_main_emp_middenland"] = {unit="wh2_dlc13_emp_inf_swordsmen_ror_0",num=2},
            ["wh_main_emp_nordland"] = {unit="wh2_dlc13_emp_inf_halberdiers_ror_0",num=2},
            ["wh_main_emp_ostermark"] = {unit="wh2_dlc13_emp_cav_empire_knights_ror_0",num=1},
            ["wh_main_emp_ostland"] = {unit="wh2_dlc13_emp_cav_empire_knights_ror_2",num=1},
            ["wh_main_emp_stirland"] = {unit="wh2_dlc13_emp_inf_crossbowmen_ror_0",num=2},
            ["wh_main_emp_talabecland"] = {unit="wh2_dlc13_emp_art_mortar_ror_0",num=1},
            ["wh_main_emp_wissenland"] = {unit="wh2_dlc13_emp_veh_steam_tank_driver_ror_0",num=1},
            -- Graetor's Sylvania
            ["mixer_emp_sylvania"] = {unit="wh_main_emp_cav_noble_archers_0",num=1},
        }
        return map[faction_key];
    end,

    get_ec_state_troop_rescue_reward_by_province = function(province_key)

        local map = {
            ["wh3_main_combi_province_reikland"] = {unit="wh2_dlc13_emp_inf_greatswords_ror_0",num=1},
            ["wh3_main_combi_province_solland"] = {unit="wh2_dlc13_emp_inf_spearmen_ror_0",num=2},
            ["wh3_main_combi_province_averland"] = {unit="wh2_dlc13_emp_cav_pistoliers_ror_0",num=1},
            ["wh3_main_combi_province_hochland"] = {unit="wh2_dlc13_emp_inf_handgunners_ror_0",num=1},
            ["wh3_main_combi_province_middenland"] = {unit="wh2_dlc13_emp_inf_swordsmen_ror_0",num=2},
            ["wh3_main_combi_province_nordland"] = {unit="wh2_dlc13_emp_inf_halberdiers_ror_0",num=2},
            ["wh3_main_combi_province_ostermark"] = {unit="wh2_dlc13_emp_cav_empire_knights_ror_0",num=1},
            ["wh3_main_combi_province_ostland"] = {unit="wh2_dlc13_emp_cav_empire_knights_ror_2",num=1},
            ["wh3_main_combi_province_stirland"] = {unit="wh2_dlc13_emp_inf_crossbowmen_ror_0",num=2},
            ["wh3_main_combi_province_talabecland"] = {unit="wh2_dlc13_emp_art_mortar_ror_0",num=1},
            ["wh3_main_combi_province_wissenland"] = {unit="wh2_dlc13_emp_veh_steam_tank_driver_ror_0",num=1},
        };

        -- Graetor's Sylvania
        if derp.mods.sylvania then
            map["wh3_main_combi_province_northern_sylvania"] = {unit="wh_main_emp_cav_noble_archers_0",num=1};
        end

        return map[province_key];
    end,

}

local ec_faction_province_map = {
    ["wh_main_emp_empire"] = "wh3_main_combi_province_reikland",
    ["wh2_dlc13_emp_golden_order"] = "wh3_main_combi_province_solland",
    ["wh_main_emp_averland"] = "wh3_main_combi_province_averland",
    ["wh_main_emp_hochland"] = "wh3_main_combi_province_hochland",
    ["wh_main_emp_middenland"] = "wh3_main_combi_province_middenland",
    ["wh_main_emp_nordland"] = "wh3_main_combi_province_nordland",
    ["wh_main_emp_ostermark"] = "wh3_main_combi_province_ostermark",
    ["wh_main_emp_ostland"] = "wh3_main_combi_province_ostland",
    ["wh_main_emp_stirland"] = "wh3_main_combi_province_stirland",
    ["wh_main_emp_talabecland"] = "wh3_main_combi_province_talabecland",
    ["wh_main_emp_wissenland"] = "wh3_main_combi_province_wissenland",
    -- Optionals?
    ["wh_main_emp_marienburg"] = "wh3_main_combi_province_the_wasteland",
    ["mixer_emp_sylvania"] = "wh3_main_combi_province_northern_sylvania",
}

-- For possible future use to gauge the strength of a particular Elector Count
function derp_check_ec_owns_province(faction_key)
    local faction_interface = cm:get_faction(faction_key);
    if not faction_interface:is_null_interface() then
        res = faction_interface:holds_entire_province(ec_faction_province_map[faction_key],true);
        log("derp_check_ec_owns_province : "..faction_key.." : "..tostring(res));
        return res;
    else
        log("derp_check_ec_owns_province : "..faction_key.." does not exist");
        return false;
    end
end