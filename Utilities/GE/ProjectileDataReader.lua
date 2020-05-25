require "Data\\GE\\ProjectileData"

ProjectileDataReader = {}
ProjectileDataReader.__index = ProjectileDataReader

function ProjectileDataReader.create()
	local projectile_data_reader = {}
	
	setmetatable(projectile_data_reader, ProjectileDataReader)
	
	projectile_data_reader.current_address = ProjectileData.start_address
	projectile_data_reader.current_slot = 1
	
	return projectile_data_reader
end

function ProjectileDataReader:reached_end()
	return (self.current_slot >= ProjectileData.capacity)
end

function ProjectileDataReader:next_slot()
	if self:reached_end() then
		return
	end

	self.current_address = (self.current_address + ProjectileData.size)
	self.current_slot = (self.current_slot + 1)
end

function ProjectileDataReader:is_empty()
	return ProjectileData.is_empty(self.current_address)
end

function ProjectileDataReader:get_value(_name)
	return ProjectileData.get_value(self.current_address, _name)
end

function ProjectileDataReader.for_each(_function)
	local projectile_data_reader = ProjectileDataReader.create()
	
	while not projectile_data_reader:reached_end() do
		if not projectile_data_reader:is_empty() then
			_function(projectile_data_reader)
		end
	
		projectile_data_reader:next_slot()
	end
end

