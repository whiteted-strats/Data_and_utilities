require "Data\\Data"
require "Data\\GE\\Version"

-- Looks suspiciously like the explosion data to me..
SmokeData = Data.create()

SmokeData.start_pointer_address = ({['U'] = 0x07A140, ['P'] = 0x068c50,})[__GE_VERSION__]  
SmokeData.size = 0x198
SmokeData.capacity = 20
SmokeData.metadata = 
{
	{["offset"] = 0x000, ["size"] = 0x4, ["type"] = "hex", ["name"] = "position_data_pointer"},
}

function SmokeData.get_start_address()
	return (mainmemory.read_u32_be(SmokeData.start_pointer_address) - 0x80000000)
end

function SmokeData.is_empty(_explosion_address)
	local position_data_address = SmokeData:get_value(_explosion_address, "position_data_pointer")
	
	return (position_data_address == 0x00000000)
end