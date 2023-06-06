hanter_derp = {};

-- Store all booleans indicating whether any supported mods are active
hanter_derp.mods = {
    fine_steel = vfs.exists("script/campaign/mod/finesteel_ui.lua"),
    sylvania = vfs.exists("script/campaign/mod/sylvania_faction.lua"),
    solland = vfs.exists("script/campaign/mod/eldred_faction.lua"),
};

----------------------------------------------------------------------------
-- Copy-paste and slightly moidfy CA's weighted_list implementation because it is only accessible after model is created, but we may need it earlier than that
local weighted_list = {};

function weighted_list:__tostring()
	return TYPE_WEIGHTED_LIST;
end

function weighted_list:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	self.items = {};
	self.max_weight = 0;
	return o;
end

function weighted_list:add_item(item, weight)
	local list_entry = {};
	list_entry.item = item;
	list_entry.weight = weight;
	table.insert(self.items, list_entry);
	self.max_weight = self.max_weight + weight;
end

function weighted_list:remove_item(i)
	self.max_weight = self.max_weight - self.items[i].weight;
	table.remove(self.items, i);
end

function weighted_list:weighted_select()
	local rand = cm:random_number(self.max_weight);

	for i = 1, #self.items do
		rand = rand - self.items[i].weight;

		if rand <= 0 then
			return self.items[i].item, i;
		end
	end
end

function weighted_list:random_select()
	-- local rand = cm:random_number(#self.items); -- Model is not yet created, so we won't be able to use this
    local rand = math.random(#self.items);
	return self.items[rand].item, rand;
end

hanter_derp.weighted_list = weighted_list;
----------------------------------------------------------------------------