require "Data\\Data"

local DestroyObjectData = Data.create()

DestroyObjectData.type = 0x19
DestroyObjectData.size = 0x08
DestroyObjectData.metadata = 
{
}

local TruifyFlagsData = Data.create()

TruifyFlagsData.type = 0x1A
TruifyFlagsData.size = 0x08
TruifyFlagsData.metadata = 
{
}

local FalsifyFlagsData = Data.create()

FalsifyFlagsData.type = 0x1B
FalsifyFlagsData.size = 0x08
FalsifyFlagsData.metadata = 
{
}

local CollectObjectData = Data.create()

CollectObjectData.type = 0x1C
CollectObjectData.size = 0x08
CollectObjectData.metadata = 
{
}

local DiscardObjectData = Data.create()

DiscardObjectData.type = 0x1D
DiscardObjectData.size = 0x08
DiscardObjectData.metadata = 
{
}

local PhotographObjectData = Data.create()

PhotographObjectData.type = 0x1E
PhotographObjectData.size = 0x10
PhotographObjectData.metadata = 
{
}

local EnterRoomData = Data.create()

EnterRoomData.type = 0x20
EnterRoomData.size = 0x10
EnterRoomData.metadata = 
{
}

local DepositObjectData = Data.create()

DepositObjectData.type = 0x21
DepositObjectData.size = 0x14
DepositObjectData.metadata = 
{
}

local AnalyzeKeyData = Data.create()

AnalyzeKeyData.type = 0x22
AnalyzeKeyData.size = 0x04
AnalyzeKeyData.metadata = 
{
}

ConditionData = {}

ConditionData.data_types =
{
	[0x19] = DestroyObjectData,
	[0x1A] = TruifyFlagsData,
	[0x1B] = FalsifyFlagsData,
	[0x1C] = CollectObjectData,
	[0x1D] = DiscardObjectData,
	[0x1E] = PhotographObjectData,
	[0x20] = EnterRoomData,
	[0x21] = DepositObjectData,
	[0x22] = AnalyzeKeyData
}

function ConditionData.get_type(_condition_address)
	return mainmemory.read_u32_be(_condition_address)
end

function ConditionData.get_data(_condition_address)
	local condition_type = ConditionData.get_type(_condition_address)

	return ConditionData.data_types[condition_type]
end