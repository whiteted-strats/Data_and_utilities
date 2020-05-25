require "Data\\Data"

MotionData = Data.create()

MotionData.size = 0xEC
MotionData.metadata = 
{
	{["offset"] = 0x04, ["size"] = 0x0C, ["type"] = "vector", 	["name"] = "speed"},
	{["offset"] = 0x10, ["size"] = 0x0C, ["type"] = "vector", 	["name"] = "acceleration"},
	{["offset"] = 0x1C, ["size"] = 0x04, ["type"] = "float", 	["name"] = "vertical_acceleration"}, -- Stacks with regular acceleration (with gravity applied on top of both)
	{["offset"] = 0x20, ["size"] = 0x40, ["type"] = "matrix", 	["name"] = "transform"},	
	{["offset"] = 0x88, ["size"] = 0x04, ["type"] = "hex", 		["name"] = "guard_position_data_pointer"},
	{["offset"] = 0x8C, ["size"] = 0x04, ["type"] = "float", 	["name"] = "elasticity"},
	{["offset"] = 0x90, ["size"] = 0x04, ["type"] = "unsigned", ["name"] = "bounce_count"},	
	{["offset"] = 0xA8, ["size"] = 0x04, ["type"] = "unsigned", ["name"] = "movement_timer"},
	{["offset"] = 0xAC, ["size"] = 0x04, ["type"] = "unsigned", ["name"] = "last_bounce_time"}
}