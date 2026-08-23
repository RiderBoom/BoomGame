ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)


CARRY = {}
PlayerCarry = {}
local CurrentAction, CurrentActionMsg, CurrentActionData = nil, '', {}
local HasAlreadyEnteredMarker, LastHospital, LastPart, LastPartNum
local IsBusy = false
local spawnedVehicles, isInShopMenu = {}, false



-- Create blips
Citizen.CreateThread(function()
	for k,v in pairs(Config.Hospitals) do
		local blip = AddBlipForCoord(v.Blip.coords)

		SetBlipSprite(blip, v.Blip.sprite)
		SetBlipScale(blip, v.Blip.scale)
		SetBlipColour(blip, v.Blip.color)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString('Hospital')
		EndTextCommandSetBlipName(blip)
	end
end)



function OpenAmbulanceActionsMenu()
	local elements = {
		{label = _U('cloakroom'), value = 'cloakroom'}
	}


	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ambulance_actions', {
		title    = _U('ambulance'),
		align    = 'top-right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'cloakroom' then
			OpenCloakroomMenu()
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenMobileAmbulanceActionsMenu()

	ESX.UI.Menu.CloseAll()
	local elements = {}
	-- table.insert(elements, {label = _U('ems_menu'), value = 'citizen_interaction'})
	-- table.insert(elements, {label = "เคสหมอ", value = 'case_med_system'})
	-- table.insert(elements, {label = "ประกาศแพทย์", value = 'AnnouceMed'})
	-- table.insert(elements, {label = "เด้งศพคนรอบข้าง", value = 'clearbody_area'})
	if ESX.GetPlayerData().job.grade_name == 'bosssub' or ESX.GetPlayerData().job.grade_name == 'boss' then
		table.insert(elements, {label = 'แต่งตั้ง', value = 'setjob'})
		table.insert(elements, {label = 'ปลดยศ', value = 'setjobdefalut'})
	else
		TriggerEvent("pNotify:SendNotification", {
			text = "คุณไม่มีสิทธิ์เข้าถึง",
			type = "error",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
		return
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_ambulance_actions', {
		title    = _U('ambulance'),
		align    = 'top-right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'citizen_interaction' then

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
				title    = _U('ems_menu_title'),
				align    = 'top-right',
				elements = {
					{label = 'อุ้ม', value = 'carry_menu'},
					{label = _U('id_card'), value = 'identity_card'},
					{label = _U('ems_menu_revive'), value = 'revive'},
					{label = 'ประคองคนไข้', value = 'drag'},
					{label = 'ใส่ชุดให้คนไข้', value = 'put_cloth'},
					{label = 'ถอดชุดให้คนไข้', value = 'unput_cloth'},
					-- {label = _U('ems_menu_small'), value = 'small'},
					{label = _U('ems_menu_big'), value = 'big'},
					-- {label = _U('ems_menu_putincar'), value = 'put_in_vehicle'},
					-- {label = 'ชุดประถมพยาบาล', value = 'firstaid'},
					{label = 'บิล', value = 'fine'},
				}
			}, function(data, menu)
				if IsBusy then return end

				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

				if closestPlayer == -1 or closestDistance > 1.0 then
					TriggerEvent("pNotify:SendNotification", {
						text = "ไม่มีใครอยู่แถวนี้",
						type = "error",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				else

					if data.current.value == 'revive' then

						DocReviveMenu()
						
					elseif data.current.value == 'small' then

						if CheckItem('bandage') then
							local closestPlayerPed = GetPlayerPed(closestPlayer)
							local health = GetEntityHealth(closestPlayerPed)

							if health > 0 then
								local playerPed = PlayerPedId()

								IsBusy = true
								ESX.ShowNotification(_U('heal_inprogress'))
								--ท่าทาง
								TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
								--รอ
								Citizen.Wait(10000)
								ClearPedTasks(PlayerPedId())

								TriggerServerEvent('esx_ambulancejob:removeItem', 'bandage')
								TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')
								ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
								local sendToDiscord = ''.. GetPlayerName(PlayerId()) ..' รักษาแผลเล็ก '.. GetPlayerName(closestPlayer) ..''
								TriggerEvent('azael_dc-serverlogs:insertData', 'heal', sendToDiscord, GetPlayerServerId(PlayerId()), '^5')

								IsBusy = false
							else
								ESX.ShowNotification(_U('player_not_conscious'))
							end
						else
							ESX.ShowNotification(_U('not_enough_bandage'))
						end

					elseif data.current.value == 'big' then

						
						if CheckItem('medikit') then
							local closestPlayerPed = GetPlayerPed(closestPlayer)
							local health = GetEntityHealth(closestPlayerPed)

							if health > 0 then
								local playerPed = PlayerPedId()

								IsBusy = true
								ESX.ShowNotification(_U('heal_inprogress'))
								TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
								Citizen.Wait(2000)
								ClearPedTasks(playerPed)

								TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
								TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'big')
								ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
								TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer),'', 'ค่ารักษาฉีดยาเข็มใหญ่', 800)

								local sendToDiscord = ''.. GetPlayerName(PlayerId()) ..' รักษาแผลใหญ่ '.. GetPlayerName(closestPlayer) ..''
								TriggerEvent('azael_dc-serverlogs:insertData', 'heal', sendToDiscord, GetPlayerServerId(PlayerId()), '^5')
								IsBusy = false
							else
								ESX.ShowNotification(_U('player_not_conscious'))
							end
						else
							ESX.ShowNotification(_U('not_enough_medikit'))
						end

					elseif data.current.value == 'put_in_vehicle' then
						TriggerServerEvent('esx_ambulancejob:putInVehicle', GetPlayerServerId(closestPlayer))
					elseif data.current.value == 'fine' then
						OpenFineMenu(closestPlayer)
					elseif data.current.value == 'drag' then
						local target = GetPlayerPed(closestPlayer)
						if not IsEntityDead(target) then
							if GetEntityHealth(target) <= 150 then
								TriggerServerEvent(GetCurrentResourceName()..':drag', GetPlayerServerId(closestPlayer))	
							else
								TriggerEvent("pNotify:SendNotification", {
									text = "เขายังไม่บาดเจ็บ",
									type = "error",
									timeout = 3000,
									layout = "bottomCenter",
									queue = "global"
								})
							end
						end
						menu.close()
					elseif data.current.value == 'put_cloth' then
						local dirt = "anim@mp_player_intincarjazz_handslow@ds@"
						RequestAnimDict(dirt)
						while not HasAnimDictLoaded(dirt) do
							Citizen.Wait(100)
						end

						TaskPlayAnim(PlayerPedId(), dirt, 'exit', 8.0, -8, -1, 49, 0, 0, 0, 0)
						Wait(500)
						ClearPedTasks(GetPlayerPed(-1))
						TriggerServerEvent('meeta_ambulance:put_cloth', GetPlayerServerId(closestPlayer))
						
					elseif data.current.value == 'unput_cloth' then
						local dirt = "anim@mp_player_intincarjazz_handslow@ds@"
						RequestAnimDict(dirt)
						while not HasAnimDictLoaded(dirt) do
							Citizen.Wait(100)
						end

						TaskPlayAnim(PlayerPedId(), dirt, 'exit', 8.0, -8, -1, 49, 0, 0, 0, 0)
						Wait(500)
						ClearPedTasks(GetPlayerPed(-1))
						TriggerServerEvent('meeta_ambulance:unput_cloth', GetPlayerServerId(closestPlayer))
					
					elseif data.current.value == 'firstaid' then
						TriggerEvent('meeta_ambulance:firstaidUse')
					elseif data.current.value == 'identity_card' then
						OpenIdentityCardMenu(closestPlayer)
						TriggerServerEvent('cdc5be83-c880-48c9-93a8-c57db0c8f87e', GetPlayerServerId(closestPlayer), GetPlayerServerId(PlayerId()))
					elseif data.current.value == 'carry_menu' then
						Carry_Menu()
					
					
					end
				end

			end, function(data, menu)
				menu.close()
			end)

		elseif data.current.value == 'setjob' then
			setjob()
		elseif data.current.value == 'setjobdefalut' then
			setjobdefalut()
		end
		
		if data.current.value == 'case_med_system' then
			TriggerEvent('XNS-AmbulanceCase:OpenBoardCase')
			ESX.UI.Menu.CloseAll()
		end
		
		if data.current.value == 'AnnouceMed' then
			AnnoucementMedical()
			menu.close()
		end
		
		if data.current.value == 'clearbody_area' then
			ClearBodyArea()
			menu.close()
		end

	end, function(data, menu)
		menu.close()
	end)
end

function DocReviveMenu()

	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	local elements = {
		{label = 'ค่ารักษาพยาบาลในเมือง', value = 'reviveMenu_1'},
		{label = 'ค่ารักษาพยาบาล นอกเมือง', value = 'reviveMenu_2'},
		{label = 'รักษาพื้นที่เข้าถึงยาก', value = 'reviveMenu_3'},
		{label = 'รักษาพื้นที่เรเบล', value = 'reviveMenu_4'},
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ambulance_menu_revive',
	{
		title    = 'เมนูรักษา',
		align    = 'top-right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'reviveMenu_1' then
			if closestPlayer == -1 or closestDistance > 2 then
				TriggerEvent("pNotify:SendNotification", {
					text = "ไม่มีใครอยู่แถวนี้",
					type = "error",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
				return
			else
				if CheckItem('medikit') then
					local closestPlayerPed = GetPlayerPed(closestPlayer)

					if IsPedDeadOrDying(closestPlayerPed, 1) then
						local playerPed = PlayerPedId()

						ESX.ShowNotification(_U('revive_inprogress'))

						local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'

						for i=1, 11, 1 do
							Citizen.Wait(1000)
					
							ESX.Streaming.RequestAnimDict(lib, function()
								TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
							end)
						end

						TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
						TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer),'', 'ค่ารักษาพยาบาลในเมือง', 1500)

						local sendToDiscord = ''.. GetPlayerName(PlayerId()) ..' ชุบชีวิต '.. GetPlayerName(closestPlayer) ..''
						TriggerEvent('azael_dc-serverlogs:insertData', 'revive', sendToDiscord, GetPlayerServerId(PlayerId()), '^5')

					
						
						if Config.ReviveReward > 0 then
							ESX.ShowNotification(_U('revive_complete_award', GetPlayerName(closestPlayer), Config.ReviveReward))
						else
							ESX.ShowNotification(_U('revive_complete', GetPlayerName(closestPlayer)))
						end
					else
						TriggerEvent("pNotify:SendNotification", {
							text = "ยังไม่บาดเจ็บ",
							type = "error",
							timeout = 3000,
							layout = "bottomCenter",
							queue = "global"
						})
					end
				else
					TriggerEvent("pNotify:SendNotification", {
						text = "คุณไม่มี Medikit",
						type = "error",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				end
				ESX.UI.Menu.CloseAll()
			end
		elseif data.current.value == 'reviveMenu_2' then
			if closestPlayer == -1 or closestDistance > 2 then
				TriggerEvent("pNotify:SendNotification", {
					text = "ไม่มีใครอยู่แถวนี้",
					type = "error",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
				return
			else
				if CheckItem('medikit') then
					local closestPlayerPed = GetPlayerPed(closestPlayer)

					if IsPedDeadOrDying(closestPlayerPed, 1) then
						local playerPed = PlayerPedId()

						ESX.ShowNotification(_U('revive_inprogress'))

						local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'

						for i=1, 11, 1 do
							Citizen.Wait(1000)
					
							ESX.Streaming.RequestAnimDict(lib, function()
								TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
							end)
						end

						TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
						TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer),'', 'ค่ารักษาพยาบาล นอกเมือง', 2000)

						local sendToDiscord = ''.. GetPlayerName(PlayerId()) ..' ชุบชีวิต '.. GetPlayerName(closestPlayer) ..''
						TriggerEvent('azael_dc-serverlogs:insertData', 'revive', sendToDiscord, GetPlayerServerId(PlayerId()), '^5')

						
						if Config.ReviveReward > 0 then
							ESX.ShowNotification(_U('revive_complete_award', GetPlayerName(closestPlayer), Config.ReviveReward))
						else
							ESX.ShowNotification(_U('revive_complete', GetPlayerName(closestPlayer)))
						end
					else
						TriggerEvent("pNotify:SendNotification", {
							text = "ยังไม่บาดเจ็บ",
							type = "error",
							timeout = 3000,
							layout = "bottomCenter",
							queue = "global"
						})
					end
				else
					TriggerEvent("pNotify:SendNotification", {
						text = "คุณไม่มี Medikit",
						type = "error",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				end
				ESX.UI.Menu.CloseAll()
			end
		elseif data.current.value == 'reviveMenu_3' then
			if closestPlayer == -1 or closestDistance > 2 then
				TriggerEvent("pNotify:SendNotification", {
					text = "ไม่มีใครอยู่แถวนี้",
					type = "error",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
				return
			else
				if CheckItem('medikit') then
					local closestPlayerPed = GetPlayerPed(closestPlayer)

					if IsPedDeadOrDying(closestPlayerPed, 1) then
						local playerPed = PlayerPedId()

						ESX.ShowNotification(_U('revive_inprogress'))

						local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'

						for i=1, 11, 1 do
							Citizen.Wait(1000)
					
							ESX.Streaming.RequestAnimDict(lib, function()
								TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
							end)
						end

						TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
						TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer),'', 'ค่ารักษาในพื้นที่เข้าถึงยาก', 2500)

						local sendToDiscord = ''.. GetPlayerName(PlayerId()) ..' ชุบชีวิต '.. GetPlayerName(closestPlayer) ..''
						TriggerEvent('azael_dc-serverlogs:insertData', 'revive', sendToDiscord, GetPlayerServerId(PlayerId()), '^5')

					
						
						if Config.ReviveReward > 0 then
							ESX.ShowNotification(_U('revive_complete_award', GetPlayerName(closestPlayer), Config.ReviveReward))
						else
							ESX.ShowNotification(_U('revive_complete', GetPlayerName(closestPlayer)))
						end
					else
						TriggerEvent("pNotify:SendNotification", {
							text = "ยังไม่บาดเจ็บ",
							type = "error",
							timeout = 3000,
							layout = "bottomCenter",
							queue = "global"
						})
					end
				else
					TriggerEvent("pNotify:SendNotification", {
						text = "คุณไม่มี Medikit",
						type = "error",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				end
				ESX.UI.Menu.CloseAll()
			end
		elseif data.current.value == 'reviveMenu_4' then
			if closestPlayer == -1 or closestDistance > 2 then
				TriggerEvent("pNotify:SendNotification", {
					text = "ไม่มีใครอยู่แถวนี้",
					type = "error",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
				return
			else
				if CheckItem('medikit') then
					local closestPlayerPed = GetPlayerPed(closestPlayer)

					if IsPedDeadOrDying(closestPlayerPed, 1) then
						local playerPed = PlayerPedId()

						ESX.ShowNotification(_U('revive_inprogress'))

						local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'

						for i=1, 11, 1 do
							Citizen.Wait(1000)
					
							ESX.Streaming.RequestAnimDict(lib, function()
								TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
							end)
						end

						TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
						TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer),'', 'ค่ารักษาในพื้นที่เรเบล', 3500)

						local sendToDiscord = ''.. GetPlayerName(PlayerId()) ..' ชุบชีวิต '.. GetPlayerName(closestPlayer) ..''
						TriggerEvent('azael_dc-serverlogs:insertData', 'revive', sendToDiscord, GetPlayerServerId(PlayerId()), '^5')

						
						
						if Config.ReviveReward > 0 then
							ESX.ShowNotification(_U('revive_complete_award', GetPlayerName(closestPlayer), Config.ReviveReward))
						else
							ESX.ShowNotification(_U('revive_complete', GetPlayerName(closestPlayer)))
						end
					else
						TriggerEvent("pNotify:SendNotification", {
							text = "ยังไม่บาดเจ็บ",
							type = "error",
							timeout = 3000,
							layout = "bottomCenter",
							queue = "global"
						})
					end
				else
					TriggerEvent("pNotify:SendNotification", {
						text = "คุณไม่มี Medikit",
						type = "error",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				end
				ESX.UI.Menu.CloseAll()
			end
		end
	end, function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent(GetCurrentResourceName()..':clearbodyAreaCL')
AddEventHandler(GetCurrentResourceName()..':clearbodyAreaCL', function()
	if not exports["CarryMenu_GpG"]:getBodyBag() then
		ClearPedTasksImmediately(PlayerPedId())
	end
end)


function ClearBodyArea()
	ESX.UI.Menu.CloseAll()
	local NearPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 8.0)
	
	for i = 1, #NearPlayer do
		if NearPlayer[i] ~= PlayerId() then
			local closestPlayer = ESX.Game.GetClosestPlayer()
			local closestPlayerPed = GetPlayerPed(closestPlayer)
			
			
			local closestPlayerPedDead = GetPlayerPed(NearPlayer[i])
			
			if IsPedDeadOrDying(closestPlayerPedDead, 1) then
				TriggerServerEvent(GetCurrentResourceName()..':clearbodyAreaSV', GetPlayerServerId(NearPlayer[i]))
			end
		end
	end
end



function AnnoucementMedical()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'Annoucement Medical', {
		title = "ประกาศแพทย์",
	}, function (data2, menu)
		local AnnouceText = data2.value
		
		if AnnouceText == nil then
			TriggerEvent("pNotify:SendNotification", {
                text = "กรุณาใส่รายละเอียดด้วย",
                type = "error",
                timeout = 6000,
                layout = "bottomCenter",
                queue = "global"
            })
		else
			TriggerServerEvent("esx_ambulancejob:sendAnnouceMedical", AnnouceText)
			menu.close()
		end
	
	end, function (data2, menu)
		menu.close()
	end)
end

function OpenIdentityCardMenu(player)

	ESX.TriggerServerCallback('esx_ambulancejob:getOtherPlayerData', function(data)

		local elements    = {}
		local nameLabel   = _U('name', data.name)
		local jobLabel    = nil
		local sexLabel    = nil
		local dobLabel    = nil
		local heightLabel = nil
		local idLabel     = nil
	
		if data.job.grade_label ~= nil and  data.job.grade_label ~= '' then
			jobLabel = _U('job', data.job.label .. ' - ' .. data.job.grade_label)
		else
			jobLabel = _U('job', data.job.label)
		end
	
		if Config.EnableESXIdentity then
	
			nameLabel = _U('name', data.firstname .. ' ' .. data.lastname)
	
			if data.sex ~= nil then
				if string.lower(data.sex) == 'm' then
					sexLabel = _U('sex', _U('male'))
				else
					sexLabel = _U('sex', _U('female'))
				end
			else
				sexLabel = _U('sex', _U('unknown'))
			end
	
			if data.dob ~= nil then
				dobLabel = _U('dob', data.dob)
			else
				dobLabel = _U('dob', _U('unknown'))
			end
	
			if data.height ~= nil then
				heightLabel = _U('height', data.height)
			else
				heightLabel = _U('height', _U('unknown'))
			end
	
			if data.name ~= nil then
				idLabel = _U('id', data.name)
			else
				idLabel = _U('id', _U('unknown'))
			end
	
		end
	
		local elements = {
			{label = nameLabel, value = nil},
			{label = jobLabel,  value = nil},
		}
	
		if Config.EnableESXIdentity then
			table.insert(elements, {label = sexLabel, value = nil})
			table.insert(elements, {label = dobLabel, value = nil})
			table.insert(elements, {label = heightLabel, value = nil})
			table.insert(elements, {label = idLabel, value = nil})
		end
	
		if data.drunk ~= nil then
			table.insert(elements, {label = _U('bac', data.drunk), value = nil})
		end
	
		if data.licenses ~= nil then
	
			table.insert(elements, {label = _U('license_label'), value = nil})
	
			for i=1, #data.licenses, 1 do
				table.insert(elements, {label = data.licenses[i].label, value = nil})
			end
	
		end
	
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction',
		{
			title    = _U('citizen_interaction'),
			align    = 'right',
			elements = elements,
		}, function(data, menu)
	
		end, function(data, menu)
			menu.close()
		end)
	
	end, GetPlayerServerId(player))

end

function Carry_Menu()
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	local elements = {
		{label = 'อุ้ม', value = 'carry'},
		{label = 'ปล่อย', value = 'putdown'}
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'carry_menu3',
	{
		title    = 'Carry',
		align    = 'top-right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'carry' then
		
			local closestPlayerPed = GetPlayerPed(closestPlayer)
		
			if closestPlayer == -1 or closestDistance > 3.0 then
				TriggerEvent("pNotify:SendNotification", {
					text = "ไม่มีใครอยู่แถวนี้",
					type = "error",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
				return
			else	
				if IsPedDeadOrDying(closestPlayerPed, 1) then
					ShowPlayerReadyAttach()
				else
					TriggerEvent("pNotify:SendNotification", {
						text = "ไม่มีคนสลบอยู่แถวนี้",
						type = "error",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				end
			end
		elseif data.current.value == 'putdown' then
			ShowPlayerAttach()
			menu.close()
		end
	end, function(data, menu)
		menu.close()
	end)
end

function ShowPlayerReadyAttach()
	local elements = {}
	local NearPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 3.0)
	for i = 1, #NearPlayer do
		if NearPlayer[i] ~= PlayerId() then
			if not PlayerCarry[GetPlayerServerId(NearPlayer[i])] then
				
				-- local closestPlayer = ESX.Game.GetClosestPlayer()
				-- local closestPlayerPed = GetPlayerPed(closestPlayer)
				
				local closestPlayerPedDead = GetPlayerPed(NearPlayer[i])
				
				if IsPedDeadOrDying(closestPlayerPedDead, 1) then
					table.insert(elements, {label = '[ '..GetPlayerServerId(NearPlayer[i])..' ]', value = GetPlayerServerId(NearPlayer[i])})
				end
			end
		end
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'carry_menu4',
	{
		title    = 'Carry',
		align    = 'top-right',
		elements = elements
	}, function(data, menu)
		tonumber(data.current.value)
		if not PlayerCarry[tonumber(data.current.value)] then
			PlayerCarry[tonumber(data.current.value)] = true
			TriggerServerEvent(GetCurrentResourceName()..':carryPlayerSV', tonumber(data.current.value), true)
		end
		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end


function ShowPlayerAttach()
	local elements = {}
	if CARRY[1] ~= nil then
		for k,v in pairs(CARRY) do
			local text = '[ '..v.id..' ]'
			table.insert(elements, {label = text, value = v.id})
		end
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'carry_menu2',
	{
		title    = 'PutDown',
		align    = 'top-right',
		elements = elements
	}, function(data, menu)
		TriggerServerEvent(GetCurrentResourceName()..':carryPlayerSV', tonumber(data.current.value), false)
		RemoveTableCarry(tonumber(data.current.value))
		PlayerCarry[tonumber(data.current.value)] = false
		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

function RemoveTableCarry(id)
	for k,v in pairs(CARRY) do
		if v.id == id then
			table.remove(CARRY, k)
		end
	end
end

RegisterNetEvent(GetCurrentResourceName()..':Attach_Carry')
AddEventHandler(GetCurrentResourceName()..':Attach_Carry', function(type, id)	
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	
	if type then
		if GetPlayerServerId(closestPlayer) == id then
			if not IsEntityAttached(PlayerPedId()) then
				AttachEntityToEntity(PlayerPedId(), GetPlayerPed(closestPlayer), 9816, 0.015, 0.38, 0.11, 0.9, 0.30, 90.0, false, false, false, false, 2, false)
				RequestAnimDict("amb@code_human_in_car_idles@generic@ps@base")	
				while not HasAnimDictLoaded('amb@code_human_in_car_idles@generic@ps@base') do Citizen.Wait(0) end
				TaskPlayAnim(PlayerPedId(), 'amb@code_human_in_car_idles@generic@ps@base', 'base', 5.0, -1, -1, 9, 0, false, false, false)
			end
		end
	else
		DetachEntity(PlayerPedId(), true, false)
		ClearPedTasksImmediately(target)
		ClearPedTasksImmediately(PlayerPedId())
	end	
end)

RegisterNetEvent(GetCurrentResourceName()..':Animcarry')
AddEventHandler(GetCurrentResourceName()..':Animcarry', function(type, name, id)
	--local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if type then
		--AttachEntityToEntity(GetPlayerPed(closestPlayer), GetPlayerPed(-1), 9816, 0.015, 0.38, 0.11, 0.9, 0.30, 90.0, false, false, false, false, 2, false)
		RequestAnimDict('anim@heists@box_carry@')
		while not HasAnimDictLoaded('anim@heists@box_carry@') do Citizen.Wait(0) end
		TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 5.0, -1, -1, 49, 1, false, false, false)
		table.insert(CARRY, {name = name, id = id})
	else
		ClearPedTasksImmediately(PlayerPedId())
		RemoveTableCarry(id)
	end
end)

function setjob()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	local elements = {}
	if ESX.GetPlayerData().job.grade_name == 'boss'  then
		table.insert(elements, {label = "แพทย์ฝึกหัด",   value = '0'})
		table.insert(elements, {label = "แพทย์",   value = '1'})
		table.insert(elements, {label = "แพทย์ชำนาญการพิเศษ  ",   value = '2'})
		table.insert(elements, {label = "แพทย์อาวุโส ",   value = '3'})
		table.insert(elements, {label = "รองผู้อำนวยการแพทย์",   value = '4'})
		table.insert(elements, {label = "ผู้อำนวยการแพทย์",   value = '5'})
	end
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'setjob',
	{
		title    = 'Setjob',
		align    = 'top-right',
		elements = elements
	}, function(data, menu)
		TriggerServerEvent('Bosssetjob:ambulance', GetPlayerServerId(closestPlayer), data.current.value)
        menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

function setjobdefalut()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if ESX.PlayerData.job.grade == 4 or ESX.PlayerData.job.grade == 5 then
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'setjobdefalut',
		{
			title    = 'Setjob',
			align    = 'top-right',
			elements = {
				
				{label = "ประชาชน",   value = '0'},
			}
		}, function(data, menu)
			TriggerServerEvent('Bosssetjob:unemployed', GetPlayerServerId(closestPlayer), data.current.value)
			menu.close()
		end, function(data, menu)
			menu.close()
		end)
	end
end

function OpenFineMenu(player)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine',
	{
		title    = 'บิล',
		align    = 'top-right',
		elements = {
			{label = "สร้างบิลค่ารักษา", value = 'Other'},
			{label = "บิลค่ารักษา 500", value = 'bill1'},
			{label = "บิลค่ารักษา 700", value = 'bill2'},
			{label = "บิลค่ารักษา 900", value = 'bill3'},
			{label = "บิลค่ารักษา 1,200", value = 'bill4'},
			{label = "บิลค่ารักษา 1,700", value = 'bill5'},
			{label = "บิลค่ารักษา 2,000", value = 'bill6'},
		}
	}, function(data, menu)
		
		if data.current.value == 'Other' then
			CreateBilling(player)
		elseif data.current.value == 'bill1' then
			TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player),'', 'ค่ารักษาพยาบาล', 500)
			menu.close()
			TriggerEvent("pNotify:SendNotification", {
				text = "สร้างบิลเรียบร้อยแล้ว",
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
			Wait(2000)
		elseif data.current.value == 'bill2' then
			TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player),'', 'ค่ารักษาพยาบาล', 700)
			menu.close()
			TriggerEvent("pNotify:SendNotification", {
				text = "สร้างบิลเรียบร้อยแล้ว",
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
			Wait(2000)
		elseif data.current.value == 'bill3' then
			TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player),'', 'ค่ารักษาพยาบาล', 900)
			menu.close()
			TriggerEvent("pNotify:SendNotification", {
				text = "สร้างบิลเรียบร้อยแล้ว",
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
			Wait(2000)
		elseif data.current.value == 'bill4' then
			TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player),'', 'ค่ารักษาพยาบาล', 1200)
			menu.close()
			TriggerEvent("pNotify:SendNotification", {
				text = "สร้างบิลเรียบร้อยแล้ว",
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
			Wait(2000)
		elseif data.current.value == 'bill5' then
			TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player),'', 'ค่ารักษาพยาบาล', 1700)
			menu.close()
			TriggerEvent("pNotify:SendNotification", {
				text = "สร้างบิลเรียบร้อยแล้ว",
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
			Wait(2000)
		elseif data.current.value == 'bill6' then
			TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player),'', 'ค่ารักษาพยาบาล', 2000)
			menu.close()
			TriggerEvent("pNotify:SendNotification", {
				text = "สร้างบิลเรียบร้อยแล้ว",
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
			Wait(2000)
		end

	end, function(data, menu)
		menu.close()
	end)
end

function CreateBilling(player)
	ESX.UI.Menu.CloseAll()
	Name_Bill = 'ค่ารักษาพยาบาล'
	CreateBillingPrice(GetPlayerServerId(player), Name_Bill)
end

function CreateBillingPrice(id, value)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'dialog_createbill_price',
	{
		title = "ใส่จำนวนเงิน",
	}, function(data2, menu2)
		if tonumber(data2.value) then
			
			TriggerServerEvent('esx_billing:sendBill', id,'', ''..value..'', tonumber(data2.value))
			TriggerServerEvent('Miller:entrybill', tonumber(data2.value) * 0.3)
			menu2.close()
			TriggerEvent("pNotify:SendNotification", {
				text = "สร้างบิลเรียบร้อยแล้ว",
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		else
			TriggerEvent("pNotify:SendNotification", {
				text = "กรุณาใส่จำนวนเงิน",
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		end
	end, function(data2, menu2)
		menu2.close()
	end)
end

function FastTravel(coords, heading)
	local playerPed = PlayerPedId()

	DoScreenFadeOut(800)

	while not IsScreenFadedOut() do
		Citizen.Wait(500)
	end

	ESX.Game.Teleport(playerPed, coords, function()
		DoScreenFadeIn(800)

		if heading then
			SetEntityHeading(playerPed, heading)
		end
	end)
end

-- Draw markers & Marker logic
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local letSleep, isInMarker, hasExited = true, false, false
		local currentHospital, currentPart, currentPartNum

		for hospitalNum,hospital in pairs(Config.Hospitals) do

			-- Ambulance Actions
			for k,v in ipairs(hospital.AmbulanceActions) do
				local distance = GetDistanceBetweenCoords(playerCoords, v, true)

				if distance < Config.DrawDistance and ESX.PlayerData.job.name == "ambulance" then
					DrawMarker(Config.Marker.type, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
					letSleep = false
				end

				if distance < Config.Marker.x and ESX.PlayerData.job.name == "ambulance" then
					isInMarker, currentHospital, currentPart, currentPartNum = true, hospitalNum, 'AmbulanceActions', k
				end
			end
			
			-- Pharmacies
			for k,v in ipairs(hospital.Pharmacies) do
				local distance = GetDistanceBetweenCoords(playerCoords, v, true)

				if distance < Config.DrawDistance and ESX.PlayerData.job.name == "ambulance" then
					DrawMarker(Config.Marker.type, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
					letSleep = false
				end

				if distance < Config.Marker.x and ESX.PlayerData.job.name == "ambulance" then
					isInMarker, currentHospital, currentPart, currentPartNum = true, hospitalNum, 'Pharmacies', k
				end
			end

			-- Vehicle Spawners
			for k,v in ipairs(hospital.Vehicles) do
				local distance = GetDistanceBetweenCoords(playerCoords, v.Spawner, true)

				if distance < Config.DrawDistance and ESX.PlayerData.job.name == "ambulance"  then
					DrawMarker(v.Marker.type, v.Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Marker.x, v.Marker.y, v.Marker.z, v.Marker.r, v.Marker.g, v.Marker.b, v.Marker.a, false, false, 2, v.Marker.rotate, nil, nil, false)
					letSleep = false
				end

				if distance < v.Marker.x and ESX.PlayerData.job.name == "ambulance" then
					isInMarker, currentHospital, currentPart, currentPartNum = true, hospitalNum, 'Vehicles', k
				end
			end

			-- Helicopter Spawners
			for k,v in ipairs(hospital.Helicopters) do
				local distance = GetDistanceBetweenCoords(playerCoords, v.Spawner, true)

				if distance < Config.DrawDistance and ESX.PlayerData.job.name == "ambulance" then
					DrawMarker(v.Marker.type, v.Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Marker.x, v.Marker.y, v.Marker.z, v.Marker.r, v.Marker.g, v.Marker.b, v.Marker.a, false, false, 2, v.Marker.rotate, nil, nil, false)
					letSleep = false
				end

				if distance < v.Marker.x and ESX.PlayerData.job.name == "ambulance" then
					isInMarker, currentHospital, currentPart, currentPartNum = true, hospitalNum, 'Helicopters', k
				end
			end


			--Fast Travels (Prompt)
			for k,v in ipairs(hospital.FastTravelsPrompt) do
				local distance = GetDistanceBetweenCoords(playerCoords, v.From, true)

				if distance < Config.DrawDistance and ESX.PlayerData.job.name == "ambulance"  then
					DrawMarker(v.Marker.type, v.From, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Marker.x, v.Marker.y, v.Marker.z, v.Marker.r, v.Marker.g, v.Marker.b, v.Marker.a, false, false, 2, v.Marker.rotate, nil, nil, false)
					letSleep = false
				end

				if distance < v.Marker.x and ESX.PlayerData.job.name == "ambulance" then
					isInMarker, currentHospital, currentPart, currentPartNum = true, hospitalNum, 'FastTravelsPrompt', k
				end
			end

		end

		-- Logic for exiting & entering markers
		if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastHospital ~= currentHospital or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then

			if
				(LastHospital ~= nil and LastPart ~= nil and LastPartNum ~= nil) and
				(LastHospital ~= currentHospital or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
			then
				TriggerEvent('esx_ambulancejob:hasExitedMarker', LastHospital, LastPart, LastPartNum)
				hasExited = true
			end

			HasAlreadyEnteredMarker, LastHospital, LastPart, LastPartNum = true, currentHospital, currentPart, currentPartNum

			TriggerEvent('esx_ambulancejob:hasEnteredMarker', currentHospital, currentPart, currentPartNum)

		end

		if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_ambulancejob:hasExitedMarker', LastHospital, LastPart, LastPartNum)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)

AddEventHandler('esx_ambulancejob:hasEnteredMarker', function(hospital, part, partNum)
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
		if part == 'AmbulanceActions' then
			CurrentAction = part
			CurrentActionMsg = _U('actions_prompt')
			CurrentActionData = {}
		elseif part == 'Pharmacies' then
			CurrentAction = part
			CurrentActionMsg = _U('open_pharmacy')
			CurrentActionData = {}
		elseif part == 'Vehicles' then
			CurrentAction = part
			CurrentActionMsg = _U('garage_prompt')
			CurrentActionData = {hospital = hospital, partNum = partNum}
		elseif part == 'Helicopters' then
			CurrentAction = part
			CurrentActionMsg = _U('helicopter_prompt')
			CurrentActionData = {hospital = hospital, partNum = partNum}
		elseif part == 'FastTravelsPrompt' then
			local travelItem = Config.Hospitals[hospital][part][partNum]

			CurrentAction = part
			CurrentActionMsg = travelItem.Prompt
			CurrentActionData = {to = travelItem.To.coords, heading = travelItem.To.heading}
		end
	end
end)

AddEventHandler('esx_ambulancejob:hasExitedMarker', function(hospital, part, partNum)
	if not isInShopMenu then
		ESX.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction then
			exports["esx_text_ui"]:Help(CurrentActionMsg)

			if IsControlJustReleased(0, Keys['E']) then

				if CurrentAction == 'AmbulanceActions' then
					OpenAmbulanceActionsMenu()
				elseif CurrentAction == 'Pharmacies' then
					OpenPharmacyMenu()
				elseif CurrentAction == 'Vehicles' then
					OpenVehicleSpawnerMenu(CurrentActionData.hospital, CurrentActionData.partNum)
				elseif CurrentAction == 'Helicopters' then
					OpenHelicopterSpawnerMenu(CurrentActionData.hospital, CurrentActionData.partNum)
				elseif CurrentAction == 'FastTravelsPrompt' then
					FastTravel(CurrentActionData.to, CurrentActionData.heading)
				end

				CurrentAction = nil

			end

		elseif ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'ambulance' and not IsDead then
			if IsControlJustReleased(0, Keys['F6']) then
				-- OpenMobileAmbulanceActionsMenu()
				OpenAmbulanceMenu()
			end
		elseif Config.AutoReviveAmbulance then
			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'ambulance' and IsDead and exports["stk_check"]:CheckJob('ambulance', 1) then
				TriggerEvent('esx_ambulancejob:revive')
			end
		else
			Citizen.Wait(500)
		end
	end
end)

RegisterNetEvent('esx_ambulancejob:putInVehicle')
AddEventHandler('esx_ambulancejob:putInVehicle', function()
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords, 5.0) then
		local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

		if DoesEntityExist(vehicle) then
			local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

			for i=maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(vehicle, i) then
					freeSeat = i
					break
				end
			end

			if freeSeat then
				TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
			end
		end
	end
end)

function OpenCloakroomMenu()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title    = _U('cloakroom'),
		align    = 'top-right',
		elements = {
			{label = _U('ems_clothes_civil'), value = 'citizen_wear'},
			{label = _U('ems_clothes_ems'), value = 'ambulance_wear'},
		}
	}, function(data, menu)
		if data.current.value == 'citizen_wear' then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		elseif data.current.value == 'ambulance_wear' then
			ChangeUnifrom()
		end

		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end



function ChangeUnifrom()
	if Config.AmbulanceUniforms[ESX.GetPlayerData().job.grade_name] then
		TriggerEvent('skinchanger:getSkin', function(skin)
			if skin.sex == 0 then
				TriggerEvent('skinchanger:loadClothes', skin, Config.AmbulanceUniforms[ESX.GetPlayerData().job.grade_name].male)
			else
				TriggerEvent('skinchanger:loadClothes', skin, Config.AmbulanceUniforms[ESX.GetPlayerData().job.grade_name].female)
			end
		end)
	end
end



function OpenVehicleSpawnerMenu(hospital, partNum)
	local playerCoords = GetEntityCoords(PlayerPedId())
	local elements = {
		{label = _U('garage_storeditem'), action = 'garage'},
		{label = _U('garage_storeitem'), action = 'store_garage'},
		{label = _U('garage_buyitem'), action = 'buy_vehicle'}
	}

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle', {
		title    = _U('garage_title'),
		align    = 'top-right',
		elements = elements
	}, function(data, menu)

		if data.current.action == 'buy_vehicle' then
			local shopCoords = Config.Hospitals[hospital].Vehicles[partNum].InsideShop
			local shopElements = {}

			local authorizedVehicles = Config.AuthorizedVehicles[ESX.PlayerData.job.grade_name]

			if #authorizedVehicles > 0 then
				for k,vehicle in ipairs(authorizedVehicles) do
					table.insert(shopElements, {
						label = ('%s - %s'):format(vehicle.label, _U('shop_item', ESX.Math.GroupDigits(vehicle.price))),
						name  = vehicle.label,
						model = vehicle.model,
						price = vehicle.price,
						type  = 'car'
					})
				end
			else
				return
			end

			OpenShopMenu(shopElements, playerCoords, shopCoords)
		elseif data.current.action == 'garage' then
			local garage = {}

			ESX.TriggerServerCallback('esx_vehicleshop:retrieveJobVehicles', function(jobVehicles)
				if #jobVehicles > 0 then
					for k,v in ipairs(jobVehicles) do
						local props = json.decode(v.vehicle)
						local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
						local label = ('%s - <span style="color:darkgoldenrod;">%s</span>: '):format(vehicleName, props.plate)

						if v.stored then
							label = label .. ('<span style="color:green;">%s</span>'):format(_U('garage_stored'))
						else
							label = label .. ('<span style="color:darkred;">%s</span>'):format(_U('garage_notstored'))
						end

						table.insert(garage, {
							label = label,
							stored = v.stored,
							model = props.model,
							vehicleProps = props
						})
					end

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_garage', {
						title    = _U('garage_title'),
						align    = 'top-right',
						elements = garage
					}, function(data2, menu2)
						if data2.current.stored then
							local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(hospital, 'Vehicles', partNum)

							if foundSpawn then
								menu2.close()

								ESX.Game.SpawnVehicle(data2.current.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
									ESX.Game.SetVehicleProperties(vehicle, data2.current.vehicleProps)

									TriggerServerEvent('esx_vehicleshop:setJobVehicleState', data2.current.vehicleProps.plate, false)
									ESX.ShowNotification(_U('garage_released'))
								end)
							end
						else
							ESX.ShowNotification(_U('garage_notavailable'))
						end
					end, function(data2, menu2)
						menu2.close()
					end)

				else
					ESX.ShowNotification(_U('garage_empty'))
				end
			end, 'car')

		elseif data.current.action == 'store_garage' then
			StoreNearbyVehicle(playerCoords)
		end

	end, function(data, menu)
		menu.close()
	end)

end

function StoreNearbyVehicle(playerCoords)
	local vehicles, vehiclePlates = ESX.Game.GetVehiclesInArea(playerCoords, 30.0), {}

	if #vehicles > 0 then
		for k,v in ipairs(vehicles) do

			-- Make sure the vehicle we're saving is empty, or else it wont be deleted
			if GetVehicleNumberOfPassengers(v) == 0 and IsVehicleSeatFree(v, -1) then
				table.insert(vehiclePlates, {
					vehicle = v,
					plate = ESX.Math.Trim(GetVehicleNumberPlateText(v))
				})
			end
		end
	else
		ESX.ShowNotification(_U('garage_store_nearby'))
		return
	end

	ESX.TriggerServerCallback('esx_ambulancejob:storeNearbyVehicle', function(storeSuccess, foundNum)
		if storeSuccess then
			local vehicleId = vehiclePlates[foundNum]
			local attempts = 0
			ESX.Game.DeleteVehicle(vehicleId.vehicle)
			IsBusy = true

			Citizen.CreateThread(function()
				while IsBusy do
					Citizen.Wait(0)
					drawLoadingText(_U('garage_storing'), 255, 255, 255, 255)
				end
			end)

			-- Workaround for vehicle not deleting when other players are near it.
			while DoesEntityExist(vehicleId.vehicle) do
				Citizen.Wait(500)
				attempts = attempts + 1

				-- Give up
				if attempts > 30 then
					break
				end

				vehicles = ESX.Game.GetVehiclesInArea(playerCoords, 30.0)
				if #vehicles > 0 then
					for k,v in ipairs(vehicles) do
						if ESX.Math.Trim(GetVehicleNumberPlateText(v)) == vehicleId.plate then
							ESX.Game.DeleteVehicle(v)
							break
						end
					end
				end
			end

			IsBusy = false
			ESX.ShowNotification(_U('garage_has_stored'))
		else
			ESX.ShowNotification(_U('garage_has_notstored'))
		end
	end, vehiclePlates)
end

function GetAvailableVehicleSpawnPoint(hospital, part, partNum)
	local spawnPoints = Config.Hospitals[hospital][part][partNum].SpawnPoints
	local found, foundSpawnPoint = false, nil

	for i=1, #spawnPoints, 1 do
		if ESX.Game.IsSpawnPointClear(spawnPoints[i].coords, spawnPoints[i].radius) then
			found, foundSpawnPoint = true, spawnPoints[i]
			break
		end
	end

	if found then
		return true, foundSpawnPoint
	else
		ESX.ShowNotification(_U('garage_blocked'))
		return false
	end
end

function OpenHelicopterSpawnerMenu(hospital, partNum)
	local playerCoords = GetEntityCoords(PlayerPedId())
	ESX.PlayerData = ESX.GetPlayerData()
	local elements = {
		{label = _U('helicopter_garage'), action = 'garage'},
		{label = _U('helicopter_store'), action = 'store_garage'},
		{label = _U('helicopter_buy'), action = 'buy_helicopter'}
	}

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'helicopter_spawner', {
		title    = _U('helicopter_title'),
		align    = 'top-right',
		elements = elements
	}, function(data, menu)

		if data.current.action == 'buy_helicopter' then
			local shopCoords = Config.Hospitals[hospital].Helicopters[partNum].InsideShop
			local shopElements = {}

			local authorizedHelicopters = Config.AuthorizedHelicopters[ESX.PlayerData.job.grade_name]

			if #authorizedHelicopters > 0 then
				for k,helicopter in ipairs(authorizedHelicopters) do
					table.insert(shopElements, {
						label = ('%s - <span style="color:green;">%s</span>'):format(helicopter.label, _U('shop_item', ESX.Math.GroupDigits(helicopter.price))),
						name  = helicopter.label,
						model = helicopter.model,
						price = helicopter.price,
						type  = 'helicopter'
					})
				end
			else
				ESX.ShowNotification(_U('helicopter_notauthorized'))
				return
			end

			OpenShopMenu(shopElements, playerCoords, shopCoords)
		elseif data.current.action == 'garage' then
			local garage = {}

			ESX.TriggerServerCallback('esx_vehicleshop:retrieveJobVehicles', function(jobVehicles)
				if #jobVehicles > 0 then
					for k,v in ipairs(jobVehicles) do
						local props = json.decode(v.vehicle)
						local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
						local label = ('%s - <span style="color:darkgoldenrod;">%s</span>: '):format(vehicleName, props.plate)

						if v.stored then
							label = label .. ('<span style="color:green;">%s</span>'):format(_U('garage_stored'))
						else
							label = label .. ('<span style="color:darkred;">%s</span>'):format(_U('garage_notstored'))
						end

						table.insert(garage, {
							label = label,
							stored = v.stored,
							model = props.model,
							vehicleProps = props
						})
					end

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'helicopter_garage', {
						title    = _U('helicopter_garage_title'),
						align    = 'top-right',
						elements = garage
					}, function(data2, menu2)
						if data2.current.stored then
							local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(hospital, 'Helicopters', partNum)

							if foundSpawn then
								menu2.close()

								ESX.Game.SpawnVehicle(data2.current.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
									ESX.Game.SetVehicleProperties(vehicle, data2.current.vehicleProps)

									TriggerServerEvent('esx_vehicleshop:setJobVehicleState', data2.current.vehicleProps.plate, false)
									ESX.ShowNotification(_U('garage_released'))
								end)
							end
						else
							ESX.ShowNotification(_U('garage_notavailable'))
						end
					end, function(data2, menu2)
						menu2.close()
					end)

				else
					ESX.ShowNotification(_U('garage_empty'))
				end
			end, 'helicopter')

		elseif data.current.action == 'store_garage' then
			StoreNearbyVehicle(playerCoords)
		end

	end, function(data, menu)
		menu.close()
	end)

end

function OpenShopMenu(elements, restoreCoords, shopCoords)
	local playerPed = PlayerPedId()
	isInShopMenu = true

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
		title    = _U('vehicleshop_title'),
		align    = 'top-right',
		elements = elements
	}, function(data, menu)

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop_confirm', {
			title    = _U('vehicleshop_confirm', data.current.name, data.current.price),
			align    = 'top-right',
			elements = {
				{ label = _U('confirm_no'), value = 'no' },
				{ label = _U('confirm_yes'), value = 'yes' }
			}
		}, function(data2, menu2)

			if data2.current.value == 'yes' then
				local newPlate = exports['esx_vehicleshop']:GeneratePlate()
				local vehicle  = GetVehiclePedIsIn(playerPed, false)
				local props    = ESX.Game.GetVehicleProperties(vehicle)
				props.plate    = newPlate

				ESX.TriggerServerCallback('esx_ambulancejob:buyJobVehicle', function (bought)
					if bought then
						ESX.ShowNotification(_U('vehicleshop_bought', data.current.name, ESX.Math.GroupDigits(data.current.price)))

						isInShopMenu = false
						ESX.UI.Menu.CloseAll()
				
						DeleteSpawnedVehicles()
						FreezeEntityPosition(playerPed, false)
						SetEntityVisible(playerPed, true)
				
						ESX.Game.Teleport(playerPed, restoreCoords)
					else
						ESX.ShowNotification(_U('vehicleshop_money'))
						menu2.close()
					end
				end, props, data.current.type)
			else
				menu2.close()
			end

		end, function(data2, menu2)
			menu2.close()
		end)

		end, function(data, menu)
		isInShopMenu = false
		ESX.UI.Menu.CloseAll()

		DeleteSpawnedVehicles()
		FreezeEntityPosition(playerPed, false)
		SetEntityVisible(playerPed, true)

		ESX.Game.Teleport(playerPed, restoreCoords)
	end, function(data, menu)
		DeleteSpawnedVehicles()

		WaitForVehicleToLoad(data.current.model)
		ESX.Game.SpawnLocalVehicle(data.current.model, shopCoords, 0.0, function(vehicle)
			table.insert(spawnedVehicles, vehicle)
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			FreezeEntityPosition(vehicle, true)
		end)
	end)

	WaitForVehicleToLoad(elements[1].model)
	ESX.Game.SpawnLocalVehicle(elements[1].model, shopCoords, 0.0, function(vehicle)
		table.insert(spawnedVehicles, vehicle)
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		FreezeEntityPosition(vehicle, true)
	end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if isInShopMenu then
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		else
			Citizen.Wait(500)
		end
	end
end)

function DeleteSpawnedVehicles()
	while #spawnedVehicles > 0 do
		local vehicle = spawnedVehicles[1]
		ESX.Game.DeleteVehicle(vehicle)
		table.remove(spawnedVehicles, 1)
	end
end

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)

			DisableControlAction(0, Keys['TOP'], true)
			DisableControlAction(0, Keys['DOWN'], true)
			DisableControlAction(0, Keys['LEFT'], true)
			DisableControlAction(0, Keys['RIGHT'], true)
			DisableControlAction(0, 176, true) -- ENTER key
			DisableControlAction(0, Keys['BACKSPACE'], true)

			drawLoadingText(_U('vehicleshop_awaiting_model'), 255, 255, 255, 255)
		end
	end
end

function drawLoadingText(text, red, green, blue, alpha)
	SetTextFont(4)
	SetTextProportional(0)
	SetTextScale(0.0, 0.5)
	SetTextColour(red, green, blue, alpha)
	SetTextDropShadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)

	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.5, 0.5)
end

function OpenPharmacyMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pharmacy', {
		title    = _U('pharmacy_menu_title'),
		align    = 'top-right',
		elements = {
			{label = _U('pharmacy_take', _U('medikit')), value = 'medikit'},
			{label = _U('pharmacy_take', _U('bandage')), value = 'bandage'}
		}
	}, function(data, menu)
		TriggerServerEvent('esx_ambulancejob:giveItem', data.current.value)
	end, function(data, menu)
		menu.close()
	end)
end

function WarpPedInClosestVehicle(ped)
	local coords = GetEntityCoords(ped)

	local vehicle, distance = ESX.Game.GetClosestVehicle(coords)

	if distance ~= -1 and distance <= 5.0 then
		local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

		for i=maxSeats - 1, 0, -1 do
			if IsVehicleSeatFree(vehicle, i) then
				freeSeat = i
				break
			end
		end

		if freeSeat then
			TaskWarpPedIntoVehicle(ped, vehicle, freeSeat)
		end
	else
		ESX.ShowNotification(_U('no_vehicles'))
	end
end

RegisterNetEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(healType, quiet)
	local playerPed = PlayerPedId()
	local maxHealth = GetEntityMaxHealth(playerPed)

	if healType == 'small' then
		
		local health = GetEntityHealth(playerPed)
		if health ~= 200 then
			SetEntityHealth(playerPed, health + 40)
		end
	elseif healType == 'big' then
		SetEntityHealth(playerPed, maxHealth)
	end

	if not quiet then
		ESX.ShowNotification(_U('healed'))
	end
end)

RegisterNetEvent(GetCurrentResourceName()..':animation')
AddEventHandler(GetCurrentResourceName()..':animation', function()
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if not animation then
		animation = true
		RequestAnimDict('anim@heists@ornate_bank@grab_cash')
		while not HasAnimDictLoaded('anim@heists@ornate_bank@grab_cash') do Citizen.Wait(0) end
		TaskPlayAnim(PlayerPedId(), 'anim@heists@ornate_bank@grab_cash', 'grab_idle', 5.0, -1, -1, 49, 1, false, false, false)
		RemoveAnimDict('anim@heists@ornate_bank@grab_cash')
	else
		animation = false
		ClearPedTasksImmediately(PlayerPedId())
	end

	
end)

RegisterNetEvent(GetCurrentResourceName()..':dragPlayer')
AddEventHandler(GetCurrentResourceName()..':dragPlayer', function(target)	
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	local target = GetPlayerPed(closestPlayer)
	if not Drag then		
		AttachEntityToEntity(PlayerPedId(), target, 11816, 0.54, -0.10, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
		RequestAnimDict("move_action@generic@core")	
		while not HasAnimDictLoaded('move_action@generic@core') do Citizen.Wait(0) end
		TaskPlayAnim(PlayerPedId(), 'move_action@generic@core', 'walk', 5.0, -1, -1, 9, 0, false, false, false)
		Drag = true
	else
		DetachEntity(PlayerPedId(), true, false)
		ClearPedTasksImmediately(target)
		ClearPedTasksImmediately(PlayerPedId())
		
		Drag = false
	end	
end)



RegisterNetEvent('meeta_ambulance:put_cloth')
AddEventHandler('meeta_ambulance:put_cloth', function()
	
	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			TriggerEvent('skinchanger:loadClothes', skin, Config.UniformsList.male)
		else
			TriggerEvent('skinchanger:loadClothes', skin, Config.UniformsList.female)
		end
	end)

end)


RegisterNetEvent('meeta_ambulance:unput_cloth')
AddEventHandler('meeta_ambulance:unput_cloth', function()

	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
		TriggerEvent('skinchanger:loadSkin', skin)
	end)

end)




Citizen.CreateThread(function()
    while true do
        local sleepP = 1000
        local p = PlayerPedId()
        local pc = GetEntityCoords(p)
        local bcoord = vector3(Config.BossMenu.Pos.x,Config.BossMenu.Pos.y,Config.BossMenu.Pos.z)
        local d = Vdist(pc, bcoord)
        
        if d < 30 and ESX.GetPlayerData().job.name == 'ambulance' then sleepP = 7
            DrawMarker(22, bcoord.x, bcoord.y, bcoord.z,nil,nil,nil,nil,nil,nil,1.0,1.0,1.0,102,0,102,100,false,false,2,true,false,false,false)
        end
        
        if d < 1.5 and ESX.GetPlayerData().job.name == 'ambulance' then sleepP = 1
            exports["esx_text_ui"]:Help('~INPUT_PICKUP~ ~b~BossMenu')
            if IsControlJustPressed(0,38) then
                if ESX.GetPlayerData().job.name == 'ambulance' and ESX.GetPlayerData().job.grade_name == 'boss' then
                    BOSSMENU()
                else
                    TriggerEvent("pNotify:SendNotification", {
                        text = "คุณไม่มีสิทธ์",
                        type = "error",
                        timeout = 3000,
                        layout = "bottomCenter",
                        queue = "global"
                    })
                end
            end
        end
		Citizen.Wait(sleepP)
    end
end)

function BOSSMENU()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Boss_menu', {
		title    = 'Boss-Menu',
		align    = 'top-right',
		elements = {
            {label = 'จัดการบุคลากร', value = 'management'},
            {label = 'รับสมัครบุคลากร', value = 'setjob'},
        },
           
	},function(data, menu)
        if data.current.value == 'management' then
            TriggerServerEvent('esx_ambulance:GetDepartMent')
        elseif data.current.value == 'setjob' then
            InputIDPlayer()
        end
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function InputIDPlayer()
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'dialog_IdPlayer', {
        title = 'ใส่ไอดีผู้เล่น',
    },function(data, menu)
        if tonumber(data.value) then
            TriggerServerEvent('esx_ambulance:setJobforid', data.value, ESX.GetPlayerData().job.name)
        end
        menu.close()
    end,function(data, menu)
		menu.close()
		end
	)
end


RegisterNetEvent('esx_ambulance:SetDepartment')
AddEventHandler('esx_ambulance:SetDepartment', function(data)
    ESX.UI.Menu.CloseAll()
    local elements = {}
    local text
    for k,v in pairs(data) do
        if v.online then
            text = ''..v.name..' Grade : '..v.grade..' <span style="color:green;">[online]</span>'
        else
            text = ''..v.name..' Grade : '..v.grade..' <span style="color:red;">[offline]</span>'
        end
        table.insert(elements, {label = text, id = v.id, online = v.online, name = v.name})
    end
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Boss_menu_Grade', {
		title    = 'Boss-Menu-Player',
		align    = 'top-right',
		elements = elements
           
	},function(data, menu)
        ManageJob(data.current)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end)

function ManageJob(dataPlayer)
    ESX.UI.Menu.CloseAll()
    local elements = {}
    ESX.TriggerServerCallback('esx_ambulance:getjob', function(result)
        for k,v in pairs(result) do
            table.insert(elements, {label = v.label, name = v.job_name, grade = v.grade})
        end
        table.insert(elements, {label = 'ปลดออก', name = 'unemployed', grade = 0})
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Boss_menu_Grade2', {
            title    = dataPlayer.name,
            align    = 'top-right',
            elements = elements
               
        },function(data, menu)
            if dataPlayer.online then
                TriggerServerEvent('esx_ambulance:SetJobPlayer_online', dataPlayer.id, data.current.name, data.current.grade)
            else
                TriggerServerEvent('esx_ambulance:SetJobPlayer_offline', dataPlayer.id, data.current.name, data.current.grade)
            end
            menu.close()
        end, function(data, menu)
            menu.close()
        end)
    end, ESX.GetPlayerData().job.name) 
end



function CheckItem(itemname)
	local inven = ESX.GetPlayerData().inventory
	for k,v in pairs(inven) do
		if v.name == itemname then
			if v.count > 0 then
				return true
			end
		end
	end
	return false
end