Config                            = {}
Config.MaxInService               = -1
Config.Locale                     = 'en'
Config.MarkerType                 = 1
Config.MarkerSize                 = { x = 1.5, y = 1.5, z = 0.5 }
Config.MarkerColor                = { r = 0, g = 255, b = 255 }
Config.DrawDistance               = 10.0



Config.EnablePlayerManagement     = true
Config.EnableESXIdentity          = true
Config.EnableNonFreemodePeds      = true
Config.EnableLicenses             = false

Config.EnableHandcuffTimer        = true 	-- เปิดการใช้เวลาในการปลดกุญแจมืออัตโนมัติ
Config.HandcuffTimer              = 30 * 60000 -- mins เวลาในการปลดกุญแจมืออัตโนมัติ


-- ตั้งจุดระบบจัดการคนหน่วยงาน ของ boss
Config.BossMenu = { 
	Pos = {x = -511.782, y = -233.193, z = 36.084}
}


-- ตั้งจุดในระบบสภา
Config.CouncilStation = {

	Council = {

		Blip = {
			Coords  = vector3(-521.147, -245.563, 36.079),
			Sprite  = 439,
			Display = 4,
			Scale   = 1.0,
			Colour  = 5
		},

		Cloakrooms = {
			vector3(-513.119, -226.347, 36.408)
		},

		Armories = {
			vector3(-512.113, -222.899, 36.746)
		},

		Vehicles = {
			{
				Spawner = vector3(-519.114, -224.460, 36.728),
				InsideShop = vector3(-530.203, -242.017, 35.859),
				heading = 208.27,
				SpawnPoints = {
					{ coords = vector3(-519.589, -236.459, 35.861), heading = 208.27, radius = 1.5 },
					{ coords = vector3(-515.467, -243.868, 35.768), heading = 208.27, radius = 1.5 },
				}
			},
		},

		Helicopters = {
			{
				Spawner = vector3(-540.699, -236.932, 36.730),
				InsideShop = vector3(-541.437, -253.221, 37.902),
				heading = 32.14,
				SpawnPoints = {
					{ coords = vector3(-541.437, -253.221, 37.902), heading = 32.14, radius = 15.0 }
				}
			},
		},


	},

}


-- ร้านขายอาวุธของสภา
Config.AuthorizedWeapons = {
	council = {
		{ weapon = 'WEAPON_STUNGUN', price = 2000 },
		{ weapon = 'WEAPON_FLASHLIGHT', price = 1000 }
	},
	
	Hcouncil = {
		{ weapon = 'WEAPON_STUNGUN', price = 2000 },
		{ weapon = 'WEAPON_FLASHLIGHT', price = 1000 }
	},
	
	chef = {
		{ weapon = 'WEAPON_STUNGUN', price = 2000 },
		{ weapon = 'WEAPON_FLASHLIGHT', price = 1000 }
	},
	
	cboss = {
		{ weapon = 'WEAPON_STUNGUN', price = 2000 },
		{ weapon = 'WEAPON_FLASHLIGHT', price = 1000 }
	},

	boss = {
		{ weapon = 'WEAPON_PUMPSHOTGUN', components = { 2000, 6000, nil }, price = 10000 },
		{ weapon = 'WEAPON_STUNGUN', price = 2000 },
		{ weapon = 'WEAPON_FLASHLIGHT', price = 1000 }
	}
}


-- รถหน่วยงานสภา
Config.AuthorizedVehicles = { 
	Shared = {	-- ตั้งให้เห็นตามยศตำแหน่ง ยึดจาก SQL ( job_grades > name ) *Shared = เห็นทุกตำแหน่ง
		{ model = 'insurgent2', label = 'Insurgent Car', price = 1000 },
		-- { model = 'kuruma2', label = 'Kuruma 2', price = 5000 },
		-- { model = 'toros', label = 'Toros', price = 5000 },
		-- { model = 'alphard', label = 'alphard', price = 50000 },
	},

	council = {
		-- { model = 'carbonizzare', label = 'carbonizzare', price = 15000 },
		-- { model = 'alphard', label = 'alphard', price = 50000 },
	},
	
	Hcouncil = {
		{ model = 'carbonizzare', label = 'carbonizzare', price = 15000 },
		-- { model = 'alphard', label = 'alphard', price = 50000 },
		-- { model = 'q820', label = 'Audi Council', price = 50000 },
	},
	
	chef = {
		{ model = 'carbonizzare', label = 'carbonizzare', price = 15000 },
		-- { model = 'alphard', label = 'alphard', price = 50000 },
		-- { model = 'q820', label = 'Audi Council', price = 50000 },
	},

	cboss = {
		{ model = 'carbonizzare', label = 'carbonizzare', price = 15000 },
		-- { model = 'alphard', label = 'alphard', price = 50000 },
		-- { model = 'RS62', label = 'RS62', price = 100000 },
		-- { model = 'q820', label = 'Audi Council', price = 50000 },
	},

	boss = {
		{ model = 'carbonizzare', label = 'carbonizzare', price = 15000 },
		-- { model = 'alphard', label = 'alphard', price = 50000 },
		-- { model = 'RS62', label = 'RS62', price = 100000 },
		-- { model = 'q820', label = 'Audi Council', price = 50000 },
	}
}


-- ฮอหน่วยงานสภา
Config.AuthorizedHelicopters = {
	
	council = { -- ตั้งให้เห็นตามยศตำแหน่ง ยึดจาก SQL ( job_grades > name )
		{ model = 'buzzard2', label = 'Buzzard2', livery = 0, price = 15000 },
	},

	Hcouncil = {
		{ model = 'buzzard2', label = 'Buzzard2', livery = 0, price = 15000 },
		{ model = 'frogger', label = 'frogger', livery = 0, price = 15000 }
	},
	
	chef = {
		{ model = 'buzzard2', label = 'Buzzard2', livery = 0, price = 15000 },
		{ model = 'frogger', label = 'frogger', livery = 0, price = 15000 }
	},
	
	cboss = {
		{ model = 'buzzard2', label = 'Buzzard2', livery = 0, price = 15000 },
		{ model = 'frogger', label = 'frogger', livery = 0, price = 15000 }
	},

	boss = {
		{ model = 'buzzard2', label = 'Buzzard2', livery = 0, price = 15000 },
		{ model = 'frogger', label = 'frogger', livery = 0, price = 15000 }
	}
}



-- ชุดเครื่องแบบหน่วยงานสภา
Config.Uniforms = {
	council = { -- ตั้งให้เห็นตามยศตำแหน่ง ยึดจาก SQL ( job_grades > name )
		male = {
			['tshirt_1'] = 67, ['tshirt_2'] = 1,
			['torso_1'] = 42, ['torso_2'] = 1,
			['pants_1'] = 12, ['pants_2'] = 0,
			['arms'] = 1, ['arms_2'] = 0,
			['decals_1'] = 0,['decals_2'] = 0,
		},
		female = {
			['tshirt_1'] = 151, ['tshirt_2'] = 1,
			['torso_1'] = 41, ['torso_2'] = 1,
			['pants_1'] = 118, ['pants_2'] = 0,
			['arms'] = 14, ['arms_2'] = 0,
			['decals_1'] = 0,['decals_2'] = 0,
		}
	},
	
	Hcouncil = {
		male = {
			['tshirt_1'] = 67, ['tshirt_2'] = 1,
			['torso_1'] = 42, ['torso_2'] = 1,
			['pants_1'] = 12, ['pants_2'] = 0,
			['arms'] = 1, ['arms_2'] = 0,
			['decals_1'] = 0,['decals_2'] = 0,
		},
		female = {
			['tshirt_1'] = 151, ['tshirt_2'] = 1,
			['torso_1'] = 41, ['torso_2'] = 1,
			['pants_1'] = 118, ['pants_2'] = 0,
			['arms'] = 14, ['arms_2'] = 0,
			['decals_1'] = 0,['decals_2'] = 0,
		}
	},
	chef = {
		male = {
			['tshirt_1'] = 67, ['tshirt_2'] = 1,
			['torso_1'] = 42, ['torso_2'] = 1,
			['pants_1'] = 12, ['pants_2'] = 0,
			['arms'] = 1, ['arms_2'] = 0,
			['decals_1'] = 0,['decals_2'] = 0,
		},
		female = {
			['tshirt_1'] = 151, ['tshirt_2'] = 1,
			['torso_1'] = 41, ['torso_2'] = 1,
			['pants_1'] = 118, ['pants_2'] = 0,
			['arms'] = 14, ['arms_2'] = 0,
			['decals_1'] = 0,['decals_2'] = 0,
		}
	},
	
	cboss = {
		male = {
			['tshirt_1'] = 67, ['tshirt_2'] = 1,
			['torso_1'] = 42, ['torso_2'] = 1,
			['pants_1'] = 12, ['pants_2'] = 0,
			['arms'] = 1, ['arms_2'] = 0,
			['decals_1'] = 0,['decals_2'] = 0,
		},
		female = {
			['tshirt_1'] = 151, ['tshirt_2'] = 1,
			['torso_1'] = 41, ['torso_2'] = 1,
			['pants_1'] = 118, ['pants_2'] = 0,
			['arms'] = 14, ['arms_2'] = 0,
			['decals_1'] = 0,['decals_2'] = 0,
		}
	},
	
	boss = {
		male = {
			['tshirt_1'] = 67, ['tshirt_2'] = 1,
			['torso_1'] = 42, ['torso_2'] = 1,
			['pants_1'] = 12, ['pants_2'] = 0,
			['arms'] = 1, ['arms_2'] = 0,
			['decals_1'] = 0,['decals_2'] = 0,
		},
		female = {
			['tshirt_1'] = 151, ['tshirt_2'] = 1,
			['torso_1'] = 41, ['torso_2'] = 1,
			['pants_1'] = 118, ['pants_2'] = 0,
			['arms'] = 14, ['arms_2'] = 0,
			['decals_1'] = 0,['decals_2'] = 0,
		}
	},
	
}