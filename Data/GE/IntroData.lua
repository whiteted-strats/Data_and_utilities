require "Data\\Data"

local SpawnData = Data.create()

SpawnData.type = 0x00
SpawnData.size = 0x0C
SpawnData.metadata = 
{
}

local WeaponData = Data.create()

WeaponData.type = 0x01
WeaponData.size = 0x10
WeaponData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", ["name"] = "right_hand_weapon"},	-- 0xFFFFFFFF = No weapon
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "hex", ["name"] = "left_hand_weapon"}
}

local AmmoData = Data.create()

AmmoData.type = 0x02
AmmoData.size = 0x10
AmmoData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "type"},	
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "amount"}
}

local SwirlData = Data.create()

SwirlData.type = 0x03
SwirlData.size = 0x20
SwirlData.metadata =
{
}

local AnimationData = Data.create()

AnimationData.type = 0x04
AnimationData.size = 0x08
AnimationData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", ["name"] = "animation"}
}

local OutfitData = Data.create()

OutfitData.type = 0x05
OutfitData.size = 0x08
OutfitData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", ["name"] = "outfit"}	
}

local CameraData = Data.create()

CameraData.type = 0x06
CameraData.size = 0x28
CameraData.metadata =
{
}

local WatchData = Data.create()

WatchData.type = 0x07
WatchData.size = 0x0C
WatchData.metadata =
{
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "hours"},
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "unsigned", ["name"] = "minutes"}	
}

local CreditsData = Data.create()

CreditsData.type = 0x08
CreditsData.size = 0x08
CreditsData.metadata =
{
}

IntroData = {}

IntroData.start_pointer_address = 0x075D08
IntroData.data_types = 
{
	[0x0] = SpawnData,
	[0x1] = WeaponData,
	[0x2] = AmmoData,
	[0x3] = SwirlData,
	[0x4] = AnimationData,
	[0x5] = OutfitData,
	[0x6] = CameraData,
	[0x7] = WatchData,
	[0x8] = CreditsData
}

function IntroData.get_start_address()	
	return (mainmemory.read_u32_be(IntroData.start_pointer_address) - 0x80000000)
end

function IntroData.get_type(_item_address)
	return mainmemory.read_u32_be(_item_address)
end

function IntroData.get_data(_item_address)
	local item_type = IntroData.get_type(_item_address)

	return IntroData.data_types[item_type]
end