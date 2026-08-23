Config                            = {}
Config.Marker                     = { type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false }
Config.DrawDistance               = 10.0
Config.Locale                     = 'en'

local second = 1000
local minute = 60 * second
Config.LoadIpl                    = true
Config.EnableESXIdentity 		  = true
Config.EnablePlayerManagement     = true
Config.AntiCombatLog              = true
Config.RemoveWeaponsAfterRPDeath  = true
Config.RemoveCashAfterRPDeath     = true
Config.RemoveItemsAfterRPDeath    = true



Config.AutoRespawn				  = true			-- เกิดออโต้ เมื่อไม่มีหมอในเมือง
Config.AutoReviveAmbulance		  = false			-- เมื่อหมอมี 1 คนแล้วหมอสลบจะให้ฟื้นอัตโนมัติหรือไม่
Config.AutoMovePlayerOutWater	  = true			-- เมื่อผู้เล่นสลบในน้ำ ให้ย้ายไปที่บนบกที่อยู่ใกล้ๆหรือไม่
Config.ItemReducetime  			  = "vip_card" 		-- ไอเทม ลดเวลาการตาย
Config.ProtectItems  			  = "safety_card" 	-- ไอเทม กันของหายเมื่อตายจนเวลาหมด
Config.AutoRespawnTimer           = 3 * minute 		-- Time เมื่อสลบไม่มีหมอ
Config.AutoRespawnTimer_VIP       = 1.5 * minute 	-- Time เมื่อสลบไม่มีหมอ ( ถ้ามีไอเทมลดเวลา )
Config.EarlyRespawnTimer          = 50 * minute  	-- Time เวลาสลบรอบแรก ( มีหมอ )
Config.EarlyRespawnTimer_VIP      = 60 * minute  	-- Time เวลาสลบรอบแรก ( ถ้ามีไอเทมลดเวลา )
Config.BleedoutTimer              = 5 * minute 		-- Time เวลาสลบรอบสุดท้ายก่อนจะตาย
Config.SetHelathRevive 			  = 30 				-- เซ็ตเลือด หลังจากชุบชีวิตแล้ว
Config.RemoveMoneyNoDoctor 		  = 500 			-- เซ็ตเงิน ตอนฟื้น หากไม่มีหมอในเซิฟเวอร์
Config.ReviveReward               = 0  				-- เมื่อหมอชุบ จะได้เงินกี่ $



Config.BandageTime = 3 		-- วินาที ในการใช้ Bandage
Config.BandageHealth = 35 	-- ใช้ Bandage เลือดเพิ่มเท่าไหร่
Config.MedikitTime = 5 		-- วินาที ในการใช้ Medikit
Config.MedikitHealth = 50 	-- ใช้ Medikit เลือดเพิ่มเท่าไหร่
Config.WaitTimeAED = 3 		-- วินาที ในการใช้ AED



-- เซ็ตจุดเกิด เมื่อผู้เล่นสลบจนหมดเวลา หรือตาย
Config.RespawnPoint = {coords = vector3(307.6768, -587.751, 43.300), heading = 68.25}



-- ตั้งพิกัดเมนูจัดการคนหน่วยงาน ของ boss
Config.BossMenu = { 
	Pos = {x = 294.8714, y = -610.871, z = 43.353}
}


-- Item ไหนจะไม่ให้หายตอนสลบจนหมดเวลา หรือตาย
Config.ItemsNotRemoveWhenDeath = { 
	"vault",
	"new_playercard",
	
}


-- การลดขั้นอาวุธ เมื่อสลบจนหมดเวลา หรือตาย
Config.WeaponDropLevel = {
	{
		lv0 = 'WEAPON_BAT',
		lv1 = 'WEAPON_BATLV1',
		lv2 = 'WEAPON_BATLV2',
		lv3 = 'WEAPON_BATLV3',
		lv4 = 'WEAPON_BATLV4',
		lv5 = 'WEAPON_BATLV5',
	},
	{
		lv0 = 'WEAPON_POOLCUE',
		lv1 = 'WEAPON_POOLCUELV1',
		lv2 = 'WEAPON_POOLCUELV2',
		lv3 = 'WEAPON_POOLCUELV3',
		lv4 = 'WEAPON_POOLCUELV4',
		lv5 = 'WEAPON_POOLCUELV5',
	},
	{
		lv0 = 'WEAPON_GOLFCLUB',
		lv1 = 'WEAPON_GOLFLV1',
		lv2 = 'WEAPON_GOLFLV2',
		lv3 = 'WEAPON_GOLFLV3',
		lv4 = 'WEAPON_GOLFLV4',
		lv5 = 'WEAPON_GOLFLV5',
	},
	{
		lv0 = 'WEAPON_BOOTLE',
		lv1 = 'WEAPON_BOTTLELV1',
		lv2 = 'WEAPON_BOTTLELV2',
		lv3 = 'WEAPON_BOTTLELV3',
		lv4 = 'WEAPON_BOTTLELV4',
		lv5 = 'WEAPON_BOTTLELV5',
	},
	{
		lv0 = 'WEAPON_MACHETE',
		lv1 = 'WEAPON_MACHETELV1',
		lv2 = 'WEAPON_MACHETELV2',
		lv3 = 'WEAPON_MACHETELV3',
		lv4 = 'WEAPON_MACHETELV4',
		lv5 = 'WEAPON_MACHETELV5',
	},
	{
		lv0 = 'WEAPON_BATTLEAXE',
		lv1 = 'WEAPON_BATTLEAXELV1',
		lv2 = 'WEAPON_BATTLEAXELV2',
		lv3 = 'WEAPON_BATTLEAXELV3',
		lv4 = 'WEAPON_BATTLEAXELV4',
		lv5 = 'WEAPON_BATTLEAXELV5',
	},
	{
		lv0 = 'WEAPON_DAGGER',
		lv1 = 'WEAPON_DAGGERLV1',
		lv2 = 'WEAPON_DAGGERLV2',
		lv3 = 'WEAPON_DAGGERLV3',
		lv4 = 'WEAPON_DAGGERLV4',
		lv5 = 'WEAPON_DAGGERLV5',
	},
	{
		lv0 = 'WEAPON_REVOLVER',
		lv1 = 'WEAPON_REVOLVERLV1',
		lv2 = 'WEAPON_REVOLVERLV2',
		lv3 = 'WEAPON_REVOLVERLV3',
		lv4 = 'WEAPON_REVOLVERLV4',
		lv5 = 'WEAPON_REVOLVERLV5',
	},
	
}


-- พิกัดในโรงพยาบาล
Config.Hospitals = {

	Pillbox = {

		Blip = {
			coords = vector3(308.2912, -587.177, 43.300),
			sprite = 61,
			scale  = 1.0,
			color  = 2
		},

		AmbulanceActions = {
			vector3(290.8329, -603.360, 43.317)
		},

		Pharmacies = {
			vector3(295.9650, -606.663, 43.327)
		},

		Vehicles = {
			{
				Spawner = vector3(294.0316, -601.201, 43.304),
				InsideShop = vector3(287.2980, -599.646, 43.184),
				Marker = { type = 36, x = 1.0, y = 1.0, z = 1.0, r = 100, g = 50, b = 200, a = 100, rotate = true },
				SpawnPoints = {
					{ coords = vector3(296.8026, -603.375, 43.304), heading = 72.99, radius = 2.0 },
					{ coords = vector3(293.6349, -610.413, 43.362), heading = 72.99, radius = 2.0 },
				}
			},
		},

		Helicopters = {
			{
				Spawner = vector3(343.9218, -580.192, 74.164),
				InsideShop = vector3(351.9090, -588.398, 74.164),
				Marker = { type = 34, x = 1.5, y = 1.5, z = 1.5, r = 100, g = 150, b = 150, a = 100, rotate = true },
				SpawnPoints = {
					{ coords = vector3(351.9090, -588.398, 74.164), heading = 6.54, radius = 10.0 },
				}
			},
		},

		FastTravelsPrompt = {
			{
				From = vector3(283.7938, -611.228, 43.312),
				To = { coords = vector3(276.7286, -611.195, 43.136), heading = 314.24 },
				Marker = { type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false }
			},
	
		},

	},
	

}


-- รถหน่วยงานหมอ
Config.AuthorizedVehicles = {

	ambulance = { -- ตั้งให้เห็นตามยศตำแหน่ง ยึดจาก SQL ( job_grades > name )
		{ model = 'ambulance', label = 'Ambulance Car', price = 500},

	},


	doctor = {
		{ model = 'ambulance', label = 'Ambulance Car', price = 500},

	},

	doctorpro = {
		{ model = 'ambulance', label = 'Ambulance Car', price = 500},
		
	},

	old_doctor = {
		{ model = 'ambulance', label = 'Ambulance Car', price = 500},
		
	},

	bosssub = {
		{ model = 'ambulance', label = 'Ambulance Car', price = 500},
		
	},

	boss = {
		{ model = 'ambulance', label = 'Ambulance Car', price = 500},
		
	},	
	
}


-- ฮอหน่วยงานหมอ
Config.AuthorizedHelicopters = {

	ambulance = {},

	doctor = {
		{ model = 'polmav', label = 'Ambulance Mavel', price = 50000 },
		{ model = 'seasparrow', label = 'Sea Sparrow', price = 5000 }

	},

	doctorpro = {
		{ model = 'polmav', label = 'Ambulance Mavel', price = 50000 },
		{ model = 'seasparrow', label = 'Sea Sparrow', price = 5000 }

	},

	old_doctor = {
		{ model = 'polmav', label = 'Ambulance Mavel', price = 50000 },
		{ model = 'seasparrow', label = 'Sea Sparrow', price = 5000 }

	},

	bosssub = {
		{ model = 'polmav', label = 'Ambulance Mavel', price = 50000 },
		{ model = 'seasparrow', label = 'Sea Sparrow', price = 5000 }

	},

	boss = {
		{ model = 'polmav', label = 'Ambulance Mavel', price = 50000 },
		{ model = 'seasparrow', label = 'Sea Sparrow', price = 5000 }

	},	
	

}


-- ชุดเครื่องแบบหน่วยงานหมอ
Config.AmbulanceUniforms = {
	
	ambulance = { -- ตั้งให้เห็นตามยศตำแหน่ง ยึดจาก SQL ( job_grades > name )
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




Config.BedSystem = false  -- เปิด / ปิด ระบบเตียงรักษา
Config.bedprop = { -- prop ที่จะให้นอนได้
	'v_med_emptybed',
	'v_med_bed2',
	'v_med_bed1'
}

Config.EnableUniformsList = true -- เปิด / ปิด การเปลี่ยนชุดนอน เมื่อนอนเตียง
Config.UniformsList = { --- ตั้งค่าชุดนอน
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

}

Config.Payforbed = 500			--ค่านอนเตียง
Config.PayforbedNoEms = 500		--ค่านอนเตียง (ไม่มีหมอ)
Config.TimeOnBed = 100 			-- เวลา นอนเตียง (มีหมอ)
Config.TimeOnBedNoAmbulance = 150 -- เวลา นอนเตียง (ไม่มีหมอ)
Config.RegenHP = 2				-- เพิ่มทีละเท่าไหร่
Config.BedList = {

	------------ Hospital City ------------
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 135.98,
		objCoords  = {x = 359.87, y = -1379.11, z = 32.43},
		objCoords2  = {x = 359.87, y = -1379.11, z = 32.43},

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 135.98,
		objCoords  = {x = 362.24, y = -1381.08, z = 32.43},--pillbox bed
		objCoords2  = {x = 362.24, y = -1381.08, z = 32.43},--pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 135.98,
		objCoords  = {x = 364.74, y = -1383.03, z = 32.43},---pillbox bed
		objCoords2  = {x = 364.74, y = -1383.03, z = 32.43},---pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 135.98,
		objCoords  = {x = 366.95, y = -1385.07, z = 32.43},---pillbox bed
		objCoords2  = {x = 366.95, y = -1385.07, z = 32.43},---pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 135.98,
		objCoords  = {x = 369.65, y = -1387.3, z = 32.43},---pillbox bed
		objCoords2  = {x = 369.65, y = -1387.3, z = 32.43},---pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 323.39,
		objCoords  = {x = 362.2, y = -1390.31, z = 32.43}, --pillbox bed
		objCoords2  = {x = 362.2, y = -1390.31, z = 32.43}, --pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 323.39,
		objCoords  = {x = 360.04, y = -1388.36, z = 32.43}, --pillbox bed
		objCoords2  = {x = 360.04, y = -1388.36, z = 32.43}, --pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 323.39,
		objCoords  = {x = 357.59, y = -1386.27, z = 32.43}, --pillbox bed
		objCoords2  = {x = 357.59, y = -1386.27, z = 32.43}, --pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 323.39,
		objCoords  = {x = 355.39, y = -1384.4, z = 32.43}, --pillbox bed
		objCoords2  = {x = 355.39, y = -1384.4, z = 32.43}, --pillbox bed

	},
	
	-------- Room 2 --------
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 135.98, 
		objCoords  = {x = 348.86, y = -1366.69, z = 32.43},---pillbox bed
		objCoords2  = {x = 348.86, y = -1366.69, z = 32.43},---pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 135.98, 
		objCoords  = {x = 351.12, y = -1368.52, z = 32.43},--pillbox bed
		objCoords2  = {x = 351.12, y = -1368.52, z = 32.43},--pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 135.98, 
		objCoords  = {x = 353.45, y = -1370.64, z = 32.43},---pillbox bed
		objCoords2  = {x = 353.45, y = -1370.64, z = 32.43},---pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 135.98, 
		objCoords  = {x = 355.85, y = -1372.63, z = 32.43},---pillbox bed
		objCoords2  = {x = 355.85, y = -1372.63, z = 32.43},---pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 135.98, 
		objCoords  = {x = 358.54, y = -1374.86, z = 32.43},---pillbox bed
		objCoords2  = {x = 358.54, y = -1374.86, z = 32.43},---pillbox bed

	},

	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 323.39,
		objCoords  = {x = 349.54, y = -1375.91, z = 32.43}, --pillbox bed
		objCoords2  = {x = 349.54, y = -1375.91, z = 32.43}, --pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 323.39,
		objCoords  = {x = 346.93, y = -1373.84, z = 32.43}, --pillbox bed
		objCoords2  = {x = 346.93, y = -1373.84, z = 32.43}, --pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 323.39,
		objCoords  = {x = 344.59, y = -1371.78, z = 32.43}, --pillbox bed
		objCoords2  = {x = 344.59, y = -1371.78, z = 32.43}, --pillbox bed

	},
	
	-------- Room 3 --------
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 51.21,
		objCoords  = {x = 350.53430175781, y = -1436.0362548828, z = 32.435592651367}, --pillbox bed
		objCoords2  = {x = 350.53430175781, y = -1436.0362548828, z = 32.435592651367}, --pillbox bed

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 51.21,
		objCoords  = {x = 348.60092163086, y = -1438.3247070313, z = 32.435600280762},
		objCoords2  = {x = 348.60092163086, y = -1438.3247070313, z = 32.435600280762},

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 51.21,
		objCoords  = {x = 346.71762084961, y = -1440.6575927734, z = 32.435607910156},
		objCoords2  = {x = 346.71762084961, y = -1440.6575927734, z = 32.435607910156},

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 51.21,
		objCoords  = {x = 344.80712890625, y = -1442.8978271484, z = 32.435607910156},
		objCoords2  = {x = 344.80712890625, y = -1442.8978271484, z = 32.435607910156},

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 51.21,
		objCoords  = {x = 342.78601074219, y = -1445.2858886719, z = 32.43558883667},
		objCoords2  = {x = 342.78601074219, y = -1445.2858886719, z = 32.43558883667},

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 51.21,
		objCoords  = {x = 341.07119750977, y = -1447.1182861328, z = 32.435607910156},
		objCoords2  = {x = 341.07119750977, y = -1447.1182861328, z = 32.435607910156},

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 228.10,
		objCoords  = {x = 334.78894042969, y = -1441.8651123047, z = 32.43537902832},
		objCoords2  = {x = 334.78894042969, y = -1441.8651123047, z = 32.43537902832},

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 228.10,
		objCoords  = {x = 336.40612792969, y = -1440.0078125, z = 32.435386657715},
		objCoords2  = {x = 336.40612792969, y = -1440.0078125, z = 32.435386657715},

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 228.10,
		objCoords  = {x = 338.24868774414, y = -1437.6552734375, z = 32.435386657715},
		objCoords2  = {x = 338.24868774414, y = -1437.6552734375, z = 32.435386657715},

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 228.10,
		objCoords  = {x = 340.08767700195, y = -1435.486328125, z = 32.435329437256},
		objCoords2  = {x = 340.08767700195, y = -1435.486328125, z = 32.435329437256},

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 228.10,
		objCoords  = {x = 341.95108032227, y = -1433.2275390625, z = 32.435390472412},
		objCoords2  = {x = 341.95108032227, y = -1433.2275390625, z = 32.435390472412},

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 228.10,
		objCoords  = {x = 343.85845947266, y = -1430.8817138672, z = 32.435390472412},
		objCoords2  = {x = 343.85845947266, y = -1430.8817138672, z = 32.435390472412},

	},
	
	----------- Room 4 -----------
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 51.21,
		objCoords  = {x = 334.85360717773, y = -1423.7387695313, z = 32.43558883667},
		objCoords2  = {x = 334.85360717773, y = -1423.7387695313, z = 32.43558883667},

	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 51.21,
		objCoords  = {x = 332.89202880859, y = -1425.9454345703, z = 32.435607910156},
		objCoords2  = {x = 332.89202880859, y = -1425.9454345703, z = 32.435607910156},
	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 51.21,
		objCoords  = {x = 331.00045776367, y = -1428.2307128906, z = 32.435607910156},
		objCoords2  = {x = 331.00045776367, y = -1428.2307128906, z = 32.435607910156},
	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 51.21,
		objCoords  = {x = 329.06817626953, y = -1430.4855957031, z = 32.435607910156},
		objCoords2  = {x = 329.06817626953, y = -1430.4855957031, z = 32.435607910156},
	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 51.21,
		objCoords  = {x = 327.26461791992, y = -1432.8903808594, z = 32.435607910156},
		objCoords2  = {x = 327.26461791992, y = -1432.8903808594, z = 32.435607910156},
	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 51.21,
		objCoords  = {x = 325.47494506836, y = -1434.8165283203, z = 32.435592651367},
		objCoords2  = {x = 325.47494506836, y = -1434.8165283203, z = 32.435592651367},
	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 228.10,
		objCoords  = {x = 318.92080688477, y = -1429.1345214844, z = 32.435371398926},
		objCoords2  = {x = 318.92080688477, y = -1429.1345214844, z = 32.435371398926},
	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 228.10,
		objCoords  = {x = 320.38046264648, y = -1427.2596435547, z = 32.435386657715},
		objCoords2  = {x = 320.38046264648, y = -1427.2596435547, z = 32.435386657715},
	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 228.10,
		objCoords  = {x = 322.30078125, y = -1424.8702392578, z = 32.435386657715},
		objCoords2  = {x = 322.30078125, y = -1424.8702392578, z = 32.435386657715},
	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 228.10,
		objCoords  = {x = 324.16455078125, y = -1422.6940917969, z = 32.435386657715},
		objCoords2  = {x = 324.16455078125, y = -1422.6940917969, z = 32.435386657715},
	},
	
	{
		text = 'กด [~b~ E ~w~] เพื่อนอนบนเตียง',
		text2 = 'กด [~g~ E ~w~] นำคนไข้ขึ้นเตียง',
		text3 = 'กด [~r~ E ~w~] นำคนไข้ลงจากเตียง',
		heading = 228.10,
		objCoords  = {x = 326.06817626953, y = -1420.4368896484, z = 32.435386657715},
		objCoords2  = {x = 326.06817626953, y = -1420.4368896484, z = 32.435386657715},
	},



	

}