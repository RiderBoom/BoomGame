
OpenAmbulanceMenu = function()
	ESX.UI.Menu.CloseAll()
	SetNuiFocus(true, true)
    SendNUIMessage({
        message = 'openUI'
    })
    if false then
        SetTimecycleModifierStrength(0)
        SetTimecycleModifier('hud_def_blur')
        Citizen.CreateThread(function()
            for i = 1, 10 do
                Citizen.Wait(0)
                SetTimecycleModifierStrength(i / 10)
            end
        end)
    end
end

RegisterNUICallback('quit', function(data)
	SetNuiFocus(false, false)
	SendNUIMessage({
        message = "closeUI"
    })

    local c = 1
    for i = 1, 50 do
        Citizen.Wait(0)
        c = c - 0.02
        DisableControlAction(0, 167, true)
        SetTimecycleModifierStrength(c)
    end
    DisableControlAction(0, 167, false)
    SetTimecycleModifier('default')
end)

RegisterNUICallback('action', function(data)
    if isBusy then 
        return 
    end
	
	if data.type == 'AnnouceMed' then
		AnnoucementMedical()
		return
	end
	
	if data.type == 'case_med_system' then
		TriggerEvent('XNS-AmbulanceCase:OpenBoardCase')
		ESX.UI.Menu.CloseAll()
		return
	end
	
	if data.type == 'boss_menu' then
		OpenMobileAmbulanceActionsMenu()
		return
	end
	
	if data.type == 'clearbody_area' then
		ClearBodyArea()
		return
	end

    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        
        if data.type == 'identity_card' then
            OpenIdentityCardMenu(closestPlayer)
			TriggerServerEvent('cdc5be83-c880-48c9-93a8-c57db0c8f87e', GetPlayerServerId(closestPlayer), GetPlayerServerId(PlayerId()))
        
		elseif data.type == 'canCarry' then
			Carry_Menu()
			
		elseif data.type == 'revive' then
			DocReviveMenu()
			
		elseif data.type == 'drag' then
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
			
		elseif data.type == 'put_cloth' then
			local dirt = "anim@mp_player_intincarjazz_handslow@ds@"
			RequestAnimDict(dirt)
			while not HasAnimDictLoaded(dirt) do
				Citizen.Wait(100)
			end

			TaskPlayAnim(PlayerPedId(), dirt, 'exit', 8.0, -8, -1, 49, 0, 0, 0, 0)
			Wait(500)
			ClearPedTasks(GetPlayerPed(-1))
			TriggerServerEvent('meeta_ambulance:put_cloth', GetPlayerServerId(closestPlayer))
			
		
		elseif data.type == 'unput_cloth' then
			local dirt = "anim@mp_player_intincarjazz_handslow@ds@"
			RequestAnimDict(dirt)
			while not HasAnimDictLoaded(dirt) do
				Citizen.Wait(100)
			end

			TaskPlayAnim(PlayerPedId(), dirt, 'exit', 8.0, -8, -1, 49, 0, 0, 0, 0)
			Wait(500)
			ClearPedTasks(GetPlayerPed(-1))
			TriggerServerEvent('meeta_ambulance:unput_cloth', GetPlayerServerId(closestPlayer))
		
		
		elseif data.type == 'big' then
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
			
		elseif data.type == 'fine' then
			OpenFineMenu(closestPlayer)
			
        end
        
	else
		TriggerEvent("pNotify:SendNotification", {
			text = "ไม่มีผู้เล่นอยู่ใกล้คุณ",
			type = "error",
			timeout = 3000,
			layout = "centerLeft",
			queue = "global"
		})
	end
end)

