require "Data\\GE\\ObjectData"
require "Data\\GE\\Version"

-- TODO: Find a more suitable name for this class, since it represents 
--		 all spawned weapons, and not just projectiles.
ProjectileData = {}

ProjectileData.start_address = ({['U'] = 0x071E80, ['P'] = 0x060dc0,})[__GE_VERSION__]	-- doesn't need reading

-- NTSC-U only and irrel
--ProjectileData.current_slot_address = 0x030AF8
--ProjectileData.previous_entry_pointer_address = 0x073EA4
ProjectileData.size = WeaponData.size
ProjectileData.capacity = 30


ProjectileData.wd_types = {
	[0x3] = "Throwing knife",
	[0x7] = "Spawned-Guard's Weapon",
	[0x8] = "Spawned-Guard's Weapon",
	[0x11] = "Spawned-Guard's Sniper",
	[0x16] = "Spawned-Guard's Laser",
	[0x1A] = "Grenade",
	[0x1B] = "Timed mine",
	[0x1C] = "Proximity mine?",
	[0x1D] = "Remote Mine",
	[0x22] = "Plastique",
	[0x2F] = "Bug",
	[0x56] = "Tank Shell",
	[0x57] = "GL grenade",
}

function ProjectileData.is_empty(_projectile_address)
	local position_data_address = WeaponData:get_value(_projectile_address, "position_data_pointer")
	
	return (position_data_address == 0x00000000)
end

function ProjectileData.get_value(_projectile_address, _name)
	return WeaponData:get_value(_projectile_address, _name)
end