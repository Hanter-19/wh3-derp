-- TODO: make sure this script only gets run where applicable

local log = function(text)
    hanter_derp.logger:log("!derp_config.lua",text);
end

-- Constants for easier coding
-- Felt cute; might move to a separate file later idk
hanter_derp.const = {
    karl_franz_character_subtype_key = "wh_main_emp_karl_franz",
    player_faction = "wh_main_emp_empire",
    
    -- Factions
    faction_empire = "wh_main_emp_empire",
    faction_secessionists = "wh_main_emp_empire_separatists",
    faction_incursion_ogre = "wh3_main_ogr_ogre_kingdoms_invasion",

    -- Effect Bundles
    effect_bundle_imperial_mandate = "derp_imperial_mandate",

    -- Dilemmas
    dilemma_incursion_ogr_camp = "derp_incursion_ogr_ogre_camp",

    -- Custom Scripted Events
    scriptevent_do_modify_fealty = "ScriptEventDoModifyFealty",
    scriptevent_do_add_units_to_army = "ScriptEventDoAddUnitsToArmy"
}

hanter_derp.map = {
    ec_faction_map = {
        ["wh_main_emp_empire"] = {province="wh3_main_combi_province_reikland",shortname="reikland",},
        ["wh2_dlc13_emp_golden_order"] = {province="wh3_main_combi_province_solland",shortname="golden",},
        ["wh_main_emp_averland"] = {province="wh3_main_combi_province_averland",shortname="averland",},
        ["wh_main_emp_hochland"] = {province="wh3_main_combi_province_hochland",shortname="hochland",},
        ["wh_main_emp_middenland"] = {province="wh3_main_combi_province_middenland",shortname="middenland",},
        ["wh_main_emp_nordland"] = {province="wh3_main_combi_province_nordland",shortname="nordland",},
        ["wh_main_emp_ostermark"] = {province="wh3_main_combi_province_ostermark",shortname="ostermark",},
        ["wh_main_emp_ostland"] = {province="wh3_main_combi_province_ostland",shortname="ostland",},
        ["wh_main_emp_stirland"] = {province="wh3_main_combi_province_stirland",shortname="stirland",},
        ["wh_main_emp_talabecland"] = {province="wh3_main_combi_province_talabecland",shortname="talabecland",},
        ["wh_main_emp_wissenland"] = {province="wh3_main_combi_province_wissenland",shortname="wissenland",},
    }
}

cm:add_pre_first_tick_callback(
    function(context)
        for i, faction_key in pairs(cm:get_human_factions()) do
            if faction_key=="wh_main_emp_empire" then
                if hanter_derp==nil then
                    hanter_derp = {};
                end
                
                hanter_derp.config = {};
                
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
                };
                
                if hanter_derp.mods.sylvania then
                    log("graetor's Sylvania Overhaul mod detected. Adding mixer_emp_sylvania to ec_faction_province_map");
                    ec_faction_province_map["mixer_emp_sylvania"] = "wh3_main_combi_province_northern_sylvania";
                    log("graetor's Sylvania Overhaul mod detected. Adding mixer_emp_sylvania to ec_faction_map");
                    hanter_derp.map.ec_faction_map["mixer_emp_sylvania"] = {province="wh3_main_combi_province_northern_sylvania",shortname="sylvania"};
                end

                if hanter_derp.mods.solland then
                    log("graetor's Solland Overhaul mod detected. Updating ec_faction_map to use short_name=\"solland\"");
                    hanter_derp.map.ec_faction_map["wh2_dlc13_emp_golden_order"].shortname = "solland";
                end
                
                hanter_derp.config.ec_faction_province_map = ec_faction_province_map;
            end
        end

    end
);

