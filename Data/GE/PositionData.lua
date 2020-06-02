require "Data\\Data"
require "Data\\GE\\GameData"

-- Now including tile & pad data.. for now

PositionData = Data.create()

PositionData.size = 0x34
PositionData.object_types =
{
	[0x1] = "Normal",
	[0x2] = "Door",
	[0x3] = "Guard",
	[0x4] = "Weapon",
	[0x6] = "Player",
	[0x7] = "Explosion",
	[0x8] = "Smoke"
}

PositionData.metadata = 
{
	{["offset"] = 0x00, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "object_type"}, -- 03 guard
	{["offset"] = 0x01, ["size"] = 0x1, ["type"] = "hex", 		["name"] = "flags"}, -- #2 = Visible, #4 = Active
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "object_data_pointer"},
	{["offset"] = 0x08, ["size"] = 0xC, ["type"] = "vector", 	["name"] = "position"},
	{["offset"] = 0x14, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "tile_pointer"},
	{["offset"] = 0x24, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "prev_entry_pointer"},
	{["offset"] = 0x28, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "next_entry_pointer"},
	{["offset"] = 0x2C, ["size"] = 0x4, ["type"] = "hex", 		["name"] = "room_list"} -- 0xFF = End of list
}

local function distSqToPad(actorPos, padNum, somePadInfo)
	local padPos = {
		x = memory.readfloat(somePadInfo + (0x2c * padNum) + 0x0, true),
		z = memory.readfloat(somePadInfo + (0x2c * padNum) + 0x8, true),
	}
	local diff = {
		x = padPos.x - actorPos.x,
		z = padPos.z - actorPos.z,
	}
	return diff.x*diff.x + diff.z*diff.z
end


-- 7F0B2718, but cleaned up
local function cleanerTileBFS(sourceTile, predicate)
	-- Key improvements over GE's implementation
	--	(2) onStack 'set'
	--	(3) inner loop is only over the outer ring, not all seen tiles
	--	(4) predicate uses a 'set' rather than a loop

	-- We're still not going to cache the result though, could lead to problems across levels

	local stack = {}
	local onStack = {}

	if (predicate(sourceTile)) then
		return sourceTile
	end

	-- Push the source tile onto the stack
	local iterStackLimit = 1
	table.insert(stack, sourceTile)
	onStack[sourceTile] = true

	local fullStackHeight = iterStackLimit
	local prevIterLimit = 0

	-- Outer loop, over distance from the centre
	while true do

		-- Mid loop, only loop over this ring now rather than the whole stack
		for stackIndex = (prevIterLimit+1),iterStackLimit do
			local pointIndex = 0
			local tile = stack[stackIndex]
			--console.log(("Tile %06X"):format(TileData:get_value(tile, "name")))

			local pointCount = TileData.get_point_count(tile)
			local internalPtr = tile

			-- Inner loop, over the neighbours of this tile
			while (pointIndex < pointCount) do
				
				-- Get neighbour tile and test if it's "null"
				local index = memory.read_u16_be(internalPtr + 0xe)
				neighbourTile = index * 8 + TileData.get_start_address() - 0x80000000

				if (bit.rshift(index, 4) ~= 0 and not onStack[neighbourTile]) then
					-- No longer looping over the whole stack
						
					if (predicate(neighbourTile)) then
						return neighbourTile
					end
					
					-- Add to the stack, and leave after probably overflowing by 1
					fullStackHeight = fullStackHeight + 1
					table.insert(stack, neighbourTile)
					onStack[neighbourTile] = true
					if (350 < fullStackHeight) then
						return 0
					end

					-- Unnecessary.. presumably a compiler artifact?
					--pointCount = *(short *)(tile + 6) >> 0xc & 0xf;
				end

				pointIndex = pointIndex + 1
				internalPtr = internalPtr + 8
			end

		end
	

		-- Mark all tiles as accessible in the next loop, if there are more to do
		if fullStackHeight == iterStackLimit then
			break
		end

		prevIterLimit = iterStackLimit	-- addition
		iterStackLimit = fullStackHeight
	end
	
	return 0

end




-- Mimicing 7f027cd4, tile -> pad (-> BFS) -> closest of this & it's neighbour
-- Except we've visited https://en.wikipedia.org/wiki/Breadth-first_search in our lifetime
function PositionData.getNearPad(posDataAddr)
	local tile = PositionData:get_value(posDataAddr, "tile_pointer")
	local somePadInfo = memory.read_u32_be(0x075d18) - 0x80000000
	local padStart = PadData.get_start_address()

	-- See if this tile has some pad, and also prep our efficient predicate
	local padOnTile = {}

	local currPad = memory.read_u32_be(0x075d00) - 0x80000000 - PadData.size
	local padNum
	local assocTile = -1
	while assocTile ~= tile do
		currPad = currPad + PadData.size
		padNum = PadData:get_value(currPad,"number")

		if padNum < 0 then
			break
		end

		assocTile = memory.read_u32_be(somePadInfo + (0x2c * padNum) + 0x28)
		padOnTile[assocTile] = currPad
	end


	-- If we didn't find a pad on our tile, we did prep 'padOnTile'
	-- So perform our BFS with a decent predicate
	if padNum < 0 then
		local function efficientPredicate(t)
			return padOnTile[t + 0x80000000] ~= nil
		end

		paddedTile = cleanerTileBFS(tile - 0x80000000, efficientPredicate)
		assert(paddedTile ~= 0, "BFS failed")

		currPad = padOnTile[paddedTile + 0x80000000]
		padNum = PadData:get_value(currPad, "number")
	end

	-- Find which of this pad and it's neighbours are closest
	local actorPos = PositionData:get_value(posDataAddr, "position")
	local linkageList = PadData:get_value(currPad, "linkageList") - 0x80000000

	local shortestDist = distSqToPad(actorPos, padNum, somePadInfo)
	local neighbour = memory.read_s32_be(linkageList)
	local dist
	while neighbour >= 0 do
		-- Convert index to pad to pad number
		neighbour = padStart + 0x10 * neighbour
		neighbour = PadData:get_value(neighbour, "number")

		dist = distSqToPad(actorPos, neighbour, somePadInfo)
		if (dist < shortestDist) then
			shortestDist = dist
			padNum = neighbour
		end
		
		linkageList = linkageList + 4
		neighbour = memory.read_s32_be(linkageList)
	end
	
	return padNum
end


-- Tile data
TileData = Data.create()

TileData.size = 0x20	-- if 3 points, can be up to 15 (9 seen)
TileData.metadata = {
	{["offset"] = 0x00, ["size"] = 0x3, ["type"] = "hex",	["name"] = "name"},
	{["offset"] = 0x03, ["size"] = 0x1, ["type"] = "hex",	["name"] = "room"},
	
	-- 4th nibble is count
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex", 	["name"] = "header"},

	{["offset"] = 0x08, ["size"] = 0x2, ["type"] = "signed",	["name"] = "a_x"},
	{["offset"] = 0x0A, ["size"] = 0x2, ["type"] = "signed",	["name"] = "a_y"},
	{["offset"] = 0x0C, ["size"] = 0x2, ["type"] = "signed",	["name"] = "a_z"},
	{["offset"] = 0x0E, ["size"] = 0x2, ["type"] = "hex", 		["name"] = "a_link"},
	
	{["offset"] = 0x10, ["size"] = 0x2, ["type"] = "signed",	["name"] = "b_x"},
	{["offset"] = 0x12, ["size"] = 0x2, ["type"] = "signed",	["name"] = "b_y"},
	{["offset"] = 0x14, ["size"] = 0x2, ["type"] = "signed",	["name"] = "b_z"},
	{["offset"] = 0x16, ["size"] = 0x2, ["type"] = "hex",		["name"] = "b_link"},
	
	{["offset"] = 0x18, ["size"] = 0x2, ["type"] = "signed",	["name"] = "c_x"},
	{["offset"] = 0x1A, ["size"] = 0x2, ["type"] = "signed",	["name"] = "c_y"},
	{["offset"] = 0x1C, ["size"] = 0x2, ["type"] = "signed",	["name"] = "c_z"},
	{["offset"] = 0x1E, ["size"] = 0x2, ["type"] = "hex",		["name"] = "c_link"},

	-- 6 on frigate door to engine bomb
	-- 8 linking to clipping linking the pipes
	-- 9 in B1 up by the glass with the camera, because of the stairs


}

function TileData.get_point_count(addr)
	return bit.rshift(bit.band(TileData:get_value(addr, "header"), 0xFFFF), 12)
end

function TileData.get_points(addr, scale)
	local function tget(prop)
		return TileData:get_value(addr, prop)
	end
	local pntCount =  TileData.get_point_count(addr)
	local pnts = {}
	for i = 1,pntCount do
		entry = {}
		for coordI = 1,3 do
			entry[("xyz"):sub(coordI,coordI)] = mainmemory.read_s16_be(addr + 0x08*i + (coordI - 1)*2) / scale
		end
		table.insert(pnts, entry)
	end

	return pnts
end

function TileData.get_start_address()
	return mainmemory.read_u32_be(0x040F58)
end

function TileData.get_first_tile_address()
	-- Precisely skips a list of 31 pointers and a 00000000
	-- This is in 0x040F5C
	ptr = mainmemory.read_u32_be(0x040F5C)
	assert(ptr == (TileData.get_start_address() + 0x80), "Assertion failed")
	return ptr
	
end

function TileData.get_last_tile_address()
	-- The last tile, not the end of data
	return mainmemory.read_u32_be(0x040F60)
end

function TileData.get_links(addr)
	-- These links are addresses :) 
	local tileDataStart = TileData.get_start_address() - 0x80000000
	local function tget(prop)
		return TileData:get_value(addr, prop)
	end

	local links = {}
	local pntCount = TileData.get_point_count(addr)

	for i = 1,pntCount do
		offset = mainmemory.read_u16_be(addr + 0x8*i + 0x6)
		if (offset == 0) then
			table.insert(links, 0)	-- we even saw a test for 0 remember
		else
			table.insert(links, tileDataStart + 0x8 * offset)
		end
	end
	return links
end

function TileData.get_size(addr)
	return 0x8 * (TileData.get_point_count(addr) + 1)
end

function TileData.getAllTiles()	
	-- Find all the tiles
	local allAddrs = {}
	local haveSeen = {}
	haveSeen[0] = true
	local seenCount = 0
	local stack = {
		TileData.get_first_tile_address() - 0x80000000,
	}

	while table.getn(stack) > 0 do
		local addr = table.remove(stack)

		local links = TileData.get_links(addr)
		for i, link in ipairs(links) do
			if haveSeen[link] == nil then
				haveSeen[link] = true
				seenCount = seenCount + 1
				table.insert(allAddrs, link)
				table.insert(stack, link)
			end
		end
	end

	return allAddrs
end

-- Takes an array of tiles, thought of as some subset of area A,
-- and a function which determines if a tile is in area B.
-- Returns an unordered collection of lines (pair of points)
--   which form the border between area B and these tiles
function TileData.getBoundary(tiles, isExternal)
	local boundary = {}
	for _, A_addr in ipairs(tiles) do
		local pnts = TileData.get_points(A_addr, GameData.get_scale())
		-- for ease
		pnts[table.getn(pnts) + 1] = pnts[1]
		for i, neighbour_addr in ipairs(TileData.get_links(A_addr)) do
			if (neighbour_addr ~= 0 and isExternal(neighbour_addr)) then
				table.insert(boundary, {pnts[i], pnts[i+1]})
			end
		end
	end

	return boundary
end


-- Pad data
PadData = Data.create()

PadData.size = 0x10
PadData.metadata = {
	{["offset"] = 0x00, ["size"] = 0x4, ["type"] = "signed",	["name"] = "number"},
	{["offset"] = 0x04, ["size"] = 0x4, ["type"] = "hex",	["name"] = "linkageList"}, -- indices, not IDs
	{["offset"] = 0x08, ["size"] = 0x4, ["type"] = "unsigned", 	["name"] = "setIndex"},
	{["offset"] = 0x0C, ["size"] = 0x4, ["type"] = "signed", 	["name"] = "dist_tmp"},
}

function PadData.get_start_address()
	return memory.read_u32_be(0x75d00) - 0x80000000
end