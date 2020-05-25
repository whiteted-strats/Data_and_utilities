require "Data\\Data"
require "Data\\GE\\GameData"

-- Now including tile data.. though it's grown a bit big.

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

function TileData.get_tileData_start()
	return mainmemory.read_u32_be(0x040F58)
end

function TileData.get_first_tile_address()
	-- Precisely skips a list of 31 pointers and a 00000000
	-- This is in 0x040F5C
	ptr = mainmemory.read_u32_be(0x040F5C)
	assert(ptr == (TileData.get_tileData_start() + 0x80), "Assertion failed")
	return ptr
	
end

function TileData.get_last_tile_address()
	-- The last tile, not the end of data
	return mainmemory.read_u32_be(0x040F60)
end

function TileData.get_links(addr)
	-- Returns [point_count] tile addresses, replacing links to the 'null tile' with a nullptr
	local tileDataStart = TileData.get_tileData_start() - 0x80000000
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
	-- Gets the actual size
	return 0x8 * (TileData.get_point_count(addr) + 1)
end

function TileData.getAllTiles()	
	-- Find all the tiles
	-- This will include some wacky ones which are disconnected from the main area
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
		pnts[table.getn(pnts) + 1] = pnts[1] 	-- for ease
		for i, neighbour_addr in ipairs(TileData.get_links(A_addr)) do
			if (neighbour_addr ~= 0 and isExternal(neighbour_addr)) then
				table.insert(boundary, {pnts[i], pnts[i+1]})
			end
		end
	end

	return boundary
end