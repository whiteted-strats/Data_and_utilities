Data = {}
Data.__index = Data

memory.usememorydomain("RDRAM")	-- always runs

function Data.create()
	local data = {}
	
	setmetatable(data, Data)
	
	return data
end

function Data.__concat(_lhs, _rhs)
	local concatenation = Data.create()
	
	concatenation.type = _rhs.type
	concatenation.size = (_lhs.size + _rhs.size)
	concatenation.metadata = {}
	
	if _lhs.metadata then
		for index, metadata in ipairs(_lhs.metadata) do
			table.insert(concatenation.metadata, metadata)
		end
	end
	
	if _rhs.metadata then
		for index, metadata in ipairs(_rhs.metadata) do
			metadata.offset = (metadata.offset + _lhs.size)
		
			table.insert(concatenation.metadata, metadata)
		end
	end
	
	return concatenation
end


function Data:get_metadata(_name)
	if not self.metadata_by_name then
		self.metadata_by_name = {}

		for index, metadata in ipairs(self.metadata) do
			self.metadata_by_name[metadata.name] = metadata
		end
	end

	return self.metadata_by_name[_name]
end

local dimension_mnemonics = {"x", "y", "z", "w"}

local function read_vector(_address, _metadata)
	local dimensions = (_metadata.size / 0x04)	
	local vector = {}	

	for i = 1, dimensions, 1 do
		local offset = (_metadata.offset + ((i - 1) * 0x04))
		
		vector[dimension_mnemonics[i]] = mainmemory.readfloat((_address + offset), true)
	end
	
	return vector
end

function Data:has_value(_name)
	return (self:get_metadata(_name) ~= nil)
end

function Data:get_value(_address, _name)
	local metadata = self:get_metadata(_name)
	
	if not metadata then
		error(string.format("Invalid name: %s", _name))
	elseif (metadata.size == 0x01) then
		return mainmemory.read_u8(_address + metadata.offset)
	elseif (metadata.size == 0x02) then
		if metadata.type == "signed" then
			return mainmemory.read_s16_be(_address + metadata.offset)
		end
		return mainmemory.read_u16_be(_address + metadata.offset)
	elseif (metadata.size == 0x03) then
		if metadata.type == "signed" then
			return mainmemory.read_s24_be(_address + metadata.offset)
		end
		return mainmemory.read_u24_be(_address + metadata.offset)
	elseif (metadata.size == 0x04) then
		if (metadata.type == "float") then
			return mainmemory.readfloat((_address + metadata.offset), true)
		elseif metadata.type == "signed" then
			return mainmemory.read_s32_be(_address + metadata.offset)
		else
			return mainmemory.read_u32_be(_address + metadata.offset)
		end
	elseif (metadata.type == "vector") then
		return read_vector(_address, metadata)
	else	
		error(string.format("Invalid size: 0x%X", metadata.size))
	end
end

function Data:check_bits(_address, _name, _mask)
	local metadata = self:get_metadata(_name)
	
	if not metadata then
		error(string.format("Invalid name: %s", _name))
	elseif (metadata.type ~= "bitfield") then
		error(string.format("Invalid type: %s", metadata.type))
	end
	
	local bits = self:get_value(_address, _name)
	
	return (bit.band(bits, _mask) == _mask)
end