require "Data\\GE\\Version"

GameData = {}

GameData.random_number_generator_address = ({['U'] = 0x024464, ['P'] = 0x020FE4})[__GE_VERSION__]
GameData.current_scene_address = ({['U'] = 0x02A8C0, ['P'] = 0x025e10})[__GE_VERSION__]
GameData.current_mission_address = ({['U'] = 0x02A8FB, ['P'] = 0x025e4b})[__GE_VERSION__] -- PAL just based off offset from scene_address
GameData.global_timer_delta_address = ({['U'] = 0x048378, ['P'] = 0x040FF8})[__GE_VERSION__]
GameData.global_timer_address = ({['U'] = 0x04837C, ['P'] = 0x040FFC})[__GE_VERSION__]
-- 0x0 = Not running, 0x1 = Running, 0x3 = Paused, 0x4 = running too?
GameData.mission_state_address = ({['U'] = 0x0484C0, ['P'] = 0x041140})[__GE_VERSION__] -- PAL checkme!

GameData.mission_timer_address = ({['U'] = 0x079A20, ['P'] = 0x068500})[__GE_VERSION__]	-- Sounds familiar
GameData.scale_address = ({['U'] = 0x040F44, ['P'] = 0x03ab94})[__GE_VERSION__]

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
	[0x05] = "Surface_1",
	[0x06] = "Bunker_1",
	[0x08] = "Silo",
	[0x0A] = "Frigate",
	[0x0C] = "Surface_2",
	[0x0D] = "Bunker_2",
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