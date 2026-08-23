if Config.BedSystem then
	ESX = exports["es_extended"]:getSharedObject()

	Citizen.CreateThread(function()
		while ESX.GetPlayerData().job == nil do
			Citizen.Wait(100)
		end

		ESX.PlayerData = ESX.GetPlayerData()
	end)

	local InAction = false
	local blur = "MenuMGIn"
	local useBilling = true
	local stk = true


	RegisterFontFile('ft')
	fontId = RegisterFontId('FC-Lamoon-Regular-ver-1.00')


	RegisterNetEvent('esx:setJob')
	AddEventHandler('esx:setJob', function(job)
		ESX.PlayerData.job = job
	end)



	local nearBed = nil
	local Onbed = false
	local creatbil = false

	Citizen.CreateThread(function()
		while true do
			local SleepBed = 1000
			
			for i = 1, #Config.BedList do
				local bedID = Config.BedList[i]
				local distance = Vdist(GetEntityCoords(PlayerPedId()),bedID.objCoords.x,bedID.objCoords.y,bedID.objCoords.z, true)

				if distance < 2.0 then SleepBed = 0
					if not (ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance') then
						if not Onbed then
							ESX.Game.Utils.DrawText3D({
								x = bedID.objCoords.x,
								y = bedID.objCoords.y,
								z = bedID.objCoords.z
							}, bedID.text, 0.6)
							
							if IsControlJustPressed(0, 38) then
								nearBed = GetEntityCoords(PlayerPedId())
								if exports["stk_check"]:CheckJob('ambulance', 1) then
									TriggerEvent("pNotify:SendNotification", {
										text = '<center>ต้องขออนุญาตจากคุณหมอก่อน!!<center>',
										type = "error",
										timeout = 3000,
										layout = "CenterLeft"
									})
								else
									if GetEntityHealth(PlayerPedId()) < 200 then
										TriggerServerEvent('esx_ambulancejob:CheckMoneyBed')
									else
										TriggerEvent("pNotify:SendNotification", {
											text = '<center>คุณยังแข็งแรงดี ไม่สามารถนอนเตียงได้<center>',
											type = "error",
											timeout = 3000,
											layout = "CenterLeft"
										})
									end
								end
							end
						end
					else
						if not Onbed then
							ESX.Game.Utils.DrawText3D({
								x = bedID.objCoords2.x,
								y = bedID.objCoords2.y,
								z = bedID.objCoords2.z
							}, bedID.text2, 0.6)

							if IsControlJustPressed(0, 38) then
								local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
								if closestPlayer == -1 or closestDistance > 1.0 then
									TriggerEvent("pNotify:SendNotification", {
										text = '<center>ไม่มีคนไข้อยู่ใกล้??<center>',
										type = "error",
										timeout = 3000,
										layout = "CenterLeft"
									})
								else
									if not creatbil then
										local closestPlayerPed = GetPlayerPed(closestPlayer)
										creatbil = true
										TriggerServerEvent('esx_ambulancejob:setOnBed', GetPlayerServerId(closestPlayer), GetEntityCoords(PlayerPedId()))
										creatbil = false
										
										Citizen.Wait(3000)
										TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer),'',"ค่านอนเตียง", tonumber(Config.Payforbed))
									end
								end
							end
						end
					end			
				end
			end
			
			Citizen.Wait(SleepBed)
		end
	end)

	RegisterNetEvent('esx_ambulancejob:Bed1')
	AddEventHandler('esx_ambulancejob:Bed1', function()
		for _,v in pairs(Config.BedList) do
			for _,k in pairs(Config.bedprop) do
				local bed = GetClosestObjectOfType(v.objCoords.x,v.objCoords.y,v.objCoords.z,1.5,GetHashKey(k),false,false,false)
				local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
				local dist = Vdist(x,y,z, v.objCoords.x, v.objCoords.y, v.objCoords.z)
				if dist < 1.5 then
					if bed ~= 0 then
						local randomAnim = math.random(1,4)
						
						if randomAnim == 1 then
							Onbed = true
							SetEntityCoords(PlayerPedId(),GetEntityCoords(bed) + vector3(0.0,0.0,0.5))
							SetEntityHeading(PlayerPedId(),v.heading)
							FreezeEntityPosition(PlayerPedId(),true)
							RequestAnimDict('missfbi5ig_0')
							while not HasAnimDictLoaded('missfbi5ig_0') do
								Citizen.Wait(0)
							end
							TaskPlayAnim(GetPlayerPed(-1), 'missfbi5ig_0','lyinginpain_loop_steve', 8.0, -8.0, -1, 1, 0, false,false, false)
						elseif randomAnim == 2 then
							Onbed = true
							SetEntityCoords(PlayerPedId(),GetEntityCoords(bed) + vector3(0.0,0.0,0.5))
							SetEntityHeading(PlayerPedId(),v.heading - 90.0)
							FreezeEntityPosition(PlayerPedId(),true)
							RequestAnimDict('amb@world_human_bum_slumped@male@laying_on_right_side@base')
							while not HasAnimDictLoaded('amb@world_human_bum_slumped@male@laying_on_right_side@base') do
								Citizen.Wait(0)
							end
							TaskPlayAnim(GetPlayerPed(-1), 'amb@world_human_bum_slumped@male@laying_on_right_side@base','base', 8.0, -8.0, -1, 1, 0, false,false, false)
						elseif randomAnim == 3 then
							Onbed = true
							SetEntityCoords(PlayerPedId(),GetEntityCoords(bed) + vector3(0.0,0.0,0.5))
							SetEntityHeading(PlayerPedId(),v.heading)
							FreezeEntityPosition(PlayerPedId(),true)
							RequestAnimDict('missheistfbi3b_ig8_2')
							while not HasAnimDictLoaded('missheistfbi3b_ig8_2') do
								Citizen.Wait(0)
							end
							TaskPlayAnim(GetPlayerPed(-1), 'missheistfbi3b_ig8_2','cpr_loop_victim', 8.0, -8.0, -1, 1, 0, false,false, false)
						elseif randomAnim == 4 then
							Onbed = true
							SetEntityCoords(PlayerPedId(),GetEntityCoords(bed) + vector3(0.0,0.0,0.5))
							SetEntityHeading(PlayerPedId(),v.heading)
							FreezeEntityPosition(PlayerPedId(),true)
							RequestAnimDict('anim@gangops@morgue@table@')
							while not HasAnimDictLoaded('anim@gangops@morgue@table@') do
								Citizen.Wait(0)
							end
							TaskPlayAnim(GetPlayerPed(-1), 'anim@gangops@morgue@table@','ko_front', 8.0, -8.0, -1, 1, 0, false,false, false)
							
							
						end

						if Config.EnableUniformsList then
							if not (ESX.PlayerData.job and ESX.PlayerData.job.name == 'police') then	
								TriggerEvent('skinchanger:getSkin', function(skin)
									if skin.sex == 0 then
										TriggerEvent('skinchanger:loadClothes', skin, Config.UniformsList.male)
									else
										TriggerEvent('skinchanger:loadClothes', skin, Config.UniformsList.female)
									end
								end)
							end
						end  

						if exports["stk_check"]:CheckJob('ambulance', 1) then
							TriggerEvent("mythic_progbar:client:progress", {
								name = "unique_action_name",
								duration = Config.TimeOnBed * 1000,
								label = "นอนรักษาอาการบาดเจ็บ",
								useWhileDead = false,
								canCancel = false,
								controlDisables = {
									disableMovement = true,
									disableCarMovement = true,
									disableMouse = false,
									disableCombat = true
								},
							})
							Citizen.Wait(Config.TimeOnBed * 1000)
						else
							TriggerEvent("mythic_progbar:client:progress", {
								name = "unique_action_name",
								duration = Config.TimeOnBedNoAmbulance * 1000,
								label = "นอนรักษาอาการบาดเจ็บ",
								useWhileDead = false,
								canCancel = false,
								controlDisables = {
									disableMovement = true,
									disableCarMovement = true,
									disableMouse = false,
									disableCombat = true
								},
							})
							Citizen.Wait(Config.TimeOnBedNoAmbulance * 1000)
						end
						FreezeEntityPosition(PlayerPedId(),false)
						SetEntityCoords(PlayerPedId(), nearBed)
						SetEntityHealth(PlayerPedId(), 200)
						Onbed = false
						ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin)
						end)
						nearBed = nil
						creatbil = false
					end
				end
			end
		end
	end)

	RegisterNetEvent('esx_ambulancejob:setcoordoffBed')
	AddEventHandler('esx_ambulancejob:setcoordoffBed', function(pos)
		nearBed = pos
	end)


	Citizen.CreateThread(function()
		while true do
			if Onbed then
				local hp = GetEntityHealth(PlayerPedId())
				SetEntityHealth(PlayerPedId(), hp + Config.RegenHP)
			end
			
			Citizen.Wait(1000)
		end
	end)

	Citizen.CreateThread(function()
		
		while true do
			Citizen.Wait(0)
			

			if Onbed then
				DisableAllControlActions(0)
				EnableControlAction(0, 1, true)
				EnableControlAction(0, 2, true)
				EnableControlAction(0, Keys['PAGEUP'], true)
				EnableControlAction(0, Keys['H'], true)
				EnableControlAction(0, Keys['N'], true)
				DisableControlAction(0, Keys['F3'], true)
				EnableControlAction(0, Keys['DELETE'], true)
				EnableControlAction(0, Keys['HOME'], true)
				EnableControlAction(0, Keys['ESC'], true)
			else
				Citizen.Wait(500)
			end

			
		end
	end)


end