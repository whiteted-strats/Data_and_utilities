require "Data\\Data"
require "Data\\GE\\PositionData"
require "Data\\GE\\PlayerData"
require "Data\\GE\\Version"

GuardData = Data.create()

GuardData.start_pointer_address = ({['U'] = 0x02CC64, ['P'] = 0x0281b4,})[__GE_VERSION__]
GuardData.capacity_address = ({['U'] = 0x2CC68, ['P'] = 0x0281b8,})[__GE_VERSION__]
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
	{["offset"] = 0x02C, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "shooting_pointer"},	-- related to anim
	{["offset"] = 0x02C, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "bond_position"},
	{["offset"] = 0x038, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "target_tile"},
	{["offset"] = 0x03C, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "target_pad"},
	{["offset"] = 0x03C, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "path_target_position"},

	-- Array of size 6, so -> 0x58
	{["offset"] = 0x040, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "path_stack"},
	{["offset"] = 0x04C, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "shooting_flags"},	-- more union, & 0x1 might be is_shooting
	{["offset"] = 0x058, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "path_stack_index"},
	{["offset"] = 0x059, ["size"] = 0x1, ["type"] = "unsigned", 	["name"] = "turning_stage"},
	{["offset"] = 0x05A, ["size"] = 0x2, ["type"] = "unsigned", ["name"] = "odd_time_bound"},
	


	-- =============================================================================================
	-- Chasing/Path-Walking data (>= 0x40 in size)
	{["offset"] = 0x05c, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "motion_stage"},
	{["offset"] = 0x05d, ["size"] = 0x1, ["type"] = "unsigned", ["name"] = "fail_count"},
	{["offset"] = 0x05e, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "normal_target_set"},
	{["offset"] = 0x05f, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "local_target_set"},
	{["offset"] = 0x060, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "target_position"},
	
	{["offset"] = 0x06c, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "barrier_left_pos"},	-- the guard always favours the left side (bad news for fac lure)
	-- ! overlap here, a union but I don't know the first unloaded member
	{["offset"] = 0x070, ["size"] = 0x4, ["type"] = "float", 	["name"] = "path_segment_coverage"},
	{["offset"] = 0x074, ["size"] = 0x4, ["type"] = "float", 	["name"] = "path_segment_length"},

	{["offset"] = 0x078, ["size"] = 0xC, ["type"] = "vector",	["name"] = "barrier_right_pos"},
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

	-- Boost work
	{["offset"] = 0x13C, ["size"] = 0x4, ["type"] = "float",	["name"] = "intolerance"},
	{["offset"] = 0x14C, ["size"] = 0x4, ["type"] = "float",	["name"] = "gun_angle"},
	

	{["offset"] = 0x160, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "left_gun_pointer"},
	{["offset"] = 0x164, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "right_gun_pointer"},


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

-- Careful port of 7f06cc80 for a guard (which simplifies 7f06c79c)
-- Likely the same as the above (if b = 1 and v = 0 always)
function GuardData.facing_angle(_slot_address)
	local mdp = GuardData:get_value(_slot_address, "model_data_pointer") - 0x80000000
	local ptr = mainmemory.read_u32_be(mainmemory.read_u32_be(mdp + 0x8) -0x80000000 + 0x0) - 0x80000000

	-- Read as a half, then masked
	local b = mainmemory.read_u8(ptr + 0x1)
	if b ~= 1 then
		return 0
	end

	-- Going into 7f06c79c
	local v = mainmemory.read_u16_be(mainmemory.read_u32_be(ptr + 0x4) -0x80000000 + 0xc)

	local ptr2 = mainmemory.read_u32_be(ptr + 0x8)
	assert(ptr2 == 0)	-- Otherwise we need to code a loop

	local pVar = mainmemory.read_u32_be(mdp + 0x10) - 0x80000000
	local transformDataPtr = pVar + v

	return mainmemory.readfloat(transformDataPtr + 0x14, true)
end

function GuardData.get_gun_heading(_slot_address)
	-- Port of 7f02c190
	-- Gun angle probably isn't defined unless they are shooting
	local facingAngle = GuardData.facing_angle(_slot_address)
	local gunAngle = GuardData:get_value(_slot_address, "gun_angle")
	--local currentAction = GuardData:get_value(_slot_address, "current_action")
	local shootPtr = GuardData:get_value(_slot_address, "shooting_pointer")

	local extraAngle = 0
	if shootPtr ~= 0 then
		shootPtr = shootPtr - 0x80000000
		extraAngle = mainmemory.readfloat(shootPtr + 0xc, true)

		local mdp = GuardData:get_value(_slot_address, "model_data_pointer") - 0x80000000
		local reflectionProbably = mainmemory.read_u8(mdp + 0x24)
		if reflectionProbably ~= 0 then
			extraAngle = -extraAngle
		end
	end

	return (facingAngle + gunAngle + extraAngle) % (2*math.pi)
end

function GuardData.get_gun_position(_slot_address)
	-- Right gun only (0) atm, there's code for both though
	local gunHeading = GuardData.get_gun_heading(_slot_address)
	local guardPos = GuardData.get_position(_slot_address)
	
	return {
		x = guardPos.x - 10*math.cos(gunHeading),
		y = guardPos.y + 30,
		z = guardPos.z + 10*math.sin(gunHeading),
	}
end

function GuardData.get_weapon_type(_slot_address, hand)
	local ptr = mainmemory.read_u32_be(_slot_address + 0x160 + hand * 4)
	if ptr == 0x0 then
		return -1
	end

	local ptr = ptr - 0x80000000
	local gunObject = mainmemory.read_u32_be(ptr + 0x4) - 0x80000000
	return WeaponData:get_value(gunObject, "type")
end

function GuardData.disp_to_bond(_slot_address)
	local guardPos = GuardData.get_position(_slot_address)
	local bondPos = PlayerData.get_position()
	return {
		x = bondPos.x - guardPos.x,
		y = bondPos.y - guardPos.y,
		z = bondPos.z - guardPos.z,
	}
end

WeaponBlob = {}
WeaponBlob.size = 0x38
WeaponBlob.start_address = ({['U'] = 0x033924, ['P'] = 0x02ee7c,})[__GE_VERSION__]  
WeaponBlob.default = ({['U'] = 0x032494, ['P'] = 0x02d9e4,})[__GE_VERSION__]

IntoleranceMultiplierAddr = ({['U'] = 0x02ce40, ['P'] = 0x028390,})[__GE_VERSION__]

function GuardData.get_shooting_data(_slot_address, coneColour)
	local intolIncr = 0.16

	local weaponId = GuardData.get_weapon_type(_slot_address, 0)	-- right hand.. not all guards are?
	if weaponId == -1 then
		return	-- no weapon
	end

	-- Get the gun data
	local gunDataPtr = WeaponBlob.start_address + weaponId * WeaponBlob.size
	local gunData = WeaponBlob.default
	if mainmemory.read_u32_be(gunDataPtr + 0x8) == 0 then
		gunData = mainmemory.read_u32_be(gunDataPtr + 0xc) - 0x80000000
	end

	-- Apply appropriate doubling
	local gunGuardAcc = mainmemory.read_s8(gunData + 0x22)
	if gunGuardAcc < 1 then
		intolIncr = intolIncr * 2
	end
	if weaponId == 0xf or weaponId == 0x10 then
		intolIncr = intolIncr * 2
	end

	-- TODO consider aztec guards - that byte that we're ignoring will be used by them


	-- Guard to bond
	local guardPos = GuardData.get_position(_slot_address)
	local GB = GuardData.disp_to_bond(_slot_address)
	local distToBond = math.sqrt(GB.x*GB.x + GB.y*GB.y + GB.z*GB.z)
	if distToBond > 300 then	-- 3m
		intolIncr = intolIncr * (300 / distToBond)
	end

	-- 0.6 on A, 0.75 on SA, 1 on 00A / 007 :)
	local intolMultiplier = mainmemory.readfloat(IntoleranceMultiplierAddr, true)
	intolIncr = intolIncr * intolMultiplier

	-- Get all the shooting angles
	local distPastBond = distToBond + 100
	local gunHeading = GuardData.get_gun_heading(_slot_address) * (180 / math.pi)
	local distances = {200,400,800,1600,distPastBond+100}
	local angles = {360 / 25, 360 / 42, 360 / 84, 360 / 167, 360 / 335, 0}
	local currDist, currAngle, nextAngle
	local reachedBond = false
	local cones = {}
	for i = 1,5,1 do
		currDist = distances[i]
		reachedBond = currDist >= distPastBond
		if reachedBond then
			currDist = distPastBond
			nextAngle = 0
		else	
			nextAngle = angles[i+1]
		end

		currAngle = angles[i]
		currAngle = currAngle - nextAngle

		table.insert(cones, {
			x = guardPos.x,
			y = guardPos.y,
			z = guardPos.z,
			radius = currDist,
			start_angle = gunHeading - nextAngle - currAngle,
			sweep_angle = currAngle,
			color = coneColour,
			left = false,
		})
		table.insert(cones, {
			x = guardPos.x,
			y = guardPos.y,
			z = guardPos.z,
			radius = currDist,
			start_angle = gunHeading + nextAngle,
			sweep_angle = currAngle,
			color = coneColour,
			left = true,
		})

		if reachedBond then
			break
		end
	end

	return {
		weaponId = weaponId,
		intolIncr = intolIncr,
		gunPos = GuardData.get_gun_position(_slot_address),
		cones = cones,
	}
end

function shotAngleLimitFromDistance(distToBondSq)
	if (2560000 < distToBondSq) then
		-- >= 16m : 1 / 335th of a full circle
		return 0.01875578
	elseif (640000 < distToBondSq) then
		-- (8-16m] 1 / 167th of a full circle
		return 0.03762386
	elseif (160000 < distToBondSq) then
		-- (4-8m] 1 / 84th full circle
		return 0.07479983
	elseif (40000 < distToBondSq) then
		-- (2-4m] 1 / 42nd of a circle
		return 0.14959966
	else
		-- [0-2m] 1 / 25th full circle
		return 0.25132743
	end
end

function GuardData.get_w_structure_addr(_slot_address)
	local mdp = GuardData:get_value(_slot_address, "model_data_pointer") - 0x80000000
	local w_pntr = mainmemory.read_u32_be(mdp + 0x10) - 0x80000000
	return w_pntr
end

GuardData.default_speed_addr = ({['U'] = 0x030984, ['P'] = 0x02bed4,})[__GE_VERSION__]
GuardData.speed_map = ({
	['U'] = {
		[0x4070] = 0x03098c,
		[0x40d4] = 0x030988,
		[0x77d4] = 0x030998,
		[0x777c] = 0x030994,
		[0x8204] = 0x030990,
		-- 77d4 appears again later in the "switch", but we'll already have left.
		-- [0x77d4] = 0x0309a4,
		[0x8520] = 0x0309a0,
		-- ending ASM is tricksy
		[0x84c4] = 0x03099c,
	},
	['P'] = {
		-- Very similar to the above
		[0x4070] = 0x02bedc,
		[0x40d4] = 0x02bed8,
		[0x77d4] = 0x02bee8,
		[0x777c] = 0x02bee4,
		[0x8204] = 0x02bee0,
		[0x8520] = 0x02bef0,
		[0x84c4] = 0x02beec,
	}
})[__GE_VERSION__]
GuardData.AnimDataBase = ({['U'] = 0x069538, ['P'] = 0x058478,})[__GE_VERSION__]
GuardData.SomeSpeedConstAddr = ({['U'] = 0x051df4, ['P'] = 0x047f2c,})[__GE_VERSION__]

function GuardData.get_speed(guardAddr)
	-- Part 1 : 7f027fa8, cleaned up.
	-- 7f027fc0 in PAL
	local mdp = mainmemory.read_u32_be(guardAddr + 0x1C)
	if mdp == 0 then
		return 0
	end
	mdp = mdp - 0x80000000
	local animPtr = mainmemory.read_u32_be(mdp + 0x20)
	local animData = mainmemory.read_u32_be(GuardData.AnimDataBase)
	local offset = animPtr - animData

	local v_addr = GuardData.speed_map[offset] or GuardData.default_speed_addr
	local v = mainmemory.readfloat(v_addr, true)
	local rtn_a = mainmemory.readfloat(mdp + 0x14, true) * v * mainmemory.readfloat(GuardData.SomeSpeedConstAddr, true)

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
	-- Note that this dodge distance and construction necessarily means this edge doesn't overlap the movement corridor
	--   which is 1.2*CR at the destination end.

	local angleMult = {-1, 1}
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