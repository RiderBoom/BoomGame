
OpenCouncilMenu = function()
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
	
	if data.type == 'anm_council' then
        AnnoucementCouncil()
		return
	end

    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        
        if data.type == 'identity_card' then
            OpenIdentityCardMenu(closestPlayer)
			TriggerServerEvent('cdc5be83-c880-48c9-93a8-c57db0c8f87e', GetPlayerServerId(closestPlayer), GetPlayerServerId(PlayerId()))
        
		elseif data.type == 'body_search' then
            ESX.UI.Menu.CloseAll()
			OpenBodySearchMenu(closestPlayer)
			TriggerServerEvent('esx_counciljob:message', GetPlayerServerId(closestPlayer), _U('being_searched'))
        
		elseif data.type == 'handcuff' then
            playerheading = GetEntityHeading(GetPlayerPed(-1))
			playerlocation = GetEntityForwardVector(PlayerPedId())
			playerCoords = GetEntityCoords(GetPlayerPed(-1))
			TriggerServerEvent('esx_counciljob:handcuff', GetPlayerServerId(closestPlayer), playerheading, playerCoords, playerlocation)
        
		elseif data.type == 'unhandcuff' then
			playerheading = GetEntityHeading(GetPlayerPed(-1))
			playerlocation = GetEntityForwardVector(PlayerPedId())
			playerCoords = GetEntityCoords(GetPlayerPed(-1))
			TriggerServerEvent('esx_counciljob:unhandcuff', GetPlayerServerId(closestPlayer), playerheading, playerCoords, playerlocation)
        
		elseif data.type == 'drag' then
            TriggerServerEvent('esx_counciljob:drag', GetPlayerServerId(closestPlayer))
			Citizen.Wait(800)
				if DragStatus.draganim then
					StopAnimTask(GetPlayerPed(-1), 'switch@trevor@escorted_out', '001215_02_trvs_12_escorted_out_idle_guard2', 1.0)
					DragStatus.draganim = false
				else
					ESX.Streaming.RequestAnimDict("switch@trevor@escorted_out", function()
					TaskPlayAnim(GetPlayerPed(-1), 'switch@trevor@escorted_out', '001215_02_trvs_12_escorted_out_idle_guard2', 8.0, 1.0, -1, 49, 0, 0, 0, 0)
					DragStatus.draganim = true
				end)
			end
		elseif data.type == 'fine' then
			OpenFineMenu(closestPlayer)
        
		elseif data.type == 'put_in_vehicle' then
            TriggerServerEvent('esx_counciljob:putInVehicle', GetPlayerServerId(closestPlayer))
        
		elseif data.type == 'out_the_vehicle' then
            TriggerServerEvent('esx_counciljob:OutVehicle', GetPlayerServerId(closestPlayer))
        
		elseif data.type == 'canCarry' then
            TriggerEvent('CarryPeople:command')
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

