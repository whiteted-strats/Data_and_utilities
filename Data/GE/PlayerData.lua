require "Data\\Data"
require "Data\\GE\\PositionData"
require "Data\\GE\\Version"

PlayerData = Data.create()

PlayerData.start_pointer_address = ({['U'] = 0x079EE0, ['P'] = 0x0689F0})[__GE_VERSION__]
PlayerData.size = 0x2A80
PlayerData.invincibility_length = 30
PlayerData.metadata = 
{
	-- COMMON TO ALL VERSIONS HOPEFULLY
	{["offset"] = 0x0074, ["size"] = 0x4, ["type"] = "float", 		["name"] = "clipping_height"},
	{["offset"] = 0x00A0, ["size"] = 0x4, ["type"] = "float", 		["name"] = "ducking_height_offset"},
	{["offset"] = 0x00A8, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "position_data_pointer"},
	{["offset"] = 0x00DC, ["size"] = 0x4, ["type"] = "float", 		["name"] = "current_health"},
	{["offset"] = 0x00E0, ["size"] = 0x4, ["type"] = "float", 		["name"] = "current_body_armour"},
	{["offset"] = 0x00E4, ["size"] = 0x4, ["type"] = "float", 		["name"] = "previous_health"},

	{["offset"] = 0x00F4, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "invincibility_timer"},	
	{["offset"] = 0x00F8, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "health_bar_timer"},	
	{["offset"] = 0x0118, ["size"] = 0x4, ["type"] = "boolean", 	["name"] = "look_ahead_flag"},
	{["offset"] = 0x0124, ["size"] = 0x4, ["type"] = "boolean", 	["name"] = "aim_button_flag"},
	{["offset"] = 0x0128, ["size"] = 0x4, ["type"] = "boolean", 	["name"] = "auto_aim_flag"},	
	{["offset"] = 0x0148, ["size"] = 0x4, ["type"] = "float", 		["name"] = "azimuth_angle"},	
	{["offset"] = 0x014C, ["size"] = 0x4, ["type"] = "float", 		["name"] = "azimuth_turning_direction"},
	{["offset"] = 0x0150, ["size"] = 0x4, ["type"] = "float", 		["name"] = "azimuth_cosine"},
	{["offset"] = 0x0154, ["size"] = 0x4, ["type"] = "float", 		["name"] = "azimuth_sine"},
	{["offset"] = 0x0158, ["size"] = 0x4, ["type"] = "float", 		["name"] = "inclination_angle"},
	{["offset"] = 0x015C, ["size"] = 0x4, ["type"] = "float", 		["name"] = "inclination_angle"},	
	{["offset"] = 0x0160, ["size"] = 0x4, ["type"] = "float", 		["name"] = "inclination_turning_direction"},
	{["offset"] = 0x0164, ["size"] = 0x4, ["type"] = "float", 		["name"] = "inclination_cosine"},
	{["offset"] = 0x0168, ["size"] = 0x4, ["type"] = "float", 		["name"] = "inclination_sine"},
	{["offset"] = 0x016C, ["size"] = 0x4, ["type"] = "float", 		["name"] = "strafe_speed_multiplier"},
	{["offset"] = 0x0170, ["size"] = 0x4, ["type"] = "float", 		["name"] = "strafe_movement_direction"},
	{["offset"] = 0x0174, ["size"] = 0x4, ["type"] = "float", 		["name"] = "forward_speed_multiplier"},
	{["offset"] = 0x0178, ["size"] = 0x4, ["type"] = "float", 		["name"] = "forward_speed_multiplier_2"},	
	{["offset"] = 0x017C, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "forward_speed_frame_counter"},	-- PAL agrees
	{["offset"] = 0x0180, ["size"] = 0x4, ["type"] = "float", 		["name"] = "boost_factor_x"},
	{["offset"] = 0x0188, ["size"] = 0x4, ["type"] = "float", 		["name"] = "boost_factor_z"},
	{["offset"] = 0x01C8, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "pause_animation_state"},
	{["offset"] = 0x01CC, ["size"] = 0x4, ["type"] = "boolean", 	["name"] = "paused_flag"},
	{["offset"] = 0x01DC, ["size"] = 0x4, ["type"] = "float", 		["name"] = "pause_watch_position"},
	{["offset"] = 0x0200, ["size"] = 0x4, ["type"] = "boolean", 	["name"] = "pausing_flag"},
	{["offset"] = 0x0204, ["size"] = 0x4, ["type"] = "float", 		["name"] = "pause_starting_angle"},
	{["offset"] = 0x020C, ["size"] = 0x4, ["type"] = "float", 		["name"] = "pause_target_angle"},
	{["offset"] = 0x0224, ["size"] = 0x4, ["type"] = "float", 		["name"] = "pause_animation_counter"},	
	{["offset"] = 0x03D3, ["size"] = 0x1, ["type"] = "unsigned", 	["name"] = "tint_red"},
	{["offset"] = 0x03D7, ["size"] = 0x1, ["type"] = "unsigned", 	["name"] = "tint_green"},
	{["offset"] = 0x03DB, ["size"] = 0x1, ["type"] = "unsigned", 	["name"] = "tint_blue"},
	{["offset"] = 0x03DC, ["size"] = 0x4, ["type"] = "float", 		["name"] = "tint_alpha"},	
	{["offset"] = 0x048C, ["size"] = 0xC, ["type"] = "vector", 		["name"] = "position"},
	{["offset"] = 0x04B0, ["size"] = 0x4, ["type"] = "float", 		["name"] = "collision_radius"}, -- PAL agrees
	{["offset"] = 0x04FC, ["size"] = 0xC, ["type"] = "vector", 		["name"] = "scaled_velocity"},
	{["offset"] = 0x0520, ["size"] = 0xC, ["type"] = "vector", 		["name"] = "velocity"},  -- PAL seems to agree
}

-- VERSION SPECIFIC offsets
local version_metadata = ({
	['U'] = {
		{["offset"] = 0x0550, ["size"] = 0x4, ["type"] = "float",		["name"] = "stationary_ground_offset"},
		-- Noises definitely differ to PAL
		{["offset"] = 0x0A80, ["size"] = 0x4, ["type"] = "float", 		["name"] = "noise"},
		{["offset"] = 0x0E28, ["size"] = 0x4, ["type"] = "float", 		["name"] = "left_noise"},

		-- 0x870 some kind of shooting data
		{["offset"] = 0x0FD4, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "weapon_z_hold"},
		-- There are a whole list of matrices down here, as for guards (see the body part HUD)
		{["offset"] = 0x10D4, ["size"] = 0x4, ["type"] = "hex", ["name"] = "view_matrix_pointer"},

		-- Used to see if we can unlock a door - needed on PAL too
		{["offset"] = 0x11E0, ["size"] = 0x4, ["type"] = "hex", ["name"] = "owned_items"},
	},
	['P'] = {
		{["offset"] = 0x0A78, ["size"] = 0x4, ["type"] = "float", 		["name"] = "noise"},
	}
})[__GE_VERSION__]

for _, md_itm in ipairs(version_metadata) do
	table.insert(PlayerData.metadata, md_itm)
end



function PlayerData.get_start_address()
	return (mainmemory.read_u32_be(PlayerData.start_pointer_address) - 0x80000000)
end

function PlayerData.get_value(_name)
	local start_address = PlayerData.get_start_address()
	
	return PlayerData.__index.get_value(PlayerData, start_address, _name)
end

function PlayerData.has_value(_name)
	local start_address = PlayerData.get_start_address()
	return PlayerData.__index.has_value(PlayerData, start_address, _name)
end

function PlayerData.get_position()
	local pdp = PlayerData.get_value("position_data_pointer") - 0x80000000
	return PositionData:get_value(pdp, "position")
end

function PlayerData.get_tile()
	local pdp = PlayerData.get_value("position_data_pointer") - 0x80000000
	return PositionData:get_value(pdp, "tile_pointer")
end

function PlayerData.getWeapon(hand)
	local pdp = PlayerData.get_start_address()
	return mainmemory.read_u32_be(pdp + 0x870 + hand * 0x3a8)
end

function PlayerData.getWeaponSpecific(hand)
	local pdp = PlayerData.get_start_address()
	return mainmemory.read_s32_be(pdp + 0x874 + hand * 0x3a8)
end

function PlayerData.getNoise()
	local noise = 0
	local pdp = PlayerData.get_start_address()
	
	-- These tests are whether a shot is being fired this frame
	--if mainmemory.read_u8(pdp + 0x87C) ~= 0 then

	noise = PlayerData.get_value("noise") -- right noise
	

	local left_noise = 0
	if PlayerData.has_value("left_noise") then
		left_noise = PlayerData.get_value("left_noise")
	end
	-- mainmemory.read_u8(pdp + 0x87C + 0x3a8) ~= 0 and 
	if left_noise > noise then
		noise = left_noise
	end

	return noise
end

function PlayerData.hasKeyForLocks(locks)
	-- This involves some iter over more 'owned items'
	-- Ported from 7f08ce70

	if locks == 0 then
		return true
	end

	if not PlayerData.has_value("owned_items") then
		return false
	end
	local firstItmPtr = PlayerData.get_value("owned_items")
	local itmPtr = firstItmPtr
	local wrapperPtr
	local objPt
	local foundKeys = 0

	while itmPtr ~= 0 and itmPtr ~= firstItmPtr do
		console.log(("%08X"):format(itmPtr))
		itmPtr = itmPtr - 0x80000000
		if mainmemory.read_u32_be(itmPtr + 0x0) == 2 then
			wrapperPtr = mainmemory.read_u32_be(itmPtr + 0x4) - 0x80000000
			if mainmemory.read_u8(wrapperPtr + 0x0) == 0x01 then

				objPtr = mainmemory.read_u32_be(wrapperPtr + 0x4) - 0x80000000
				if ObjectData.get_type(objPtr) == 0x04 then	-- key
					foundKeys = bit.bor(foundKeys, KeyData:get_value(objPtr, "opens_locks"))

					if bit.band(locks, foundKeys) == locks then	-- all locks can be opened
						return true
					end
				end

			end
		end
		itmPtr = mainmemory.read_u32_be(itmPtr + 0xC)
	end

	return false

end
