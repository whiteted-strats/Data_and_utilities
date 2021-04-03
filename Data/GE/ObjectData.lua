require "Data\\Data"
require "Data\\GE\\PositionData"
require "HUD_Matt\\HUD_matt_lib"	-- matrixFromMainMemory, applyHomMatrix, vectorAdd
require "Data\\GE\\Version"
require "Data\\GE\\PresetData"

local dimension_mnemonics = {"x", "y", "z", "w"}

-- Putting code here for getting preset bounds
function getPresetPoints(objAddr)
    -- Transform at 0x18 - rotation and scale
    local T = matrixFromMainMemory(objAddr+0x18)
    local pos = PhysicalObjectData:get_value(objAddr, "position")

    -- I've seen this in code since, but originally I found this by memory watching :) 
    local mdp = mainmemory.read_u32_be(objAddr + 0x14) - 0x80000000
    local a = mainmemory.read_u32_be(mdp + 0x8) - 0x80000000
	local b = mainmemory.read_u32_be(a) - 0x80000000
    local c = mainmemory.read_u32_be(b + 0x14) - 0x80000000
    local d = mainmemory.read_u32_be(c + 0x4) - 0x80000000
	local scalesPointer = d + 4
	
	local extremes = {}
	for i=0,1,1 do
		local pnt = {}
		for j=1,3,1 do
			pnt[dimension_mnemonics[j]] = mainmemory.readfloat(scalesPointer + i*4 + (j-1)*8, true)
		end

		table.insert(extremes, pnt)
	end

	local xs = {1,1,2,2}
	local zs = {1,2,2,1}
	local rtns = {}
	for i=1,4,1 do
		local pnt = {x=extremes[xs[i]].x, y=extremes[1].y, z=extremes[zs[i]].z}
		local pnt2 = applyHomMatrix(pnt, T)
		local pnt3 = vectorAdd(pos, pnt2)
		table.insert(rtns, pnt3)
	end

	return rtns
end


DoorData = Data.create()

DoorData.type = 0x01
DoorData.size = 0x80
DoorData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "float", 	["name"] = "max_displacement_percentage"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "float", 	["name"] = "walkthrough_distance"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "acceleration"},
	{["offset"] = 0x10, ["size"] = 0x4, ["type"] = "float", 	["name"] = "rate"},
	{["offset"] = 0x14, ["size"] = 0x4, ["type"] = "float", 	["name"] = "max_speed"},
	{["offset"] = 0x1A, ["size"] = 0x2, ["type"] = "unsigned",	["name"] = "hinge_type"},
	{["offset"] = 0x1C, ["size"] = 0x4, ["type"] = "bitfield", 	["name"] = "lock"},
	{["offset"] = 0x20, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "max_open_time"},	-- A0
	{["offset"] = 0x28, ["size"] = 0x4, ["type"] = "float", 	["name"] = "max_displacement"},
	{["offset"] = 0x34, ["size"] = 0x4, ["type"] = "float", 	["name"] = "displacement_percentage"},	-- important, 0xB4
	{["offset"] = 0x38, ["size"] = 0x4, ["type"] = "float", 	["name"] = "speed_percentage"},
	{["offset"] = 0x3C, ["size"] = 0x1, ["type"] = "enum", 		["name"] = "state"},
	-- Confirmed looking at the individual levels. Double doors are 2 linked doors,
	-- Dam & Facility have linked opposed doors.
	-- The glass in bunker is 4 doors
	-- Aztec's table & Egypt's gun room have various complexities
	{["offset"] = 0x48, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "linked_door"},

	{["offset"] = 0x6C, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "opened_time"},
	{["offset"] = 0x7C, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "timer"}
}

function read_vector_directly(address, size)
	local vector = {}	
	
	for i = 1, size, 1 do
		local offset = (i - 1) * 0x04
		vector[dimension_mnemonics[i]] = mainmemory.readfloat(address + offset, true)
	end
	
	return vector
end

-- TODO : add preset data as a seperate file, move this in there.

function doorDataGetHinges(door_address)
	-- Supported for door types 5 and 9 now
	-- Direction should be working fine now
	-- Ported from 7f0526ec
	local hinge_type = DoorData:get_value(door_address, "hinge_type")
	local hinges = {}

	if ((hinge_type == 5) or (hinge_type == 9)) then
		local preset = DoorData:get_value(door_address, "preset")

		local presetDataPtr = (mainmemory.read_u32_be(PresetData.start_address) - 0x80000000) + 0x44 * preset

		local pA = read_vector_directly(presetDataPtr, 3)
		local normal_x = read_vector_directly(presetDataPtr + 0xc, 3)
		local normal_y = read_vector_directly(presetDataPtr + 0x18, 3)
		local low_x = mainmemory.readfloat(presetDataPtr + 0x34, true)
		local high_z = mainmemory.readfloat(presetDataPtr + 0x30, true)
		local low_z = mainmemory.readfloat(presetDataPtr + 0x2c, true)

		-- Flag[2] is whether it opens backwards
		-- Flag[4] is whether it opens away from the player
		-- If [4] is set, it sets [2] dynamically. But [2] can still be set by itself.
		local flags = DoorData:get_value(door_address, "flags_1")
		local openBackward = (bit.band(bit.rshift(flags, 29), 1) == 1)
		local openAwayFromBond = (bit.band(bit.rshift(flags, 27), 1) == 1)

		local doorPosition = DoorData:get_value(door_address, "position")

		local normal_z = {}
		local hingePos = {}
		local offset = {}

		normal_z.x = (normal_x).y * (normal_y).z - (normal_y).y * (normal_x).z
		normal_z.y = (normal_x).z * (normal_y).x - (normal_y).z * (normal_x).x
		normal_z.z = (normal_x).x * (normal_y).y - (normal_y).x * (normal_x).y
		hingePos.x = (normal_x).x * low_x + (pA).x
		hingePos.y = (normal_x).y * low_x + (pA).y
		hingePos.z = (normal_x).z * low_x + (pA).z
		
		if (hinge_type == 9) then
			-- type 9, always has high z
			hingePos.x = hingePos.x + normal_z.x * high_z
			hingePos.y = hingePos.y + normal_z.y * high_z
			hingePos.z = hingePos.z + normal_z.z * high_z
			table.insert(hinges, hingePos)
		else
			-- type 5, can swing both ways
			-- this output order seems best
			
			if (openAwayFromBond or not openBackward) then
				table.insert(hinges, {
					["x"] = hingePos.x + normal_z.x * low_z,
					["y"] = hingePos.y + normal_z.y * low_z,
					["z"] = hingePos.z + normal_z.z * low_z,
				})
			end
			
			if (openAwayFromBond or openBackward) then
				-- This one is used when flag_2 is set, which requires flag_4 to be set
				table.insert(hinges, {
					["x"] = hingePos.x + normal_z.x * high_z,
					["y"] = hingePos.y + normal_z.y * high_z,
					["z"] = hingePos.z + normal_z.z * high_z,
				})
			end
			
		end

		-- offset = doorPos - hingePos
		-- We're at the call to copy matrix in 7f0526ec
	end

	return hinges
end


DoorScaleData = Data.create()

DoorScaleData.type = 0x02
DoorScaleData.size = 0x08
DoorScaleData.metadata = 
{
}

PhysicalObjectData = Data.create()

PhysicalObjectData.type = 0x03
PhysicalObjectData.size = 0x80
PhysicalObjectData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x02, ["type"] = "hex", 		["name"] = "image"},
	{["offset"] = 0x06, ["size"] = 0x02, ["type"] = "hex", 		["name"] = "preset"},
	{["offset"] = 0x08, ["size"] = 0x04, ["type"] = "bitfield", ["name"] = "flags_1"},
	{["offset"] = 0x0C, ["size"] = 0x04, ["type"] = "bitfield", ["name"] = "flags_2"},
	{["offset"] = 0x10, ["size"] = 0x04, ["type"] = "hex", 		["name"] = "position_data_pointer"},
	{["offset"] = 0x14, ["size"] = 0x04, ["type"] = "hex", 		["name"] = "model_data_pointer"},
	{["offset"] = 0x18, ["size"] = 0x40, ["type"] = "matrix", 	["name"] = "transform"},
	{["offset"] = 0x58, ["size"] = 0x0C, ["type"] = "vector",	["name"] = "position"},
	{["offset"] = 0x64, ["size"] = 0x04, ["type"] = "hex",		["name"] = "more_flags"},	-- used onscreen
	{["offset"] = 0x68, ["size"] = 0x04, ["type"] = "hex",		["name"] = "collision_data_pointer"},
	{["offset"] = 0x6C, ["size"] = 0x04, ["type"] = "hex",		["name"] = "motion_data_pointer"},	
	{["offset"] = 0x70, ["size"] = 0x04, ["type"] = "float",	["name"] = "damage_received"},
	{["offset"] = 0x74, ["size"] = 0x04, ["type"] = "float",	["name"] = "health"},
	{["offset"] = 0x78, ["size"] = 0x04, ["type"] = "color",	["name"] = "current_color"},
	{["offset"] = 0x7C, ["size"] = 0x04, ["type"] = "color",	["name"] = "target_color"}
}

KeyData = Data.create()

KeyData.type = 0x04
KeyData.size = 0x04
KeyData.metadata =
{
	{["offset"] = 0x0, ["size"] = 0x04, ["type"] = "bitfield",	["name"] = "opens_locks"}
}

AlarmData = Data.create()

AlarmData.type = 0x05
AlarmData.size = 0x00
AlarmData.metadata = nil

CameraData = Data.create()

CameraData.type = 0x06
CameraData.size = 0x6C
CameraData.metadata =
{
}

AmmoClipData = Data.create()

AmmoClipData.type = 0x07
AmmoClipData.size = 0x04
AmmoClipData.metadata =
{
}

WeaponData = Data.create()

WeaponData.type = 0x08
WeaponData.size = 0x08
WeaponData.metadata =
{
	-- Table of types is in projectile data
	{["offset"] = 0x00, ["size"] = 0x1, ["type"] = "hex", ["name"] = "type"},
	{["offset"] = 0x01, ["size"] = 0x1, ["type"] = "hex", ["name"] = "padding"}, -- ff
	{["offset"] = 0x02, ["size"] = 0x2, ["type"] = "hex", ["name"] = "timer"},
}

CharacterData = Data.create()

CharacterData.type = 0x09
CharacterData.size = 0x1C
CharacterData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x2, ["type"] = "hex", 	["name"] = "id"},
	{["offset"] = 0x06, ["size"] = 0x2, ["type"] = "hex", 	["name"] = "preset"},
	{["offset"] = 0x08, ["size"] = 0x2, ["type"] = "hex", 	["name"] = "body"},
	{["offset"] = 0x0A, ["size"] = 0x2, ["type"] = "hex", 	["name"] = "action_block"},
	{["offset"] = 0x0C, ["size"] = 0x2, ["type"] = "hex", 	["name"] = "default_2328_preset"},	
	{["offset"] = 0x18, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "guard_data_pointer"}	
}

SingleScreenMonitorData = Data.create()

SingleScreenMonitorData.type = 0x0A
SingleScreenMonitorData.size = 0x80
SingleScreenMonitorData.metadata =
{
}

MultiScreenMonitorData = Data.create()

MultiScreenMonitorData.type = 0x0B
MultiScreenMonitorData.size = 0x1D4
MultiScreenMonitorData.metadata =
{
}

CeilingMonitorsData = Data.create()

CeilingMonitorsData.type = 0x0C
CeilingMonitorsData.size = 0x00
CeilingMonitorsData.metadata = nil

DroneData = Data.create()

DroneData.type = 0x0D
DroneData.size = 0x58
DroneData.metadata =
{
	-- GAP [0x0 - 0x4)	unknown unsigned
	-- GAP [0x4 - 0x8) 	unknown float
	-- Both in radians, with right negated
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "float", 	["name"] = "sight_left"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "sight_right"},

	-- All angles in radians
	{["offset"] = 0x10, ["size"] = 0x4, ["type"] = "float", 	["name"] = "azimuth_angle"},
	{["offset"] = 0x14, ["size"] = 0x4, ["type"] = "float", 	["name"] = "delta_azimuth"},
	-- This is the inclination at which it rests while inactive
	{["offset"] = 0x18, ["size"] = 0x4, ["type"] = "float", 	["name"] = "rest_inclination"},
	{["offset"] = 0x1C, ["size"] = 0x4, ["type"] = "float", 	["name"] = "inclination_angle"},
	{["offset"] = 0x20, ["size"] = 0x4, ["type"] = "float", 	["name"] = "delta_inclination"},

	-- The azimuth/inclination deltas are complicated - they:
	-- * are capped by this value (per Game Frame, so higher lag will supress the rotation)
	-- * accelerate linearly when far away from the player
	-- * decelerate when they are close.. but still overshoot
	{["offset"] = 0x24, ["size"] = 0x4, ["type"] = "float", 	["name"] = "max_delta"},

	-- Firing / targeting range
	{["offset"] = 0x28, ["size"] = 0x4, ["type"] = "float", 	["name"] = "range"},
	
	-- The number of bullets ever fired - wierd that it notes this
	{["offset"] = 0x2C, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "shot_count"},

	-- The delta for- and angle that- the gun barrel has rotated through
	{["offset"] = 0x30, ["size"] = 0x4, ["type"] = "float", 	["name"] = "delta_barrel_rotation"},
	{["offset"] = 0x34, ["size"] = 0x4, ["type"] = "float", 	["name"] = "barrel_rotation"},


	-- Time last seen : if this is more than ~2s ago we stop shooting (though may well still be active)
	--   "seen" is being reasonably close to the stream of bullets
	{["offset"] = 0x38, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "time_last_seen"},
	-- ! The last time that we were last very close to the bullet stream
	{["offset"] = 0x3C, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "time_last_close"},
	-- The last time we fired a shot
	{["offset"] = 0x40, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "time_last_shot"},

	-- [UNCONFIRMED]
	{["offset"] = 0x44, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "bullet_pointer_1"},
	{["offset"] = 0x48, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "bullet_pointer_2"},
	
	-- GAP [0x48 - 0x4C) a pointer, maybe to a model or something

	-- 1 if firing, 0 otherwise
	{["offset"] = 0x50, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "is_firing"},
	
	-- !! Builds up with near misses
	--   When this hits 1 the bullet will land (unless the player is invincible)
	{["offset"] = 0x54, ["size"] = 0x4, ["type"] = "float", 	["name"] = "intolerance"},
}

CollectibleLinkData = Data.create()

CollectibleLinkData.type = 0x0E
CollectibleLinkData.size = 0x0C
CollectibleLinkData.metadata =
{
}

HatData = Data.create()

HatData.type = 0x11
HatData.size = 0x00
HatData.metadata = nil

GrenadeProbabilityData = Data.create()

GrenadeProbabilityData.type = 0x12
GrenadeProbabilityData.size = 0x0C
GrenadeProbabilityData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "id"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "probability"}
}

ObjectLinkData = Data.create()

ObjectLinkData.type = 0x13
ObjectLinkData.size = 0x10
ObjectLinkData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "position_data_pointer_1"},	
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "position_data_pointer_2"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "previous_entry_pointer"}
}

AmmoBoxData = Data.create()

AmmoBoxData.type = 0x14
AmmoBoxData.size = 0x34
AmmoBoxData.metadata =
{
}

BodyArmorData = Data.create()

BodyArmorData.type = 0x15
BodyArmorData.size = 0x08
BodyArmorData.metadata =
{
	{["offset"] = 0x4, ["size"] = 0x4, ["type"] = "float", 	["name"] = "amount"},
}

TagData = Data.create()

TagData.type = 0x16
TagData.size = 0x10
TagData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x2, ["type"] = "signed", 	["name"] = "object_number"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "previous_entry_pointer"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "tagged_object_pointer"}	
}
TagData.head_ptr = ({['U'] = 0x075d80, ['P'] = 0x064cc0,})[__GE_VERSION__]

-- Ported from 7f057080
function TagData.getObjectWithTag(tag)
	currLink = mainmemory.read_u32_be(TagData.head_ptr)
	while currLink ~= 0 do
		currLink = currLink - 0x80000000
		currTag = TagData:get_value(currLink, "object_number")
		if currTag == tag then
			return TagData:get_value(currLink, "tagged_object_pointer") - 0x80000000
		end

		currLink = TagData:get_value(currLink, "previous_entry_pointer")
	end

	return nil
end

ObjectiveData = Data.create()

ObjectiveData.type = 0x17
ObjectiveData.size = 0x10
ObjectiveData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "objective_number"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "text_preset"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "difficulty"}
}

BriefingData = Data.create()

BriefingData.type = 0x23
BriefingData.size = 0x10
BriefingData.metadata = 
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "enum", 	["name"] = "briefing_type"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex",  	["name"] = "text_preset"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "hex",  	["name"] = "previous_entry_pointer"}
}

GasContainerData = Data.create()

GasContainerData.type = 0x24
GasContainerData.size = 0x00
GasContainerData.metadata = nil

ItemInfoData = Data.create()

ItemInfoData.type = 0x25
ItemInfoData.size = 0x28
ItemInfoData.metadata = 
{
	{["offset"] = 0x0A, ["size"] = 0x2, ["type"] = "hex",	["name"] = "item"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "hex",	["name"] = "watch_top_text_preset"},
	{["offset"] = 0x10, ["size"] = 0x4, ["type"] = "hex",	["name"] = "watch_bottom_text_preset"},
	{["offset"] = 0x14, ["size"] = 0x4, ["type"] = "hex",	["name"] = "inventory_text_preset"},
	{["offset"] = 0x18, ["size"] = 0x4, ["type"] = "hex",	["name"] = "weapon_of_choice_text_preset"},
	{["offset"] = 0x1C, ["size"] = 0x4, ["type"] = "hex",	["name"] = "interaction_text_preset"}	
}

LockData = Data.create()

LockData.type = 0x26
LockData.size = 0x10
LockData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "door_data_pointer"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "object_data_pointer"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "previous_entry_pointer"}
}

VehicleData = Data.create()

VehicleData.type = 0x27
VehicleData.size = 0x30
VehicleData.metadata =
{
}

AircraftData = Data.create()

AircraftData.type = 0x28
AircraftData.size = 0x34
AircraftData.metadata =
{
}

GlassData = Data.create()

GlassData.type = 0x2A
GlassData.size = 0x00
GlassData.metadata = nil

SafeData = Data.create()

SafeData.type = 0x2B
SafeData.size = 0x00
SafeData.metadata = nil

SafeObjectData = Data.create()

SafeObjectData.type = 0x2C
SafeObjectData.size = 0x14
SafeObjectData.metadata = 
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", ["name"] = "object_pointer"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", ["name"] = "safe_pointer"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "hex", ["name"] = "door_pointer"},
	{["offset"] = 0x10, ["size"] = 0x4, ["type"] = "hex", ["name"] = "previous_entry_pointer"}
}

TankData = Data.create()

TankData.type = 0x2D
TankData.size = 0x60
TankData.metadata = 
{
	{["offset"] = 0x58, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "shell_count"}
}

ViewpointData = Data.create()

ViewpointData.type = 0x2E
ViewpointData.size = 0x1C
ViewpointData.metadata = 
{
	{["offset"] = 0x1A, ["size"] = 0x2, ["type"] = "hex", ["name"] = "preset"}
}

TintedGlassData = Data.create()

TintedGlassData.type = 0x2F
TintedGlassData.size = 0x14
TintedGlassData.metadata = 
{
	{["offset"] = 0x00, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "opaque_distance"},
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "transparent_distance"}
}

-- Append data common for all physical objects
DoorData = 					PhysicalObjectData .. DoorData
KeyData = 					PhysicalObjectData .. KeyData
AlarmData = 				PhysicalObjectData .. AlarmData
CameraData = 				PhysicalObjectData .. CameraData
AmmoClipData = 				PhysicalObjectData .. AmmoClipData
WeaponData = 				PhysicalObjectData .. WeaponData
SingleScreenMonitorData = 	PhysicalObjectData .. SingleScreenMonitorData
MultiScreenMonitorData = 	PhysicalObjectData .. MultiScreenMonitorData
CeilingMonitorsData = 		PhysicalObjectData .. CeilingMonitorsData
DroneData = 				PhysicalObjectData .. DroneData
HatData = 					PhysicalObjectData .. HatData
AmmoBoxData = 				PhysicalObjectData .. AmmoBoxData
BodyArmorData = 			PhysicalObjectData .. BodyArmorData
GasContainerData = 			PhysicalObjectData .. GasContainerData
VehicleData = 				PhysicalObjectData .. VehicleData
AircraftData = 				PhysicalObjectData .. AircraftData
GlassData = 				PhysicalObjectData .. GlassData
SafeData = 					PhysicalObjectData .. SafeData
TankData = 					PhysicalObjectData .. TankData
TintedGlassData = 			PhysicalObjectData .. TintedGlassData

ObjectData = {}

ObjectData.start_pointer_address = ({['U'] = 0x075D0C, ['P'] = 0x064C4C,})[__GE_VERSION__]
ObjectData.data_types =
{
	[0x01] = DoorData,
	[0x02] = DoorScaleData,
	[0x03] = PhysicalObjectData,
	[0x04] = KeyData,
	[0x05] = AlarmData,
	[0x06] = CameraData,
	[0x07] = AmmoClipData,
	[0x08] = WeaponData,
	[0x09] = CharacterData,
	[0x0A] = SingleScreenMonitorData,
	[0x0B] = MultiScreenMonitorData,
	[0x0C] = CeilingMonitorsData,
	[0x0D] = DroneData,
	[0x0E] = CollectibleLinkData,
	[0x11] = HatData,
	[0x12] = GrenadeProbabilityData,
	[0x13] = ObjectLinkData,
	[0x14] = AmmoBoxData,
	[0x15] = BodyArmorData,
	[0x16] = TagData,
	[0x17] = ObjectiveData,
	[0x23] = BriefingData,
	[0x24] = GasContainerData,
	[0x25] = ItemInfoData,
	[0x26] = LockData,
	[0x27] = VehicleData,
	[0x28] = AircraftData,
	[0x2A] = GlassData,
	[0x2B] = SafeData,
	[0x2C] = SafeObjectData,
	[0x2D] = TankData,
	[0x2E] = ViewpointData,
	[0x2F] = TintedGlassData
}

function ObjectData.get_start_address()	
	return (mainmemory.read_u32_be(ObjectData.start_pointer_address) - 0x80000000)
end

function ObjectData.get_type(_object_address)
	return mainmemory.read_u8(_object_address + 0x03)
end

function ObjectData.get_data(_object_address)
	local object_type = ObjectData.get_type(_object_address)

	return ObjectData.data_types[object_type]
end


-- Pickups code

function ObjectData.getAllCollectables()
	-- Outer loop from 7f03d0d4
	local relPosData = mainmemory.read_u32_be(PositionData.head_ptr)
	local isCollectible = {}

	while relPosData ~= 0 do
		relPosData = relPosData - 0x80000000

		local collectible = false

		local field_2 = mainmemory.read_s16_be(relPosData + 0x2)	-- not yet named
		local objClass = PositionData:get_value(relPosData, "object_type")
		if field_2 < 1 and (objClass == 1 or objClass == 4) then
			-- From 7f0506dc
			local objPtr = PositionData:get_value(relPosData, "object_data_pointer") - 0x80000000
			local objType = ObjectData.get_type(objPtr)

			-- Key, Ammo, Weapon, AmmoBox or BodyArmour (hat omitted seperately)
			local flags_1 = PhysicalObjectData:get_value(objPtr, "flags_1")

			if not (objType == 0x04 or objType == 0x07 or objType == 0x08 or objType == 0x14 or objType == 0x15) then
				local flag = bit.band(bit.rshift(flags_1, 31 - 0xd), 1)
				collectible = (flag == 1)
			else
				local flag = bit.band(bit.rshift(flags_1, 31 - 0xb), 1)
				collectible = (flag == 0)
			end

			local flag = bit.band(bit.rshift(flags_1, 31 - 0xc), 1)
			collectible = collectible and (flag == 0)

			-- [Motion checks and strange list checks ignored here]

			-- [Further specific tests here - i.e. checking you don't have max ammo]
			-- => BA one is bizarre, you can't have more armour than you are picking up.
			--    So you can always pick up a 100%, but must be under 50% to pick up a 50%
			
			-- Then to pick anything up you must be looking no more than 45 degrees down,
			--  inside 1 metre in XZ, and within 2 metres in Y
			-- There is a condition on the player which makes this 3.5m and 5m, but I assume it doesn't happen normally
			-- If obj.flags_2 & 0x1000 == 0, you also need a line of sight on it (over clipping)
			-- Use PhysicalObject's position.
			if collectible then
				isCollectible[objPtr] = true	-- could put whether it's extreme here
			end
		end

		-- Step backwards
		relPosData = PositionData:get_value(relPosData, "prev_entry_pointer")
	end

	return isCollectible
end