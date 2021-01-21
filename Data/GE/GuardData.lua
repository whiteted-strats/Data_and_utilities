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
	{["offset"] = 0x008, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "frames_until_update"},	-- must actually be < 0 to trigger the update
	{["offset"] = 0x00A, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "shots_near"},
	{["offset"] = 0x00B, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "shots_hit"},
	{["offset"] = 0x00C, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "alpha"},	
	{["offset"] = 0x00F, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "body_model"},
	{["offset"] = 0x010, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "belligerency"}, -- Grenade prob
	{["offset"] = 0x012, ["size"] = 0x2, ["type"] = "hex",		["name"] = "flags"},
	{["offset"] = 0x018, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "position_data_pointer"},
	{["offset"] = 0x01C, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "model_data_pointer"},	
	{["offset"] = 0x024, ["size"] = 0x4, ["type"] = "float", 	["name"] = "collision_radius"},
	{["offset"] = 0x028, ["size"] = 0x4, ["type"] = "float", 	["name"] = "collision_height"},

	-- Unions galore here
	{["offset"] = 0x02C, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "fadeout_timer"},
	{["offset"] = 0x02C, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "bond_position"},
	{["offset"] = 0x038, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "target_tile"},
	{["offset"] = 0x03C, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "target_pad"},
	{["offset"] = 0x03C, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "path_target_position"},

	-- Array of size 6, so -> 0x58
	{["offset"] = 0x040, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "path_stack"},
	{["offset"] = 0x058, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "path_stack_index"},
	{["offset"] = 0x059, ["size"] = 0x1, ["type"] = "enum", 	["name"] = "turning_stage"},
	{["offset"] = 0x05A, ["size"] = 0x2, ["type"] = "unsigned", ["name"] = "odd_time_bound"},
	


	-- =============================================================================================
	-- Chasing/Path-Walking data (>= 0x40 in size)
	{["offset"]= 0x05c, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "motion_stage"},
	{["offset"]= 0x05d, ["size"] = 0x1, ["type"] = "unsigned", 	["name"] = "fail_count"},
	{["offset"]= 0x05e, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "normal_target_set"},
	{["offset"]= 0x05f, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "local_target_set"},
	{["offset"] = 0x060, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "target_position"},

	{["offset"] = 0x06c, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "barrier_right_pos"},
	-- ! overlap here, a union but I don't know the first unloaded member
	{["offset"] = 0x070, ["size"] = 0x4, ["type"] = "float", 	["name"] = "path_segment_coverage"},
	{["offset"] = 0x074, ["size"] = 0x4, ["type"] = "float", 	["name"] = "path_segment_length"},

	{["offset"] = 0x078, ["size"] = 0xC, ["type"] = "vector",	["name"] = "barrier_left_pos"},
	{["offset"] = 0x084, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "chase_timer"},
	{["offset"] = 0x088, ["size"] = 0xC, ["type"] = "vector",	["name"] = "local_target_position"},

	{["offset"] = 0x094, ["size"] = 0x4, ["type"] = "float", 	["name"] = "segment_coverage"},
	{["offset"] = 0x098, ["size"] = 0x4, ["type"] = "float", 	["name"] = "segment_length"},
	
	-- -> 0x9C)
	-- =============================================================================================

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

	{["offset"] = 0x160, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "gun_pointer"},

	{["offset"] = 0x180, ["size"] = 0x1, ["type"] = "hex", ["name"] = "shooting_stage_flag"},
	{["offset"] = 0x184, ["size"] = 0xC, ["type"] = "vector",	["name"] = "shot_origin"},	-- confirmed on HUD apparently
	{["offset"] = 0x190, ["size"] = 0xC, ["type"] = "vector",	["name"] = "bullet_dirc"}
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

	-- then read float from offset 0x14
	-- Other offsets are 0x20 (identical?) and 0x30 (can differ slightly?) 
	local angle = mainmemory.readfloat(w_pntr+0x14,true)

	return angle
end


function GuardData.get_w_structure_addr(_slot_address)
	local mdp = GuardData:get_value(_slot_address, "model_data_pointer") - 0x80000000
	local w_pntr = mainmemory.read_u32_be(mdp + 0x10) - 0x80000000
	return w_pntr
end


function GuardData.get_speed(guardAddr)
	-- Part 1 : 7f027fa8, cleaned up.
	local mdp = mainmemory.read_u32_be(guardAddr + 0x1C)
	if mdp == 0 then
		return 0
	end
	mdp = mdp - 0x80000000
	local animPtr = mainmemory.read_u32_be(mdp + 0x20)
	local animData = mainmemory.read_u32_be(0x069538)
	local offset = animPtr - animData

	-- Presumably consts
	local map = {}
	map[0x4070] = mainmemory.readfloat(0x03098c, true)
	map[0x40d4] = mainmemory.readfloat(0x030988, true)
	map[0x77d4] = mainmemory.readfloat(0x030998, true)
	map[0x777c] = mainmemory.readfloat(0x030994, true)
	map[0x8204] = mainmemory.readfloat(0x030990, true)
	-- 77d4 appears again later in the "switch", but we'll already have left.
	--map[0x77d4] = mainmemory.readfloat(0x0309a4, true)
	map[0x8520] = mainmemory.readfloat(0x0309a0, true)
	-- ending ASM is tricksy
	map[0x84c4] = mainmemory.readfloat(0x03099c, true)
	default = mainmemory.readfloat(0x030984, true)

	local v = map[offset] or default
	local rtn_a = mainmemory.readfloat(mdp + 0x14, true) * v * mainmemory.readfloat(0x051df4, true)

	-- End of 7f027fa8
	-- Part 2 : Actual change to segment_coverage within 7f028600

	local v2 = math.abs(mainmemory.readfloat(mdp + 0x40, true))	-- 7f06f618
	return rtn_a * v2
end


function GuardData.get_dodge_points(guardAddr)
	-- Return the points computed by 7f03130c i.e. 'plotRouteAroundSomethingToReachTarget',
	-- which computes a point to avoid the extreme some barrier (can be a collidable object or a tile edge)
	-- These barrier points are stored in the chaseData struct, so we can compute these points any time
	-- Effectively it just constructs a right angled triangle, with a bizarre edge case.

	local pdp = GuardData:get_value(guardAddr, "position_data_pointer") - 0x80000000
	local G = PositionData:get_value(pdp, "position")
	local dd = GuardData:get_value(guardAddr, "collision_radius") * 1.2 * 1.05	-- Dodge distance

	local angleMult = {1,-1}
	local dodgePnts = {}

	for i, P in ipairs({GuardData:get_value(guardAddr, "barrier_right_pos"), GuardData:get_value(guardAddr, "barrier_left_pos")}) do
		local GP = {x = P.x - G.x, z = P.z - G.z}
		local lenGP = math.sqrt(GP.x*GP.x + GP.z*GP.z)
		local scale = dd / lenGP
		local angle = math.pi / 4	-- 45 degrees, odd but acceptable choice for edge case where guard is very close.
		if scale <= 1 then
			angle = math.acos(scale)
		end
		--console.log(angle * 180 / math.pi)
		
		-- Outwards, so opposite directions for left/right extreme of barrier
		angle = angle * angleMult[i]


		-- Flip and scale GP for clarity
		local V = {x = -GP.x * scale, z = -GP.z * scale}
		-- Rotate through this angle and add to P to give the point
		local cosA = math.cos(angle)
		local sinA = math.sin(angle)
		table.insert(dodgePnts, {
			x = P.x + cosA * V.x - sinA * V.z,
			y = P.y,	-- just borrow's P's y
			z = P.z + sinA * V.x + cosA * V.z,
		})
	end

	return dodgePnts
end