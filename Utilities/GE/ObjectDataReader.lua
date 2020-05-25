require "Data\\GE\\ObjectData"
require "Data\\GE\\ConditionData"
require "Data\\GE\\CollisionData"

ObjectDataReader = {}
ObjectDataReader.__index = ObjectDataReader

function ObjectDataReader.create()
	local object_data_reader = {}
	
	setmetatable(object_data_reader, ObjectDataReader)
	
	object_data_reader.current_address = ObjectData.get_start_address()
	object_data_reader.current_data = ObjectData.get_data(object_data_reader.current_address)
	
	return object_data_reader
end

function ObjectDataReader:clone()
	local clone = {}
	
	setmetatable(clone, ObjectDataReader)
	
	clone.current_address = self.current_address
	clone.current_data = self.current_data
	
	return clone
end

function ObjectDataReader:reached_end()
	return (not self.current_data and true or false)
end

function ObjectDataReader:next_object()
	if self:reached_end() then
		return
	end
	
	self.current_address = (self.current_address + self.current_data.size)
	
	-- Is this objective data?
	if (self.current_data.type == 0x17) then
		local condition_address = self.current_address
		local condition_data = ConditionData.get_data(condition_address)
		
		while condition_data do
			condition_address = (condition_address + condition_data.size)
			condition_data = ConditionData.get_data(condition_address)
		end
		
		self.current_address = (condition_address + 4)
	end
	
	self.current_data = ObjectData.get_data(self.current_address)
end

function ObjectDataReader:has_value(_name)
	return self.current_data:has_value(_name)
end

function ObjectDataReader:get_value(_name)
	return self.current_data:get_value(self.current_address, _name)
end

function ObjectDataReader:check_bits(_name, _mask)
	return self.current_data:check_bits(self.current_address, _name, _mask)
end

function ObjectDataReader:is_collidable()
	return (self:has_value("flags_1") and self:check_bits("flags_1", 0x00000100))
end

function ObjectDataReader:get_collision_data()
	local collision_data_address = (self:get_value("collision_data_pointer") - 0x80000000)
	
	local points = {}
	local count = CollisionData:get_value(collision_data_address, "point_count")
	
	for i = 1, count, 1 do
		points[i] = CollisionData:get_value(collision_data_address, "point_" .. i)
	end
	
	local min_y = CollisionData:get_value(collision_data_address, "min_y")
	local max_y = CollisionData:get_value(collision_data_address, "max_y")
	
	return points, min_y, max_y
end

function ObjectDataReader.for_each(_function)
	local object_data_reader = ObjectDataReader.create()
	
	while not object_data_reader:reached_end() do
		_function(object_data_reader)
	
		object_data_reader:next_object()
	end
end