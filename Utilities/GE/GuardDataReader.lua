require "Data\\GE\\GuardData"
require "Data\\GE\\PositionData"

GuardDataReader = {}
GuardDataReader.__index = GuardDataReader

function GuardDataReader.create()
	local guard_data_reader = {}
	
   setmetatable(guard_data_reader, GuardDataReader)
   
   guard_data_reader.current_address = GuardData.get_start_address()
   guard_data_reader.current_slot = 1
   
   return guard_data_reader
end

function GuardDataReader:reached_end()
	return (self.current_slot >= GuardData.get_capacity())	
end

function GuardDataReader:next_slot()
	if self:reached_end() then
		return
	end
	
	self.current_address = (self.current_address + GuardData.size)
	self.current_slot = (self.current_slot + 1)
end

function GuardDataReader:is_empty()
	return GuardData.is_empty(self.current_address)
end

function GuardDataReader:is_clone()
	return GuardData.is_clone(self.current_address)
end

function GuardDataReader:get_value(_name)
	return GuardData:get_value(self.current_address, _name)
end

function GuardDataReader:get_position()
	local position_data_address = (self:get_value("position_data_pointer") - 0x80000000)
	
	return PositionData:get_value(position_data_address, "position")
end

function GuardDataReader.for_each(_function)
	local guard_data_reader = GuardDataReader.create()
	
	while not guard_data_reader:reached_end() do
		if not guard_data_reader:is_empty() then
			_function(guard_data_reader)
		end
	
		guard_data_reader:next_slot()
	end
end