-- An almost complete copy of Henrik's (PD) GuardDataReader
require "Data\\GE\\ScriptData"

ScriptDataReader = {}
ScriptDataReader.__index = ScriptDataReader

function ScriptDataReader.create()
	local script_data_reader = {}
	
   setmetatable(script_data_reader, ScriptDataReader)
   
   script_data_reader.current_address = ScriptData.get_start_address()
   script_data_reader.current_slot = 1
   
   return script_data_reader
end

function ScriptDataReader:reached_end()
	-- Only change, was >= (probably a pd-change)
	return (self.current_slot > ScriptData.get_capacity())	
end

function ScriptDataReader:next_slot()
	if self:reached_end() then
		return
	end
	
	self.current_address = (self.current_address + ScriptData.size)
	self.current_slot = (self.current_slot + 1)
end

function ScriptDataReader:is_empty()
	return false
end

function ScriptDataReader:is_clone()
	return ScriptData.is_clone(self.current_address)
end

function ScriptDataReader:get_value(_name)
	return ScriptData:get_value(self.current_address, _name)
end

function ScriptDataReader.for_each(_function)
	local script_data_reader = ScriptDataReader.create()

	while not script_data_reader:reached_end() do
		if not script_data_reader:is_empty() then
			_function(script_data_reader)
		end
	
		script_data_reader:next_slot()
	end
end