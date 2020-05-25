GameData = {}

GameData.random_number_generator_address = 0x024464
GameData.current_scene_address = 0x02A8C0
GameData.current_mission_address = 0x02A8FB
GameData.global_timer_delta_address = 0x048378
GameData.global_timer_address = 0x04837C
GameData.mission_state_address = 0x0484C0 -- 0x0 = Not running, 0x1 = Running, 0x3 = Paused, 0x4 = running too?
GameData.mission_timer_address = 0x079A20
GameData.scale_address = 0x040F44

GameData.scene_index_to_name = 
{
	"Nintendo Logo",
	"Rareware Logo",
	"Bond Intro",
	"Goldeneye Logo",
	"File Select",
	"File Menu",
	"Mission Select",
	"Difficulty Select",
	"007 Settings",
	"Mission Briefing",
	"Mission Start",
	"Mission Status",
	"Mission Time"
}
-- Adjusting for base 0
GameData.scene_index_to_name[0] = "Twycross Classification"

GameData.mission_index_to_name =
{
	[0x01] = "Dam",
	[0x02] = "Facility",
	[0x03] = "Runway",
	[0x05] = "Surface 1",
	[0x06] = "Bunker 1",
	[0x08] = "Silo",
	[0x0A] = "Frigate",
	[0x0C] = "Surface 2",
	[0x0D] = "Bunker 2",
	[0x0F] = "Statue",
	[0x10] = "Archives",
	[0x11] = "Streets",
	[0x12] = "Depot",
	[0x13] = "Train",
	[0x15] = "Jungle",
	[0x16] = "Control",
	[0x17] = "Caverns",
	[0x18] = "Cradle",
	[0x1A] = "Aztec",
	[0x1C] = "Egyptian"
}

function GameData.get_random_number_generator()
	return mainmemory.read_u32_be(GameData.random_number_generator_address)
end

function GameData.get_current_scene()
	return mainmemory.read_u32_be(GameData.current_scene_address)
end

function GameData.get_current_mission()
	return mainmemory.read_u8(GameData.current_mission_address)
end

function GameData.get_scene_name(_scene)
	return GameData.scene_index_to_name[_scene]
end

function GameData.get_mission_name(_mission)
	return GameData.mission_index_to_name[_mission]
end

function GameData.get_global_timer_delta()
	return mainmemory.readfloat(GameData.global_timer_delta_address, true)
end

function GameData.get_global_timer()
	return mainmemory.read_u32_be(GameData.global_timer_address)
end

function GameData.get_mission_state()
	return mainmemory.read_u32_be(GameData.mission_state_address)
end

function GameData.get_mission_time()
	return mainmemory.read_u32_be(GameData.mission_timer_address)
end

function GameData.get_scale()
	return mainmemory.readfloat(GameData.scale_address, true)
end