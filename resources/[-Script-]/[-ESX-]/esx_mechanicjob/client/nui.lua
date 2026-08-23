
OpenMechanicMenu = function()
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

	if data.type == 'hij' then
		local playerPed = PlayerPedId()
		local vehicle = ESX.Game.GetVehicleInDirection()
		local coords = GetEntityCoords(playerPed)

		if IsPedSittingInAnyVehicle(playerPed) then
			ESX.ShowNotification(_U('inside_vehicle'))
			return
		end

		if DoesEntityExist(vehicle) then
			isBusy = true
			TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0,
									 true)
			Citizen.CreateThread(function()
				Citizen.Wait(10000)

				SetVehicleDoorsLocked(vehicle, 1)
				SetVehicleDoorsLockedForAllPlayers(vehicle, false)
				ClearPedTasksImmediately(playerPed)

				ESX.ShowNotification(_U('vehicle_unlocked'))
				isBusy = false

				local plate = GetVehicleNumberPlateText(vehicle)
				local sendToDiscord =
					'' .. GetPlayerName(PlayerId()) ..
						' งัดรถ ทะเบียน ' .. plate ..
						''
				TriggerServerEvent('azael_discordlogs:sendToDiscord',
								   'MechanicHijack', sendToDiscord,
								   GetPlayerServerId(PlayerId()), '^5')
			end)
		else
			ESX.ShowNotification(_U('no_vehicle_nearby'))
		end
		return
	end
	
	if data.type == 'repair' then
		local playerPed = PlayerPedId()
		local vehicle = ESX.Game.GetVehicleInDirection()
		local coords = GetEntityCoords(playerPed)
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)

		if Config.FixInArea then
			if Vdist(GetEntityCoords(playerPed),Config.Zones.MechanicActions.Pos.x,Config.Zones.MechanicActions.Pos.y,Config.Zones.MechanicActions.Pos.z) < 50 then
				if IsPedSittingInAnyVehicle(playerPed) then
					ESX.ShowNotification(_U('inside_vehicle'))
					return
				end
			
				if exports["stk_check"]:CheckItem(Config.UseItem, 1) then

					if DoesEntityExist(vehicle) then
						isBusy = true
						TriggerServerEvent('esx_mechanicjob:triggerBomb',
											ped, coords, veh)
						Citizen.CreateThread(function()
							Citizen.Wait(20000)

							SetVehicleFixed(vehicle)
							SetVehicleDeformationFixed(vehicle)
							SetVehicleUndriveable(vehicle, false)
							SetVehicleEngineOn(vehicle, true, true)
							ClearPedTasksImmediately(playerPed)

							ESX.ShowNotification(_U('vehicle_repaired'))
							isBusy = false

							local plate = GetVehicleNumberPlateText(vehicle)
							local sendToDiscord = '' ..
														GetPlayerName(
															PlayerId()) ..
														' ซ่อมรถ ทะเบียน ' ..
														plate .. ''
							TriggerServerEvent(
								'azael_discordlogs:sendToDiscord',
								'MechanicRepair', sendToDiscord,
								GetPlayerServerId(PlayerId()), '^5')
						end)

					else
						ESX.ShowNotification(_U('no_vehicle_nearby'))
					end

				else
					TriggerEvent("pNotify:SendNotification", {
						text = "คุณไม่มีเครื่องมือซ่อม🥺",
						type = "error",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})

				end
			else
				TriggerEvent("pNotify:SendNotification", {
					text = "ต้องกลับไปซ่อมที่อู่🥺",
					type = "error",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
			end
		else
			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowNotification(_U('inside_vehicle'))
				return
			end
		
			if exports["stk_check"]:CheckItem(Config.UseItem, 1) then

				if DoesEntityExist(vehicle) then
					isBusy = true
					TriggerServerEvent('esx_mechanicjob:triggerBomb',
										ped, coords, veh)
					Citizen.CreateThread(function()
						Citizen.Wait(20000)

						SetVehicleFixed(vehicle)
						SetVehicleDeformationFixed(vehicle)
						SetVehicleUndriveable(vehicle, false)
						SetVehicleEngineOn(vehicle, true, true)
						ClearPedTasksImmediately(playerPed)

						ESX.ShowNotification(_U('vehicle_repaired'))
						isBusy = false

						local plate = GetVehicleNumberPlateText(vehicle)
						local sendToDiscord = '' ..
													GetPlayerName(
														PlayerId()) ..
													' ซ่อมรถ ทะเบียน ' ..
													plate .. ''
						TriggerServerEvent(
							'azael_discordlogs:sendToDiscord',
							'MechanicRepair', sendToDiscord,
							GetPlayerServerId(PlayerId()), '^5')
					end)

				else
					ESX.ShowNotification(_U('no_vehicle_nearby'))
				end

			else
				TriggerEvent("pNotify:SendNotification", {
					text = "คุณไม่มีเครื่องมือซ่อม🥺",
					type = "error",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})

			end
		end
		return
	end
	
	if data.type == 'wash' then
		local playerPed = PlayerPedId()
		local vehicle = ESX.Game.GetVehicleInDirection()
		local coords = GetEntityCoords(playerPed)

		if IsPedSittingInAnyVehicle(playerPed) then
			ESX.ShowNotification(_U('inside_vehicle'))
			return
		end

		if DoesEntityExist(vehicle) then
			isBusy = true
			TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_MAID_CLEAN', 0,
									 true)
			Citizen.CreateThread(function()
				Citizen.Wait(10000)

				SetVehicleDirtLevel(vehicle, 0)
				ClearPedTasksImmediately(playerPed)

				ESX.ShowNotification(_U('vehicle_cleaned'))
				isBusy = false
				local plate = GetVehicleNumberPlateText(vehicle)
				local sendToDiscord =
					'' .. GetPlayerName(PlayerId()) ..
						' ล้างรถ ทะเบียน ' ..
						plate .. ''
				TriggerServerEvent('azael_discordlogs:sendToDiscord',
								   'MechanicClean', sendToDiscord,
								   GetPlayerServerId(PlayerId()), '^5')
			end)
		else
			ESX.ShowNotification(_U('no_vehicle_nearby'))
		end
		return
	end
	
	if data.type == 'remove' then
		local playerPed = PlayerPedId()

		if IsPedSittingInAnyVehicle(playerPed) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)

			if GetPedInVehicleSeat(vehicle, -1) == playerPed then

				local plate = GetVehicleNumberPlateText(vehicle)
				local sendToDiscord =
					'' .. GetPlayerName(PlayerId()) ..
						' เก็บรถทะเบียน ' .. plate ..
						''
				TriggerServerEvent('azael_discordlogs:sendToDiscord',
								   'MechanicImpVeh', sendToDiscord,
								   GetPlayerServerId(PlayerId()), '^3')
				ESX.ShowNotification(_U('vehicle_impounded'))
				ESX.Game.DeleteVehicle(vehicle)
			else
				ESX.ShowNotification(_U('must_seat_driver'))
			end
		else
			local vehicle = ESX.Game.GetVehicleInDirection()

			if DoesEntityExist(vehicle) then

				local plate = GetVehicleNumberPlateText(vehicle)
				local sendToDiscord =
					'' .. GetPlayerName(PlayerId()) ..
						' เก็บรถทะเบียน ' .. plate ..
						''
				TriggerServerEvent('azael_discordlogs:sendToDiscord',
								   'MechanicImpVeh', sendToDiscord,
								   GetPlayerServerId(PlayerId()), '^3')
				ESX.ShowNotification(_U('vehicle_impounded'))
				ESX.Game.DeleteVehicle(vehicle)
			else
				ESX.ShowNotification(_U('must_near'))
			end
		end
		return
	end
	
	if data.type == 'AnnouceMC' then
		AnnoucementMC()
		return
	end
	
	-- if data.type == 'boss_menu' then
		--action
		-- return
	-- end

    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        
        if data.type == 'identity_card' then
            OpenIdentityCardMenu(closestPlayer)
			TriggerServerEvent('cdc5be83-c880-48c9-93a8-c57db0c8f87e', GetPlayerServerId(closestPlayer), GetPlayerServerId(PlayerId()))
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

