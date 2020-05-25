-- Data for the global scripts
-- As with PD, seems identical to GuardData (with invalid offsets just 0s)

require "Data\\Data"

ScriptData = Data.create()

ScriptData.start_pointer_address = 0x03097C
ScriptData.capacity_address = 0x030980
ScriptData.size = 0x1DC

-- copied from GuardData and stripped back. 
ScriptData.metadata =	
{
	-- ID doesn't seem to be at 0x0, first 8 bytes are always:
	-- 00FE0000 0000001A
	
	-- Checked
	{["offset"] = 0x104, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "action_block_pointer"},
	{["offset"] = 0x108, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "action_block_offset"},

	-- These 5 assumed.
	{["offset"] = 0x10A, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "action_block_return"},
	{["offset"] = 0x10C, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "user_byte_1"},
	{["offset"] = 0x10D, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "user_byte_2"},
	{["offset"] = 0x10F, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "random_value"},
	{["offset"] = 0x110, ["size"] = 0x1, ["type"] = "unsigned",	["name"] = "timer"},
}

function ScriptData.get_capacity()
	return mainmemory.read_u32_be(ScriptData.capacity_address)
end

function ScriptData.get_start_address()
	return (mainmemory.read_u32_be(ScriptData.start_pointer_address) - 0x80000000)
end

function ScriptData.is_empty(_slot_address)
	return false	-- Unimplemented
end

function ScriptData.is_clone(_slot_address)
	return false -- ?
end