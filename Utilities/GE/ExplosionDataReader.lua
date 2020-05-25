require "Data\\GE\\ExplosionData"
require "Data\\GE\\PositionData"

ExplosionDataReader = {}
ExplosionDataReader.__index = ExplosionDataReader

function ExplosionDataReader.create()
	local explosion_data_reader = {}
	
	setmetatable(explosion_data_reader, ExplosionDataReader)
	
	explosion_data_reader.current_address = ExplosionData.get_start_address()
	explosion_data_reader.current_slot = 1
	explosion_data_reader.current_type = explosion_data_reader:get_value("explosion_type")
	
	return explosion_data_reader
end

function ExplosionDataReader:reached_end()
	return (self.current_slot >= ExplosionData.capacity)
end

function ExplosionDataReader:next_slot()
	if self:reached_end() then
		return
	end

	self.current_address = (self.current_address + ExplosionData.size)
	self.current_slot = (self.current_slot + 1)
	self.current_type = self:get_value("explosion_type")
end

function ExplosionDataReader:is_empty()
	return ExplosionData.is_empty(self.current_address)
end

function ExplosionDataReader:get_value(_name)
	return ExplosionData:get_value(self.current_address, _name)
end

function ExplosionDataReader:get_position()
	local position_data_address = (self:get_value("position_data_pointer") - 0x80000000)
	
	return PositionData:get_value(position_data_address, "position")
end

function ExplosionDataReader:get_type_value(_name) 
	return ExplosionTypeData.get_value(self.current_type, _name)
end

function ExplosionDataReader.for_each(_function)
	local explosion_data_reader = ExplosionDataReader.create()
	
	while not explosion_data_reader:reached_end() do
		if not explosion_data_reader:is_empty() then
			_function(explosion_data_reader)
		end
	
		explosion_data_reader:next_slot()
	end
end