Config = {}
Config.MaxInService               = -1
Config.Locale                     = 'en'
Config.MarkerType                 = 1
Config.MarkerSize                 = { x = 1.5, y = 1.5, z = 0.5 }
Config.MarkerColor                = { r = 50, g = 50, b = 204 }
Config.DrawDistance               = 20.0
Config.EnablePlayerManagement     = false
Config.EnableESXIdentity          = true
Config.EnableNonFreemodePeds      = true
Config.EnableLicenses             = true



--=========== Zone Repair Vehicles [Police] ===========--
Config.FixMoney = 100 		-- ราคาต่อการซ่อม 1 ครั้ง
Config.ProgressWait = 15	-- เวลาในการซ่อม
Config.FixZone = { 			-- พิกัดในการซ่อม (เห็นแค่ตำรวจ)
   {x = 463.6465, y = -1015.33, z = 28.075 },
   {x = 463.4929, y = -1019.88, z = 28.105 },
}

--======================================================--


Config.EnableHandcuffTimer        = true 		-- เปิด / ปิด การปลดล็อคกุญแจมืออัตโนมัติ
Config.HandcuffTimer              = 10 * 60000 	-- 10 นาที เวลาในการปลดล็อคกุญแจมืออัตโนมัติ
Config.CurfewCooldown 			  = 20 			-- วินาที Cooldown ในการเคอร์ฟิวของตำรวจ




-- ตั้งจุดระบบเช็คชื่อเจ้าของจากทะเบียนรถ (ที่ไม่ได้อยู่กับตัวรถ)
Config.CheckPlate = vector3(415.7392, -989.102, 28.408)



-- ตั้งจุดระบบจัดการคนหน่วยงาน ของ boss
Config.BossMenu = { 
	Pos = {x = 412.1732, y = -990.382, z = 29.410}
}



-- ตั้งจุดระบบตำรวจ
Config.PoliceStations = {

	LSPD = {

		Blip = {
			Coords  = vector3(437.9429, -981.921, 30.689),
			Sprite  = 526,
			Display = 4,
			Scale   = 1.0,
			Colour  = 38
		},

		Cloakrooms = {
			vector3(412.9326, -993.618, 29.400)
		},

		Armories = {
			vector3(416.6638, -993.383, 29.346)
		},

		Vehicles = {
			{
				Spawner = vector3(436.9077, -1012.87, 28.660),
				InsideShop = vector3(228.5, -993.5, -99.0),
				SpawnPoints = {
					{ coords = vector3(440.9960, -1020.65, 28.635), heading = 96.77, radius = 2.0 },
					{ coords = vector3(430.1676, -1020.82, 28.874), heading = 96.77, radius = 2.0 },
					{ coords = vector3(450.6553, -1019.76, 28.449), heading = 96.77, radius = 2.0 },
				}
			},
		
		
		},

		Helicopters = {
			{
				Spawner = vector3(461.4992, -981.520, 43.691),
				InsideShop = vector3(449.3686, -981.184, 43.691),
				SpawnPoints = {
					{ coords = vector3(449.3686, -981.184, 43.691), heading = 91.69, radius = 10.0 }
				}
			},
		},

	},
	

}



-- ระบบร้านค้าอาวุธของตำรวจ
Config.CoinDutyName = "duty_coin" -- ไอเทมที่ใช้คู่กับเงิน ในการซื้ออาวุธของตำรวจ
Config.AuthorizedWeapons = {
	
	recruit = { -- ตั้งให้เห็นตามยศตำแหน่ง ยึดจาก SQL ( job_grades > name )
		{ weapon = 'WEAPON_NIGHTSTICK', price = 0, items = 0 },
		{ weapon = 'WEAPON_STUNGUN', price = 0, items = 0 },
		{ weapon = 'WEAPON_PUMPSHOTGUN', components = { 2000, 6000, nil }, price = 0, items = 0 },
		{ weapon = 'WEAPON_FLASHLIGHT', price = 80, items = 0 }
	},

	officer = {
		{ weapon = 'WEAPON_NIGHTSTICK', price = 0, items = 0 },
		{ weapon = 'WEAPON_STUNGUN', price = 0, items = 0 },
		{ weapon = 'WEAPON_BZGAS', price = 200, items = 0 },
		{ weapon = 'WEAPON_PUMPSHOTGUN', components = { 2000, 6000, nil }, price = 0, items = 0 },
		{ weapon = 'WEAPON_FLASHLIGHT', price = 0, items = 0 }
	},
		
	polofficer = {
		{ weapon = 'WEAPON_NIGHTSTICK', price = 0, items = 0 },
		{ weapon = 'WEAPON_STUNGUN', price = 0, items = 0 },
		{ weapon = 'WEAPON_BZGAS', price = 200, items = 0 },
		{ weapon = 'WEAPON_PUMPSHOTGUN', components = { 2000, 6000, nil }, price = 0, items = 0 },
		{ weapon = 'WEAPON_FLASHLIGHT', price = 0, items = 0 }
	},
	
	polofficer1 = {
		{ weapon = 'WEAPON_NIGHTSTICK', price = 0, items = 0 },
		{ weapon = 'WEAPON_STUNGUN', price = 0, items = 0 },
		{ weapon = 'WEAPON_BZGAS', price = 200, items = 0 },
		{ weapon = 'WEAPON_PUMPSHOTGUN', components = { 2000, 6000, nil }, price = 0, items = 0 },
		{ weapon = 'WEAPON_FLASHLIGHT', price = 0, items = 0 }
	},
	
	proofficer = {
		{ weapon = 'WEAPON_PISTOL50', components = { 0, 0, 1000, 4000, nil }, price = 10000, items = 0 },
		{ weapon = 'WEAPON_NIGHTSTICK', price = 0, items = 0 },
		{ weapon = 'WEAPON_STUNGUN', price = 0, items = 0 },
		{ weapon = 'WEAPON_BZGAS', price = 200, items = 0 },
		{ weapon = 'WEAPON_PUMPSHOTGUN', components = { 2000, 6000, nil }, price = 0, items = 0 },
		{ weapon = 'WEAPON_FLASHLIGHT', price = 0, items = 0 }
	},

	sergeant = {
		{ weapon = 'WEAPON_PISTOL50', components = { 0, 0, 1000, 4000, nil }, price = 10000, items = 0 },
		{ weapon = 'WEAPON_NIGHTSTICK', price = 0, items = 0 },
		{ weapon = 'WEAPON_STUNGUN', price = 0, items = 0 },
		{ weapon = 'WEAPON_BZGAS', price = 200, items = 0 },
		{ weapon = 'WEAPON_PUMPSHOTGUN', components = { 2000, 6000, nil }, price = 0, items = 0 },
		{ weapon = 'WEAPON_FLASHLIGHT', price = 0, items = 0 }
	},
	
	chef = {
		{ weapon = 'WEAPON_PISTOL50', components = { 0, 0, 1000, 4000, nil }, price = 10000, items = 0 },
		{ weapon = 'WEAPON_NIGHTSTICK', price = 0, items = 0 },
		{ weapon = 'WEAPON_STUNGUN', price = 0, items = 0 },
		{ weapon = 'WEAPON_BZGAS', price = 200, items = 0 },
		{ weapon = 'WEAPON_PUMPSHOTGUN', components = { 2000, 6000, nil }, price = 0, items = 0 },
		{ weapon = 'WEAPON_FLASHLIGHT', price = 0, items = 0 }
	},

	boss = {
		{ weapon = 'WEAPON_PISTOL50', components = { 0, 0, 1000, 4000, nil }, price = 10000, items = 0 },
		{ weapon = 'WEAPON_NIGHTSTICK', price = 0, items = 0 },
		{ weapon = 'WEAPON_STUNGUN', price = 0, items = 0 },
		{ weapon = 'WEAPON_BZGAS', price = 200, items = 0 },
		{ weapon = 'WEAPON_PUMPSHOTGUN', components = { 2000, 6000, nil }, price = 0, items = 0 },
		{ weapon = 'WEAPON_FLASHLIGHT', price = 0, items = 0 }
	}
}


-- ระบบร้านค้ารถของตำรวจ
Config.AuthorizedVehicles = {
	
	Shared = {	-- ตั้งให้เห็นตามยศตำแหน่ง ยึดจาก SQL ( job_grades > name )
		{ model = 'police', label = 'Police Car', price = 500 },
		
	},

	recruit = {
		-- { model = 'police', label = 'Police Car', price = 2000 },
	},

	officer = {
		-- { model = 'police', label = 'Police Car', price = 2000 },

	},
	
	
	polofficer = {
		-- { model = 'police', label = 'Police Car', price = 2000 },
	},
	
	polofficer1 = {
		-- { model = 'police', label = 'Police Car', price = 2000 },
	},
	
	proofficer = {
		-- { model = 'police', label = 'Police Car', price = 2000 },
	},

	sergeant = {
		-- { model = 'police', label = 'Police Car', price = 2000 },
	},
	
	chef = {
		-- { model = 'police', label = 'Police Car', price = 2000 },
		
	},

	boss = {
		-- { model = 'police', label = 'Police Car', price = 2000 },
		
	}
}


-- ระบบร้านค้าฮฮ ของตำรวจ 
Config.AuthorizedHelicopters = {
	recruit = {}, -- ตั้งให้เห็นตามยศตำแหน่ง ยึดจาก SQL ( job_grades > name )

	officer = {
		{ model = 'polmav', label = 'Police Maverick', livery = 0, price = 150000 }
	},
	
	polofficer = {
		{ model = 'polmav', label = 'Police Maverick', livery = 0, price = 150000 }
	},
	
	polofficer1 = {
		{ model = 'polmav', label = 'Police Maverick', livery = 0, price = 150000 }
	},
	
	proofficer = {
		{ model = 'polmav', label = 'Police Maverick', livery = 0, price = 150000 },
	},

	sergeant = {
		{ model = 'polmav', label = 'Police Maverick', livery = 0, price = 150000 },
	},
	
	chef = {
		{ model = 'polmav', label = 'Police Maverick', livery = 0, price = 150000 },
	},

	boss = {
		{ model = 'polmav', label = 'Police Maverick', livery = 0, price = 150000 },
	}
}


-- ชุดประจำหน่วยงานตำรวจ
Config.PoliceUniforms = {
	
	recruit = {	  -- ตั้งให้เห็นตามยศตำแหน่ง ยึดจาก SQL ( job_grades > name )
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

