require "Data\\Data"

ExplosionTypeData = Data.create()

ExplosionTypeData.start_address = 0x040284
ExplosionTypeData.size = 0x40
ExplosionTypeData.type_count = 21
ExplosionTypeData.metadata =
{
	{["offset"] = 0x00, ["size"] = 0x4, ["type"] = "float", 	["name"] = "flame_lateral_spread"},
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "float", 	["name"] = "flame_vertical_spread"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "float", 	["name"] = "flame_lateral_spread"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "flame_vertical_spread"},
	{["offset"] = 0x10, ["size"] = 0x4, ["type"] = "float", 	["name"] = "flame_size"},
	{["offset"] = 0x14, ["size"] = 0x4, ["type"] = "float", 	["name"] = "min_damage_radius"},
	{["offset"] = 0x18, ["size"] = 0x4, ["type"] = "float", 	["name"] = "max_damage_radius"},
	{["offset"] = 0x1C, ["size"] = 0x2, ["type"] = "unsigned", 	["name"] = "animation_length"},
	{["offset"] = 0x20, ["size"] = 0x4, ["type"] = "float", 	["name"] = "animation_speed"},
	{["offset"] = 0x24, ["size"] = 0x2, ["type"] = "unsigned", 	["name"] = "flake_count"},
	{["offset"] = 0x28, ["size"] = 0x4, ["type"] = "float", 	["name"] = "flake_size"},
	{["offset"] = 0x2C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "flake_spread"},
	{["offset"] = 0x30, ["size"] = 0x4, ["type"] = "float", 	["name"] = "flake_lateral_speed"},
	{["offset"] = 0x34, ["size"] = 0x4, ["type"] = "float", 	["name"] = "flake_vertical_speed"},
	{["offset"] = 0x39, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "sound_preset"},
	{["offset"] = 0x3C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "damage_factor"}
}

function ExplosionTypeData.get_value(_type, _name)	
	local type_data_address = (ExplosionTypeData.start_address + (_type * ExplosionTypeData.size))
	
	return ExplosionTypeData.__index.get_value(ExplosionTypeData, type_data_address, _name)
end

ExplosionData = Data.create()

ExplosionData.start_pointer_address = 0x07A144
ExplosionData.size = 0x3E0
ExplosionData.capacity = 6
ExplosionData.no_damage_frame_count = 8
ExplosionData.metadata = 
{
	{["offset"] = 0x000, ["size"] = 0x4, ["type"] = "hex", 			["name"] = "position_data_pointer"},
	{["offset"] = 0x3C8, ["size"] = 0x2, ["type"] = "unsigned", 	["name"] = "animation_frame"},
	{["offset"] = 0x3CA, ["size"] = 0x2, ["type"] = "unsigned", 	["name"] = "next_damage_frame"}, -- 0xFFFF = Continuous damage
	{["offset"] = 0x3CC, ["size"] = 0x1, ["type"] = "hex", 			["name"] = "explosion_type"},
}

function ExplosionData.get_start_address()
	return (mainmemory.read_u32_be(ExplosionData.start_pointer_address) - 0x80000000)
end

function ExplosionData.is_empty(_explosion_address)
	local position_data_address = ExplosionData:get_value(_explosion_address, "position_data_pointer")
	
	return (position_data_address == 0x00000000)
end
