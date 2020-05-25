require "Data\\GE\\IntroData"

IntroDataReader = {}
IntroDataReader.__index = IntroDataReader

function IntroDataReader.create()
	local intro_data_reader = {}
	
	setmetatable(intro_data_reader, IntroDataReader)
	
	intro_data_reader.current_address = IntroData.get_start_address()
	intro_data_reader.current_data = IntroData.get_data(intro_data_reader.current_address)
	
	return intro_data_reader
end

function IntroDataReader:reached_end()
	return (not self.current_data and true or false)
end

function IntroDataReader:next_item()
	if self:reached_end() then
		return
	end
	
	self.current_address = (self.current_address + self.current_data.size)
	self.current_data = IntroData.get_data(self.current_address)
end

function IntroDataReader:get_value(_name)
	return self.current_data:get_value(self.current_address, _name)
end

function IntroDataReader.for_each(_function)
	local intro_data_reader = IntroDataReader.create()
	
	while not intro_data_reader:reached_end() do
		_function(intro_data_reader)
	
		intro_data_reader:next_item()
	end
end