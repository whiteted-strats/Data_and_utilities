require "Data\\Data"
require "Data\\GE\\PositionData"

GuardData = Data.create()

GuardData.start_pointer_address = 0x02CC64
GuardData.capacity_address = 0x2CC68
GuardData.size = 0x1DC
GuardData.fadeout_length = 90
GuardData.metadata =
{
	{["offset"] = 0x000, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "id"},
	{["offset"] = 0x004, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "rounds_fired_left"},
	{["offset"] = 0x005, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "rounds_fired_right"},
	{["offset"] = 0x006, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "head_model"},	-- 0xFF = Special character (Natalya, Trevelyan etc...)
	{["offset"] = 0x007, ["size"] = 0x1, ["type"] = "enum", 	["name"] = "current_action"},
	{["offset"] = 0x00A, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "shots_near"},
	{["offset"] = 0x00B, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "shots_hit"},
	{["offset"] = 0x00C, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "alpha"},	
	{["offset"] = 0x00F, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "body_model"},
	{["offset"] = 0x010, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "belligerency"},
	{["offset"] = 0x018, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "position_data_pointer"},
	{["offset"] = 0x01C, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "model_data_pointer"},	
	{["offset"] = 0x024, ["size"] = 0x4, ["type"] = "float", 	["name"] = "collision_radius"},	
	{["offset"] = 0x02C, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "fadeout_timer"},
	{["offset"] = 0x02C, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "bond_position"},
	{["offset"] = 0x03C, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "path_target_position"},

	-- Various movement data
	{["offset"]= 0x05c, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "moving_flags"},
	{["offset"] = 0x060, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "target_position"},
	{["offset"] = 0x070, ["size"] = 0x4, ["type"] = "float", 	["name"] = "path_segment_coverage"},
	{["offset"] = 0x074, ["size"] = 0x4, ["type"] = "float", 	["name"] = "path_segment_length"},
	{["offset"] = 0x084, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "chase_timer"},
	
	{["offset"] = 0x094, ["size"] = 0x4, ["type"] = "float", 	["name"] = "segment_coverage"},
	{["offset"] = 0x098, ["size"] = 0x4, ["type"] = "float", 	["name"] = "segment_length"},
	{["offset"] = 0x09C, ["size"] = 0x4, ["type"] = "unsigned",	["name"] = "last_moving_visible_time"},
	{["offset"] = 0x0AC, ["size"] = 0x4, ["type"] = "float", 	["name"] = "clipping_height"},
	{["offset"] = 0x0BC, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "position"},
	{["offset"] = 0x0D0, ["size"] = 0x4, ["type"] = "float", 	["name"] = "reaction_time"},	
	{["offset"] = 0x0D4, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "last_bond_detection_time"},		
	{["offset"] = 0x0EC, ["size"] = 0x4, ["type"] = "float", 	["name"] = "hearing_ability"},	
	{["offset"] = 0x0FC, ["size"] = 0x4, ["type"] = "float", 	["name"] = "damage_received"},
	{["offset"] = 0x100, ["size"] = 0x4, ["type"] = "float", 	["name"] = "health"},
	{["offset"] = 0x104, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "action_block_pointer"},
	{["offset"] = 0x108, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "action_block_offset"},
	{["offset"] = 0x10A, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "action_block_return"},
	{["offset"] = 0x10C, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "user_byte_1"},
	{["offset"] = 0x10D, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "user_byte_2"},
	{["offset"] = 0x10F, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "random_value"},
	{["offset"] = 0x110, ["size"] = 0x1, ["type"] = "unsigned",	["name"] = "timer"},
	{["offset"] = 0x114, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "2328_preset"},

	{["offset"] = 0x11C, ["size"] = 0x8, ["type"] = "vector",	["name"] = "north_collision"},
	{["offset"] = 0x124, ["size"] = 0x8, ["type"] = "vector",	["name"] = "east_collision"},
	{["offset"] = 0x12C, ["size"] = 0x8, ["type"] = "vector",	["name"] = "south_collision"},
	{["offset"] = 0x134, ["size"] = 0x8, ["type"] = "vector",	["name"] = "west_collision"},

	{["offset"] = 0x160, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "gun_pointer"}
}

function GuardData.get_capacity()
	return mainmemory.read_u32_be(GuardData.capacity_address)
end

function GuardData.get_start_address()
	return (mainmemory.read_u32_be(GuardData.start_pointer_address) - 0x80000000)
end

function GuardData.is_empty(_slot_address)
	return (mainmemory.read_u8(_slot_address + 0x1C) == 0x00)
end

function GuardData.is_clone(_slot_address)
	return (mainmemory.read_u8(_slot_address) == 0x27)
end


function GuardData.get_position(_slot_address)
	local position_data_address = (GuardData:get_value(_slot_address,"position_data_pointer") - 0x80000000)
	
	return PositionData:get_value(position_data_address, "position")
end

-- Gets the 4 collision points, cws from North
-- We rename the components to x and z, correct in the real world
function GuardData.get_collision_diamond(_slot_address)
	local diamond = {}
	for _, prop in ipairs({"north_collision", "east_collision", "south_collision", "west_collision"}) do
		local pnt = GuardData:get_value(_slot_address, prop)
		pnt.z = pnt.y
		pnt.y = nil
		table.insert(diamond,pnt)
	end

	return diamond
end


-- Azimuth angle of the living guard, in radians, from positive z?
--   Passes through structures which we don't understand at all.
function GuardData.azimuth_angle(_slot_address)
	local w_pntr = GuardData.get_w_structure_addr(_slot_address)

	-- Then read float from offset 0x14
	-- Other offsets are 0x20 (identical?) and 0x30 (can differ slightly?) 
	local angle = mainmemory.readfloat(w_pntr+0x14,true)

	return angle
end


function GuardData.get_w_structure_addr(_slot_address)
	local mdp = GuardData:get_value(_slot_address, "model_data_pointer") - 0x80000000
	local w_pntr = mainmemory.read_u32_be(mdp + 0x10) - 0x80000000
	return w_pntr
end