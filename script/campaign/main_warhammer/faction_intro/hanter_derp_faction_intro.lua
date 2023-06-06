-- Hanter's note: most of this is boilerplate code from CA, with my customisations

local data = {
    -- Load order defines the order in which each of these tables is loaded, with later loads overwriting the elements of earlier ones.
    -- If this isn't defined, a script will always load last.
    -- If two scripts have an equal load-order, the order becomes alphabetical, based on script name.
    load_order = 0,
    -- A list of functions used to define how a faction's variant might be inferred. A typical example would be determining if we're playing as Karl Franz or Volkmar the Grimm.
    -- variant_key_getters = {
    --     -- ...
    -- },
    -- You can use presets to define bits of intro data which are used by lots of factions.
    -- intro_presets = {
    --     theatre_empire = {
    --         cam_gameplay_start = {
    --             x = 402,
    --             y = 497,
    --             d = 29,
    --             b = 0,
    --             h = 67,
    --         }
    --     },
    -- },
    intro_presets = {
        standard = {
            how_they_play = true,
        }
    },
    -- UI to hide when zooming into the map.
	map_ui = {"campaign_3d_ui", "parchment_overlay", "campaign_flags", "campaign_flags_strength_bars"},
}

data.cutscene_styles = {
	zoom_in_and_speak = function(self)
		local valid, missing_fields = data.validate_data_for_style(self, { "cam_cutscene_start", "advice_line" })
		if not valid then
			script_error("ERROR: Not all data required to use the zoom_in_and_speak cutscene style was present on this faciton intro table. Missing fields: " .. missing_fields)
			return false, missing_fields
		end

		local new_configurator = function(cutscene)
            cutscene:set_relative_mode(true)
            cutscene:action_fade_scene(0, 1, 2)
            cutscene:action_override_ui_visibility(0, false, data.map_ui)
            -- Other functions take xydbk coords but this one takes enumerated ones. Need to translate from one to the other.
            cutscene:action_set_camera_position(0, { self.cam_cutscene_start.x, self.cam_cutscene_start.y, self.cam_cutscene_start.d, self.cam_cutscene_start.b, self.cam_cutscene_start.h })
            cutscene:action_scroll_camera_to_position(1, 8, true, { self.cam_gameplay_start.x, self.cam_gameplay_start.y, self.cam_gameplay_start.d, self.cam_gameplay_start.b, self.cam_gameplay_start.h })
            cutscene:action_show_advice(5, self.advice_line)
            -- Wait for the advisor to finish before proceeding, and then wait 2 seconds to smooth UI transition.
            cutscene:action(
                function()
                    cutscene:wait_for_advisor()
                end,
                2
            );
            cutscene:action_end_cutscene(0)
            -- Clear UI on end or on skip.
            -- The faction intro system already loads up the end-cutscene with other stuff ('How They Play', etc.) before this is called, so we need to prepend the end-cutscene rather than set it outright.
            cutscene:prepend_end_cutscene(
                function()
                    for u = 1, #data.map_ui do
                        cm:get_campaign_ui_manager():override(data.map_ui[u]):set_allowed(true);
                    end;
                end
            )
        end

		return new_configurator
	end
}

data.validate_data_for_style = function(data, required_fields)
	local missing_fields_string = ""

	for f = 1, #required_fields do
		if data[required_fields[f]] == nil then
			local comma_prefix
			if #missing_fields_string > 0 then
				comma_prefix = ", '"
			else
				comma_prefix = "'"
			end
			missing_fields_string = missing_fields_string .. comma_prefix .. required_fields[f] .. "'"

		end
	end

	if #missing_fields_string > 0 then
		return false, missing_fields_string
	else
		return true, nil
	end
end
    
-- This table provides the actual intro data for each faction.
-- Best practise is to define these after you've defined the initial data table, so that you can reference the contents of the data table (including presets)
data.faction_intros = {

    wh_main_emp_empire = faction_intro_data:new{
		preset = data.intro_presets.standard,
        advice_line = "wh3_dlc21_ie_camp_emp_karl_franz_intro_01",
		cutscene_style = data.cutscene_styles.zoom_in_and_speak,
        cam_cutscene_start = {x = hanter_derp.start:get_start_dx(), y = hanter_derp.start:get_start_dy(),	d = 22.456482, b = 0.0,	h = 65.031822,},
        cam_gameplay_start = {x = hanter_derp.start:get_start_dx(), y = hanter_derp.start:get_start_dy(),	d = 6.965149, b = 0, h = 8.008892,},
	},

}
    
return data