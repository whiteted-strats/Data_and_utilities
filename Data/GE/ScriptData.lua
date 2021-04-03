-- Data for the global scripts
-- As with PD, seems identical to GuardData (with invalid offsets just 0s)

require "Data\\Data"
require "Data\\GE\\ObjectData"
require "Data\\GE\\Version"

ScriptData = Data.create()

ScriptData.start_pointer_address = ({['U'] = 0x03097C, ['P'] = 0x02becc,})[__GE_VERSION__]   
ScriptData.capacity_address = ({['U'] = 0x030980, ['P'] = 0x02bed0,})[__GE_VERSION__]   
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

---------------------------------------------
-- Adapted from tas tools' script_module

local function getScripts(scriptBlob)
	-- NTSC-U Globals (00XX) at 0x03744C
	local scriptAddr = {}
    local addr,id
	while true do
        addr = mainmemory.read_u32_be(scriptBlob)
        id = mainmemory.read_u32_be(scriptBlob + 0x4)
        scriptBlob = scriptBlob + 8
        if (addr == 0) then -- omits 0011, but we can't track that anyway
            break
        end

        --console.log(("%04X : %08X"):format(id, addr))

        scriptAddr[id] = addr - 0x80000000
	end
	
	return scriptAddr
end


ScriptData.scriptBlobAddr = ({['U'] = 0x75D14, ['P'] = 0x064c50,})[__GE_VERSION__]
function getLevelScripts()
	-- Level scripts & Actors (10XX & 04XX)
	return getScripts(mainmemory.read_u32_be(ScriptData.scriptBlobAddr) - 0x80000000)
end

local virtual_offset = ({['U'] = 0x34b30, ['P'] = 0x329f0, ['J'] = 0x34b70})[__GE_VERSION__]
ScriptData.instrJumpTableAddr = ({['U'] = 0x052100, ['P'] = 0x048240})[__GE_VERSION__]

local function getCommandLength(scriptPtr)
    local id = mainmemory.read_u8(scriptPtr)
    if (id == 0xAD) then
        -- Comment, variable length
        local i = 1
        while (mainmemory.read_u8(scriptPtr + i) ~= 0) do
            i = i + 1
        end
        return 1 + i
    else
        -- All simple functions of the form
        -- 03e00008     jr ra
        -- 2402XXXX     li v0, X    (addiu v0, zero, X)
        local funcAddr = mainmemory.read_u32_be(ScriptData.instrJumpTableAddr  + 4*id)
        -- 7F virtual -> physical on the ROM
        funcAddr = funcAddr + virtual_offset - 0x7f000000
        memory.usememorydomain("ROM")
        local instr1 = memory.read_u32_be(funcAddr)
        local instr2 = memory.read_u32_be(funcAddr + 0x4)
        memory.usememorydomain("RDRAM") -- switch back

        assert(instr1 == 0x03e00008)
        assert(bit.rshift(instr2, 16) == 0x2402)
        return bit.band(instr2,0xFFFF)
    end
end

local function findCommandsWithId(scriptBase, targetId, cmdOffsets)
    -- Returns the offsets into the script where there are the given commands
    local id = -1
    local len
	local scriptPtr = scriptBase
	
	if cmdOffsets == nil then
		cmdOffsets = {}
	end

    while (id ~= 0x4) do
        id = mainmemory.read_u8(scriptPtr)
        len = getCommandLength(scriptPtr)

        if (id == targetId) then
			table.insert(cmdOffsets, scriptPtr - scriptBase)
        end

        scriptPtr = scriptPtr + len
    end

    return cmdOffsets
end

function ScriptData.getActivatableObjects()
	-- Finds all activatable objects using the scripts.

	local scriptAddr = getLevelScripts()
	-- Both 5c and 5d have the same tests, and format of 5XTTLL
	-- TT is the tag of the object we're interested in
	local tagInUse = {}
	for _, addr in pairs(scriptAddr) do
		local cmdOffsets = findCommandsWithId(addr, 0x5c)
		findCommandsWithId(addr, 0x5d, cmdOffsets)

		for _, offset in ipairs(cmdOffsets) do
			tagInUse[mainmemory.read_u8(addr + offset + 0x1)] = true
		end
	end

	-- tag set -> list of pointers
	local taggedObjs = {}
	for tag, _ in pairs(tagInUse) do
		table.insert(taggedObjs, TagData.getObjectWithTag(tag))
	end

	return taggedObjs
end