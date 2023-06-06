-- Refresh the logs every time the game is loaded
do
    local logTimeStamp = os.date("%Y-%m-%d %X");

    local popLog = io.open("hanter_log.txt","w+");
    popLog:write("NEW LOG ["..logTimeStamp.."]\n");
    popLog:flush();
    popLog:close();
end

-- core:add_ui_created_callback(    
--     function()
--         if cm:is_new_game() and cm:get_saved_value("hanter_log_refresh") then
--             return;
--         end

--         cm:set_saved_value("hanter_log_refresh", true);

--         if not __write_output_to_logfile then
--             return;
--         end

--         local logTimeStamp = os.date("%Y-%m-%d %X");

--         local popLog = io.open("hanter_log.txt","w+");
--         popLog:write("NEW LOG ["..logTimeStamp.."]\n");
--         popLog:flush();
--         popLog:close();

--     end
-- );

local logger = {}

function logger:log(filename,text)
    if not __write_output_to_logfile then
        return;
    end

    local logTimeStamp = "["..os.date("%Y-%m-%d %X").."]";
    local logContext = "[DERP]";
    local logFilename = "["..tostring(filename).."]";
    local logText = " "..tostring(text);
    local popLog = io.open("hanter_log.txt","a");

    popLog:write(logTimeStamp..logContext..logFilename..logText.."\n");
    popLog:flush();
    popLog:close();
end

function logger:tostring_square_brackets(str)
    return "["..tostring(str).."]";
end

-- Produce pretty string for any given string str and its cqi
function logger:tostring_str_and_cqi(str,cqi)
    return "["..tostring(str).." | cqi="..tostring(cqi).."]";
end

-- Produce pretty string for x-y coordinates
function logger:tostring_coords(x,y)
    return "["..tostring(x)..","..tostring(y).."]";
end

-- Produce pretty string for a character name and their cqi
function logger:tostring_character_name_and_cqi(cqi)
    local char = cm:get_character_by_cqi(cqi);
    local name = common.get_localised_string(char:get_forename()).." "..common.get_localised_string(char:get_surname());
    return self:tostring_str_and_cqi(name,cqi);
end

function logger:tostring_region_province_coords(region,region_cqi,province,x,y)
    return "["..tostring(region).." | cqi="..tostring(region_cqi).."]["..province.."]"..self:tostring_coords(x,y);
end

hanter_derp.logger = logger;