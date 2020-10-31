require "Data\\Data"

PresetData = Data.create()
PresetData.size = 0x44
PresetData.start_address = 0x075d1c
PresetData.end_address = 0x075d0c	-- just by eye on frig/statue, points to after an entirely zeroed preset

PresetData.metadata = {
	-- Structure largely confirmed by 7f03f598

	{["offset"] = 0x0, ["size"] = 0xC, ["type"] = "vector", 		["name"] = "position"},
	{["offset"] = 0xC, ["size"] = 0xC, ["type"] = "vector", 		["name"] = "normal_x"},
	{["offset"] = 0x18, ["size"] = 0xC, ["type"] = "vector", 		["name"] = "normal_y"},
	--{["offset"] = 0x24, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "unknown"},	-- seems to be a pointer
	{["offset"] = 0x28, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "tile_pointer"},
	-- normal_z = normal_x X normal_y, cross product
	{["offset"] = 0x2C, ["size"] = 0x4, ["type"] = "float", 		["name"] = "low_z"},	
	{["offset"] = 0x30, ["size"] = 0x4, ["type"] = "float", 		["name"] = "high_z"},
	{["offset"] = 0x34, ["size"] = 0x4, ["type"] = "float", 		["name"] = "low_x"},
	{["offset"] = 0x38, ["size"] = 0x4, ["type"] = "float", 		["name"] = "high_x"},
	{["offset"] = 0x3C, ["size"] = 0x4, ["type"] = "float", 		["name"] = "low_y"},
	{["offset"] = 0x40, ["size"] = 0x4, ["type"] = "float", 		["name"] = "high_y"},
}

function PresetData.get_start_address()
	return memory.read_u32_be(PresetData.start_address) - 0x80000000
end
function PresetData.get_end_address()
	return memory.read_u32_be(PresetData.end_address) - 0x80000000 - 0x44
end

function PresetData.getPresetAddrFromNum(preset_num)
	-- Only allowed for 0x27XX (100YY) pads
	-- but in some places (i.e. door data) these are stored with 10000 already subtracted off
	-- So we are accomodating (as the GE code is iirc)
	if (preset_num >= 10000) then
		preset_num = preset_num - 10000
	end
	return PresetData.get_start_address() + 0x44 * preset_num
end 


-- TODO : move other stuff in