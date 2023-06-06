-- Boilerplate code --------------------------------------------------------
local derp = hanter_derp;
local const = hanter_derp.const;
local utils = hanter_derp.utils;
local logger = hanter_derp.logger;
local weighted_list = hanter_derp.weighted_list; -- Use our copied weighted_list implementation because model is not created yet

local function log(text)
    hanter_derp.logger:log("hanter_derp_dynamic_start.lua",text);
end
----------------------------------------------------------------------------

local start_x,start_y; -- will be used to track player Faction Leader start position, which is needed for faction intro setup
local final_variant;  -- will be used to call setup() at the start of a new game

local starting_scenarios = {

    scenarios = {

        -- Each scenario should have the following methods:
        -- choose_variant(self) : function that returns a variant
            -- Each variant should have the following:
                -- pos_data : table containing start position data, for example {px=538, py=689, e1x=544, e1y=694, e2x=533, e2y=701}
                -- setup()  : function that performs the setup

        ["start_ogr"] = {
    
            variants = {
                -- px, py : Faction Leader starting logical coordinates
                -- e1x, e1y : Ogre army starting logical coordinates
                -- e2x, e2y : Ogre camp starting logical coordinates
                -- ["reikland"] = {px=518, py=643, e1x = 519, e1y=633, e2x=513, e2y=622}, -- disable reikland for now
                ["middenheim"] = {px=538, py=689, e1x=544, e1y=694, e2x=533, e2y=701},
                ["nordland"] = {px=553, py=730, e1x=554, e1y=740, e2x=538, e2y=737},
                ["ostland"] = {px=637, py=731, e1x=649, e1y=736, e2x=656, e2y=747},
                ["hochland"] = {px=605, py=698, e1x=614, e1y=702, e2x=619, e2y=711},
                ["talabecland"] = {px=607, py=664, e1x=609, e1y=652, e2x=593, e2y=652},
                ["stirland"] = {px=578, py=628, e1x=589, e1y=628, e2x=599, e2y=621},
                ["averland"] = {px=625, py=582, e1x=634, e1y=578, e2x=647, e2y=582},
                ["solland"] = {px=580, py=575, e1x=581, e1y=562, e2x=573, e2y=557},
                ["wissenland"] = {px=549, py=599, e1x=551, e1y=591, e2x=562, e2y=585},
                ["ostermark"] = {px=688, py=667, e1x=691, e1y=675, e2x=702, e2y=675},
            },

            choose_variant = function(self)
                local possible_variants = weighted_list:new();
                for key,_ in pairs(self.variants) do
                    possible_variants:add_item(key,1);
                end
                local chosen_variant = possible_variants:random_select();
                log("Chosen starting variant : "..chosen_variant);
                local variant = {

                    pos_data = self.variants[chosen_variant],

                    setup = function()
                        local values = self.variants[chosen_variant];
                        -- get the owning faction of the Faction Leader's starting region so we can enforce military access
                        local region_owner = cm:get_region_data_at_position(values.px, values.py):region():owning_faction();
                        cm:force_grant_military_access(region_owner:name(),const.player_faction,false);
            
                        -- Move the Faction Leader and enable Imperial Mandate
                        custom_starts:teleport_character_faction_leader(const.player_faction, values.px, values.py);
                        utils.enable_imperial_mandate();
            
                        -- absorb Empire Secessionists (caution: triggers YNE and HKrul's Empire Secessionists dilemmas at next turn)
                        custom_starts:absorb_other_faction(const.faction_empire, const.faction_secessionists);
            
                        -- spawn Ogre army
                        cm:create_force_with_general(
                            "wh3_main_ogr_ogre_kingdoms_invasion",
                            "wh3_main_ogr_inf_gnoblars_0,wh3_main_ogr_inf_gnoblars_0,wh3_main_ogr_inf_gnoblars_0,wh3_main_ogr_inf_gnoblars_0,wh3_main_ogr_mon_sabretusk_pack_0,wh3_main_ogr_inf_ogres_0,wh3_main_ogr_inf_ogres_0,wh3_main_ogr_inf_ogres_2",
                            cm:get_region_data_at_position(values.e1x,values.e1y):region():name(),
                            values.e1x,
                            values.e1y,
                            "general",
                            "wh3_main_ogr_tyrant",
                            "",
                            "",
                            "",
                            "",
                            false,
                            function(cqi)
                                cm:set_force_has_retreated_this_turn(cm:get_character_by_cqi(cqi):military_force());
                                log("Ogre Army created with char cqi:" .. cqi);
                            end
                        );
            
                        -- spawn Ogre camp
                        local camp_general_cqi;
                        cm:create_force_with_general(
                        "wh3_main_ogr_ogre_kingdoms_invasion",
                        "wh3_main_ogr_inf_gnoblars_0,wh3_main_ogr_inf_gnoblars_0,wh3_main_ogr_inf_gnoblars_0,wh3_main_ogr_inf_gnoblars_1,wh3_main_ogr_inf_ogres_1,wh3_main_ogr_inf_ogres_2",
                        cm:get_region_data_at_position(values.e2x,values.e2y):region():name(),
                        values.e2x,
                        values.e2y,
                        "general",
                        "wh3_main_ogr_tyrant_camp",
                        "",
                        "",
                        "",
                        "",
                        false,
                        function(cqi)
                            local mf_interface = cm:get_character_by_cqi(cqi):military_force();
                            cm:force_character_force_into_stance(cm:char_lookup_str(cqi), "MILITARY_FORCE_ACTIVE_STANCE_TYPE_FIXED_CAMP");
                            cm:add_building_to_force(mf_interface:command_queue_index(), 
                                {
                                    "wh3_main_ogr_camp_town_centre_2",
                                    "wh3_main_ogr_camp_barracks_1",
                                    "wh3_main_ogr_camp_cav_1"
                                }
                            );
                            camp_general_cqi = cqi;
                            log("Ogre Camp created with char cqi: [" .. cqi .. "] and force cqi: [" .. mf_interface:command_queue_index() .. "]");
                        end
                        );
            
                        -- Set the Ogres to be at war with the player
                        cm:force_declare_war(const.faction_incursion_ogre,const.player_faction,false,false);
            
                        -- Prepare Dilemma for destroying Ogre Camp
                        core:add_listener(
                            "derp_ogre_camp_destroyed",
                            "CharacterConvalescedOrKilled",
                            function(context)
                                local character = context:character();
                                return character:faction():name()==const.faction_incursion_ogre and character:character_subtype("wh3_main_ogr_tyrant_camp") and character:command_queue_index()==camp_general_cqi and cm:pending_battle_cache_human_victory();
                            end,
                            function(context)
                                local region_key = context:character():region():name();
                                log("CharacterConvalescedOrKilled for Ogre Camp in region : "..region_key);
                                local dilemma_builder = cm:create_dilemma_builder(const.dilemma_incursion_ogr_camp);
                                local payload_builder = cm:create_payload();
                                local mf = cm:get_military_force_by_cqi(utils.get_first_player_force_cqi_from_pending_battle_cache());
                                -- First Choice (Recruit Ogre Mercenaries)
                                local mercenary_reward = utils.get_ogre_camp_mercenaries_reward();
                                payload_builder:add_unit(mf,mercenary_reward,1,7);
                                log("Ogre Mercenary reward : "..mercenary_reward);
                
                                dilemma_builder:add_choice_payload("FIRST", payload_builder);
                                payload_builder:clear();
                
                                -- Second Choice (Recruit EC Troops)
                                -- local troop_reward = utils.get_ec_state_troop_rescue_reward_by_province(cm:get_region(region_key):province_name());
                                local troop_reward = utils.get_ec_state_troop_rescue_inf_reward_and_faction();
                                payload_builder:add_unit(mf,troop_reward.unit,troop_reward.num,0);
                                log("Rescued Prisoners reward : "..troop_reward.unit.. " | "..troop_reward.faction);
                
                                dilemma_builder:add_choice_payload("SECOND", payload_builder);
                                payload_builder:clear();
                
                                -- Third Choice (Prestige and Fealty)
                                local is_fealty_affected = false;
                                if troop_reward.faction ~= const.player_faction and not cm:get_faction(troop_reward.faction):is_dead() then
                                    log("Fealty reward possible : "..troop_reward.faction);
                                    is_fealty_affected = true;
                                    payload_builder:faction_pooled_resource_transaction("emp_prestige","events",1000,false);
                                    payload_builder:text_display("dummy_elector_loyalty_increase_2");
                                    payload_builder:text_display("dummy_derp_join_ec_army_2");
                                    dilemma_builder:add_target("target_faction_2",cm:get_faction(troop_reward.faction)); -- target faction for fealty bonus
                                    -- dilemma_builder:add_target("target_character_1",cm:get_faction(troop_reward.faction):faction_leader());
                                else
                                    log("Fealty reward not possible; Setting higher Prestige reward instead");
                                    payload_builder:faction_pooled_resource_transaction("emp_prestige","events",3000,false);
                                end
                
                                dilemma_builder:add_choice_payload("THIRD", payload_builder);
                                payload_builder:clear();
                
                                -- Fourth Choice (Money and Resource)
                                payload_builder:treasury_adjustment(5000);
                                if derp.mods.fine_steel then
                                    log("Dirty Dan's Imperial Armoury detected. Adding Fine Steel to rewards");
                                    payload_builder:faction_pooled_resource_transaction("dd_fine_steel","other",50,false);
                                end
                
                                dilemma_builder:add_choice_payload("FOURTH", payload_builder);
                                payload_builder:clear();
                
                                dilemma_builder:add_target("default",cm:get_faction(const.player_faction));
                                cm:launch_custom_dilemma_from_builder(dilemma_builder,cm:get_faction(const.player_faction));
                                
                                -- Prepare listener for dilemma choice (only needed when fealty is affected)
                                if is_fealty_affected then
                                    core:add_listener(
                                    "derp_ogre_camp_destroyed_dilemma_choice",
                                    "DilemmaChoiceMadeEvent",
                                    function(context)
                                        if context:dilemma()==const.dilemma_incursion_ogr_camp then
                                            log("Dilemma choice for ["..const.dilemma_incursion_ogr_camp.."] : "..context:choice())    
                                        end
                                        -- THIRD choice (index=2) affects fealty
                                        return context:dilemma()==const.dilemma_incursion_ogr_camp and context:choice()==2;
                                    end,
                                    function(context)
                                        --[[
                                        core:trigger_custom_event(
                                            const.scriptevent_do_modify_fealty,
                                            {
                                                target_faction_key = troop_reward.faction,
                                                value = 1,
                                            }
                                        );
                                        core:trigger_custom_event(
                                            const.scriptevent_do_add_units_to_army,
                                            {
                                                target_character_lookup = cm:char_lookup_str(cm:get_faction(troop_reward.faction):faction_leader()),
                                                units = {{unit=troop_reward.unit,num=troop_reward.num},}
                                            }
                                        )
                                        log("Triggered Custom Event : "..const.scriptevent_do_modify_fealty);
                                        --]]
                                        log("Modifying Fealty for : "..troop_reward.faction);
                                        empire_modify_elector_loyalty(troop_reward.faction,"events",1);
                                        log("Adding rescued units to Faction Leader of : "..troop_reward.faction);
                                        for i=1,troop_reward.num do
                                            cm:grant_unit_to_character(cm:char_lookup_str(cm:get_faction(troop_reward.faction):faction_leader()),troop_reward.unit);
                                        end
                                    end,
                                    false
                                )
                                end

                                log("Launched dilemma : "..const.dilemma_incursion_ogr_camp);
                            end,
                            false
                        );
                    end,

                }
                return variant
            end,

        }

    },

    choose_scenario = function(self)
        local possible_scenarios = weighted_list:new();
        for key,_ in pairs(self.scenarios) do
            possible_scenarios:add_item(key,1)
        end
        local chosen_scenario = possible_scenarios:random_select();
        log("Chosen starting scenario : "..chosen_scenario);
        return self.scenarios[chosen_scenario];
    end,
    

}

local get_starting_scenario = function()
    -- TODO: Implement the methods used below
    local scenario = starting_scenarios:choose_scenario();
    final_variant = scenario:choose_variant();
    local pos_data = final_variant.pos_data;
    start_x = pos_data.px;
    start_y = pos_data.py;
end

get_starting_scenario();

-- Information for starting scenario, will be used to place the camer in the faction intro (see /script/campaign/main_warhammer/faction_intro)
derp.start = {

    start_lx = start_x,
    start_ly = start_y,

    get_start_dx = function(self)
        local x,_ = cm:log_to_dis(self.start_lx,self.start_ly);
        return x;
    end,
    get_start_dy = function(self)
        local _,y = cm:log_to_dis(self.start_lx,self.start_ly);
        return y;
    end,
}

cm:add_first_tick_callback_new(
    function()
        if not cm:is_faction_human(const.player_faction) then
            return;
        end
        final_variant.setup();
    end
);

-- For debugging
derp_trigger_new_start = function()
    cm:kill_all_armies_for_faction(cm:get_faction("wh3_main_ogr_ogre_kingdoms_invasion"));
    get_starting_scenario();
    final_variant.setup();
end;