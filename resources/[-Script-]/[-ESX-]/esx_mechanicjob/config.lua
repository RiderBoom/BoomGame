Config                            = {}
Config.Marker                     = { type = 1, x = 1.5, y = 1.5, z = 0.5, r = 255, g = 161, b = 0, a = 100, rotate = false }
Config.DrawDistance               = 10.0
Config.Locale                     = 'en'
Config.EnablePlayerManagement     = true
Config.EnableSocietyOwnedVehicles = false
Config.MaxInService               = -1


Config.NPCJobEarnings             = { min = 15, max = 40 }
Config.CheckItem				  = true   		-- ต้องการให้ตรวจสอบ Item ก่อนซ่อมหรือไม่
Config.UseItem					  = 'fixkit'  	-- ไอเทมที่ให้หักเมื่อใช้ซ่อมรถ


-- ตั้งจุดระบบจัดการคนหน่วยงาน ของ boss
Config.BossMenu = { 
	Pos = {x = -362.255, y = -125.919, z = 38.698}
}


-- ตั้งจุดในระบบช่าง
Config.MechanicStation = {

	machanic = {

		Blip = {
			Coords  = vector3(-363.146, -122.885, 38.696),
			Sprite  = 446,
			Display = 4,
			Scale   = 1.0,
			Colour  = 5
		},

		Cloakrooms = {
			vector3(-377.814, -115.790, 38.701)
		},

		Vehicles = {
			{
				Spawner = vector3(-377.117, -122.544, 38.688),
				InsideShop = vector3(-363.146, -122.885, 38.696),
				heading = 208.27,
				SpawnPoints = {
					{ coords = vector3(-372.535, -113.204, 38.681), heading = 208.27, radius = 1.5 },
				}
			},
		},


	},

}

-- รถในร้านค้า หน่วยงานช่าง
Config.AuthorizedVehicles = {

	Shared = { -- ตั้งให้เห็นตามยศตำแหน่ง ยึดจาก SQL ( job_grades > name ) *Shared = ซื้อได้ทุกคน
		{ model = 't20', label = 'Mechanic Car', price = 500},

	},

	
}


-- ตั้งชุดประจำหน่วยงานช่าง
Config.MechanicUniforms = {
	
	mechanic = { -- ตั้งให้เห็นตามยศตำแหน่ง ยึดจาก SQL ( job_grades > name )
		male = {
			['tshirt_1'] = 15, 
			['tshirt_2'] = 0,
			['torso_1'] = 257, 
			['torso_2'] = 0,
			['arms'] = 6,
			['pants_1'] = 96, 
			['pants_2'] = 0,
			['shoes_1'] = 66, 
			['shoes_2'] = 0,
			['helmet_1'] = -1, 
			['helmet_2'] = 0,
			['watches_1'] = -1, 
			['watches_2'] = 0,
			['glasses_1'] = -1, 
			['glasses_2'] = 0,
			['bracelets_1'] = -1, 
			['bracelets_2'] = 0,
			['chain_1'] = 0, 
			['chain_2'] = 0,
			['decals_1'] = 0, 
			['decals_2'] = 0,
			['mask_1'] = 0, 
			['mask_2'] = 0,
			['bproof_1'] = 0,
			['bproof_2'] = 0
		},
		female = {
			['tshirt_1'] = 68, 
			['tshirt_2'] = 0,
			['torso_1'] = 255, 
			['torso_2'] = 0,
			['arms'] = 0,
			['pants_1'] = 83, 
			['pants_2'] = 0,
			['shoes_1'] = 55, 
			['shoes_2'] = 0,
			['helmet_1'] = -1, 
			['helmet_2'] = 0,
			['watches_1'] = -1, 
			['watches_2'] = 0,
			['glasses_1'] = -1, 
			['glasses_2'] = 0,
			['bracelets_1'] = -1, 
			['bracelets_2'] = 0,
			['chain_1'] = 0, 
			['chain_2'] = 0,
			['decals_1'] = 0, 
			['decals_2'] = 0,
			['mask_1'] = 0, 
			['mask_2'] = 0,
			['bproof_1'] = 0,
			['bproof_2'] = 0
		}  
	},
	
}



