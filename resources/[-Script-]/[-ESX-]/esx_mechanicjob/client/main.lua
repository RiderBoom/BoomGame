ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job) 
	ESX.PlayerData.job = job 
end)


local HasAlreadyEnteredMarker, LastZone = false, nil
local CurrentAction, CurrentActionMsg, CurrentActionData = nil, '', {}
local CurrentlyTowedVehicle, Blips, NPCOnJob, NPCTargetTowable,
      NPCTargetTowableZone = nil, {}, false, nil, nil
local NPCHasSpawnedTowable, NPCLastCancel, NPCHasBeenNextToTowable,
      NPCTargetDeleterZone = false, GetGameTimer() - 5 * 60000, false, false
local isDead, isBusy = false, false
local spawnedVehicles, isInShopMenu = {}, false



function VehicleInFront()
    local pos = GetEntityCoords(GetPlayerPed(-1))
    local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0,
                                                         4.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x,
                                          entityWorld.y, entityWorld.z, 10,
                                          GetPlayerPed(-1), 0)
    local a, b, c, d, result = GetRaycastResult(rayHandle)
    return result
end

RegisterNetEvent('esx_mechanicjob:placeBomb')
AddEventHandler('esx_mechanicjob:placeBomb', function(ped, coords, veh)
    local dict
    local model = 'prop_carjack'
    local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, -2.0, 0.0)
    local headin = GetEntityHeading(ped)
    local vehFront = VehicleInFront()
    FreezeEntityPosition(veh, true)
    local vehpos = GetEntityCoords(veh)
    dict = 'mp_car_bomb'
    RequestAnimDict(dict)
    RequestModel(model)
    while not HasAnimDictLoaded(dict) or not HasModelLoaded(model) do
        Citizen.Wait(1)
    end

    local vehjack = CreateObject(GetHashKey(model), vehpos.x, vehpos.y,
                                 vehpos.z - 0.5, true, true, true)
    ESX.ShowNotification('Lifting vehicle with jack')
    SetVehicleDoorOpen(vehFront, 4, false, false)
    AttachEntityToEntity(vehjack, veh, 0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, false,
                         false, false, false, 0, true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1250, 1, 0.0, 1, 1)
    Citizen.Wait(1250)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.01, true,
                            true, true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.025, true,
                            true, true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.05, true,
                            true, true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.1, true, true,
                            true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.15, true,
                            true, true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.2, true, true,
                            true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.3, true, true,
                            true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    dict = 'move_crawl'
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.4, true, true,
                            true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.5, true, true,
                            true)
    SetEntityCollision(veh, false, false)
    TaskPedSlideToCoord(ped, offset, headin, 1000)
    Citizen.Wait(1000)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Citizen.Wait(100) end
    ESX.ShowNotification('Vehicle repair')
    TaskPlayAnimAdvanced(ped, dict, 'onback_bwd', coords, 0.0, 0.0,
                         headin - 180, 1.0, 0.5, 3000, 1, 0.0, 1, 1)
    dict = 'amb@world_human_vehicle_mechanic@male@base'
    Citizen.Wait(3000)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Citizen.Wait(1) end
    TaskPlayAnim(ped, dict, 'base', 8.0, -8.0, 5000, 1, 0, false, false, false)
    dict = 'move_crawl'
    Citizen.Wait(5000)
    local coords2 = GetEntityCoords(ped)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Citizen.Wait(1) end
    TaskPlayAnimAdvanced(ped, dict, 'onback_fwd', coords2, 0.0, 0.0,
                         headin - 180, 1.0, 0.5, 2000, 1, 0.0, 1, 1)
    Citizen.Wait(3000)
    dict = 'mp_car_bomb'
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Citizen.Wait(1) end
    ESX.ShowNotification('Lowering vehicle')
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1250, 1, 0.0, 1, 1)
    Citizen.Wait(1250)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.4, true, true,
                            true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.3, true, true,
                            true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.2, true, true,
                            true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.15, true,
                            true, true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.1, true, true,
                            true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.05, true,
                            true, true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.025, true,
                            true, true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    dict = 'move_crawl'
    Citizen.Wait(1000)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + 0.01, true,
                            true, true)
    TaskPlayAnimAdvanced(ped, dict, 'car_bomb_mechanic', coords, 0.0, 0.0,
                         headin, 1.0, 0.5, 1000, 1, 0.25, 1, 1)
    SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z, true, true, true)
    FreezeEntityPosition(veh, false)
    DeleteObject(vehjack)
    SetEntityCollision(veh, true, true)
    TriggerServerEvent('esx_carBomb:storeCars', veh)
end)


function OpenMobileMechanicActionsMenu()
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                     'mobile_mechanic_actions', {
        title = _U('mechanic'),
        align = 'top-left',
        elements = {
            {label = _U('id_card'),	value = 'identity_card'},
            {label = _U('billing'), value = 'fine'},
            {label = _U('hijack'), value = 'hijack_vehicle'},
            {label = _U('repair'), value = 'fix_vehicle'},
            {label = _U('clean'), value = 'clean_vehicle'},
            {label = _U('imp_veh'), value = 'del_vehicle'},


            -- {label = "แต่งตั้ง", value = 'setjob'},
            -- {label = "ปลดยศ", value = 'setjobdefault'}
        }
    }, function(data, menu)
        if isBusy then return end
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        if data.current.value == 'identity_card' then
            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                OpenIdentityCardMenu(closestPlayer)
                TriggerServerEvent('cdc5be83-c880-48c9-93a8-c57db0c8f87e', GetPlayerServerId(closestPlayer), GetPlayerServerId(PlayerId())) 
            else
                TriggerEvent("pNotify:SendNotification", {
                    text = "ไม่มีผู้เล่นอยู่ใกล้คุณ",
                    type = "success",
                    timeout = 3000,
                    layout = "bottomCenter",
                    queue = "global"
                })
            end
            
        elseif data.current.value == 'fine' then
            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                OpenFineMenu(closestPlayer)
            else
                TriggerEvent("pNotify:SendNotification", {
                    text = "ไม่มีผู้เล่นอยู่ใกล้คุณ",
                    type = "success",
                    timeout = 3000,
                    layout = "bottomCenter",
                    queue = "global"
                })
            end
        elseif data.current.value == 'hijack_vehicle' then
            menu.close()
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
        elseif data.current.value == 'fix_vehicle' then
            menu.close()
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
        elseif data.current.value == 'clean_vehicle' then
            menu.close()
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
        elseif data.current.value == 'del_vehicle' then
            menu.close()
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
        elseif data.current.value == 'dep_vehicle' then
            menu.close()
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, true)

            local towmodel = GetHashKey('flatbed3')
            local isVehicleTow = IsVehicleModel(vehicle, towmodel)

            if isVehicleTow then
                local targetVehicle = ESX.Game.GetVehicleInDirection()

                if CurrentlyTowedVehicle == nil then
                    if targetVehicle ~= 0 then
                        if not IsPedInAnyVehicle(playerPed, true) then
                            if vehicle ~= targetVehicle then
                                AttachEntityToEntity(targetVehicle, vehicle, 20,
                                                     -0.5, -5.0, 1.0, 0.0, 0.0,
                                                     0.0, false, false, false,
                                                     false, 20, true)
                                CurrentlyTowedVehicle = targetVehicle
                                ESX.ShowNotification(_U(
                                                         'vehicle_success_attached'))

                                if NPCOnJob then
                                    if NPCTargetTowable == targetVehicle then
                                        ESX.ShowNotification(_U(
                                                                 'please_drop_off'))
                                        Config.Zones.VehicleDelivery.Type = 1

                                        if Blips['NPCTargetTowableZone'] then
                                            RemoveBlip(
                                                Blips['NPCTargetTowableZone'])
                                            Blips['NPCTargetTowableZone'] = nil
                                        end

                                        Blips['NPCDelivery'] = AddBlipForCoord(
                                                                   Config.Zones
                                                                       .VehicleDelivery
                                                                       .Pos.x,
                                                                   Config.Zones
                                                                       .VehicleDelivery
                                                                       .Pos.y,
                                                                   Config.Zones
                                                                       .VehicleDelivery
                                                                       .Pos.z)
                                        SetBlipRoute(Blips['NPCDelivery'], true)
                                    end
                                end
                            else
                                ESX.ShowNotification(_U('cant_attach_own_tt'))
                            end
                        end
                    else
                        ESX.ShowNotification(_U('no_veh_att'))
                    end
                else
                    AttachEntityToEntity(CurrentlyTowedVehicle, vehicle, 20,
                                         -0.5, -12.0, 1.0, 0.0, 0.0, 0.0, false,
                                         false, false, false, 20, true)
                    DetachEntity(CurrentlyTowedVehicle, true, true)

                    if NPCOnJob then
                        if NPCTargetDeleterZone then

                            if CurrentlyTowedVehicle == NPCTargetTowable then
                                ESX.Game.DeleteVehicle(NPCTargetTowable)
                                TriggerServerEvent(
                                    'esx_mechanicjob:onNPCJobMissionCompleted')
                                StopNPCJob()
                                NPCTargetDeleterZone = false
                            else
                                ESX.ShowNotification(_U('not_right_veh'))
                            end

                        else
                            ESX.ShowNotification(_U('not_right_place'))
                        end
                    end

                    CurrentlyTowedVehicle = nil
                    ESX.ShowNotification(_U('veh_det_succ'))
                end
            else
                ESX.ShowNotification(_U('imp_flatbed'))
            end
        elseif data.current.value == 'object_spawner' then
            local playerPed = PlayerPedId()

            if IsPedSittingInAnyVehicle(playerPed) then
                ESX.ShowNotification(_U('inside_vehicle'))
                return
            end

            ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                             'mobile_mechanic_actions_spawn', {
                title = _U('objects'),
                align = 'top-left',
                elements = {
                    {label = _U('roadcone'), value = 'prop_roadcone02a'},
                    {label = _U('toolbox'), value = 'prop_toolchest_01'}
                }
            }, function(data2, menu2)
                local model = data2.current.value
                local coords = GetEntityCoords(playerPed)
                local forward = GetEntityForwardVector(playerPed)
                local x, y, z = table.unpack(coords + forward * 1.0)

                if model == 'prop_roadcone02a' then
                    z = z - 2.0
                elseif model == 'prop_toolchest_01' then
                    z = z - 2.0
                end

                ESX.Game.SpawnObject(model, {x = x, y = y, z = z}, function(obj)
                    SetEntityHeading(obj, GetEntityHeading(playerPed))
                    PlaceObjectOnGroundProperly(obj)
                end)
            end, function(data2, menu2) menu2.close() end)

        elseif data.current.value == 'setjob' then
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'setjob',
                                 {
                    title = 'Setjob',
                    align = 'top-left',
                    elements = {

                        {label = "ช่างฝึกหัด", value = '0'},
                        {label = "ช่างมืออาชีพ", value = '1'},
                        {label = "หัวหน้างาน", value = '2'},
                        {label = "ช่างชำนาญการ", value = '3'},
                        {label = "รองหัวหน้าช่าง", value = '4'}
                    }
                }, function(data2, menu2)
                    TriggerServerEvent('Bosssetjobmechanic:mechanic',
                                       GetPlayerServerId(closestPlayer),
                                       data2.current.value)
                    -- print('ok')
                    menu2.close()
                end, function(data2, menu2) menu2.close() end)
            else
                ESX.ShowNotification(_U('no_players'))
            end

        elseif data.current.value == 'setjobdefault' then
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                                 'setjobdefalut', {
                    title = 'Setjob',
                    align = 'top-left',
                    elements = {{label = "ประชาชน", value = '0'}}
                }, function(data, menu)
                    TriggerServerEvent('Bosssetjobmechanic:unemployed',
                                       GetPlayerServerId(closestPlayer),
                                       data.current.value)
                    -- print('ok')
                    TriggerServerEvent('esx_mechanicjob:removeitem', 'radio_agent', 1)
                    TriggerServerEvent('esx_mechanicjob:removeitem', 'mechanic_licence', 1)
                    menu.close()
                end, function(data, menu) menu.close() end)
            else
                ESX.ShowNotification(_U('no_players'))
            end
        end
    end, function(data, menu) menu.close() end)
end


function OpenFineMenu(player)

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine',
	{
		title    = _U('fine'),
		align    = 'right',
		elements = {
			{label = "สร้างบิล",   value = 'create_bills'}
		}
	}, function(data, menu)
		CreateBilling(player)
	end, function(data, menu)
		menu.close()
	end)

end

function CreateBilling(player)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'dialog_createbill',
	{
		title = "ใส่ชื่อบิล",
	}, function(data, menu)
		if data.value == nil then
			TriggerEvent("pNotify:SendNotification", {
				text = "กรุณาใส่รายละเอียดด้วย",
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		else
			CreateBillingPrice(player, data.value)
			menu.close()
		end
	end, function(data, menu)
		menu.close()
	end)
end

function CreateBillingPrice(player, value)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'dialog_createbill_price',
	{
		title = "ใส่จำนวนเงิน",
	}, function(data2, menu2)
		if tonumber(data2.value) then
			TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_mechanic',"Fine: "..value, tonumber(data2.value))
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


RegisterNetEvent('esx_mechanicjob:onHijack')
AddEventHandler('esx_mechanicjob:onHijack', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
        local vehicle

        if IsPedInAnyVehicle(playerPed, false) then
            vehicle = GetVehiclePedIsIn(playerPed, false)
        else
            vehicle =
                GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
        end

        local chance = math.random(100)
        local alarm = math.random(100)

        if DoesEntityExist(vehicle) then
            if alarm <= 33 then
                SetVehicleAlarm(vehicle, true)
                StartVehicleAlarm(vehicle)
            end

            TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)

            Citizen.CreateThread(function()
                Citizen.Wait(10000)
                if chance <= 66 then
                    SetVehicleDoorsLocked(vehicle, 1)
                    SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                    ClearPedTasksImmediately(playerPed)
                    ESX.ShowNotification(_U('veh_unlocked'))
                else
                    ESX.ShowNotification(_U('hijack_failed'))
                    ClearPedTasksImmediately(playerPed)
                end
            end)
        end
    end
end)







RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
    local specialContact = {
        name = _U('mechanic'),
        number = 'mechanic',
        base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAAA4BJREFUWIXtll9oU3cUx7/nJA02aSSlFouWMnXVB0ejU3wcRteHjv1puoc9rA978cUi2IqgRYWIZkMwrahUGfgkFMEZUdg6C+u21z1o3fbgqigVi7NzUtNcmsac40Npltz7S3rvUHzxQODec87vfD+/e0/O/QFv7Q0beV3QeXqmgV74/7H7fZJvuLwv8q/Xeux1gUrNBpN/nmtavdaqDqBK8VT2RDyV2VHmF1lvLERSBtCVynzYmcp+A9WqT9kcVKX4gHUehF0CEVY+1jYTTIwvt7YSIQnCTvsSUYz6gX5uDt7MP7KOKuQAgxmqQ+neUA+I1B1AiXi5X6ZAvKrabirmVYFwAMRT2RMg7F9SyKspvk73hfrtbkMPyIhA5FVqi0iBiEZMMQdAui/8E4GPv0oAJkpc6Q3+6goAAGpWBxNQmTLFmgL3jSJNgQdGv4pMts2EKm7ICJB/aG0xNdz74VEk13UYCx1/twPR8JjDT8wttyLZtkoAxSb8ZDCz0gdfKxWkFURf2v9qTYH7SK7rQIDn0P3nA0ehixvfwZwE0X9vBE/mW8piohhl1WH18UQBhYnre8N/L8b8xQvlx4ACbB4NnzaeRYDnKm0EALCMLXy84hwuTCXL/ExoB1E7qcK/8NCLIq5HcTT0i6u8TYbXUM1cAyyveVq8Xls7XhYrvY/4n3gC8C+dsmAzL1YUiyfWxvHzsy/w/dNd+KjhW2yvv/RfXr7x9QDcmo1he2RBiCCI1Q8jVj9szPNixVfgz+UiIGyDSrcoRu2J16d3I6e1VYvNSQjXpnucAcEPUOkGYZs/l4uUhowt/3kqu1UIv9n90fAY9jT3YBlbRvFTD4fw++wHjhiTRL/bG75t0jI2ITcHb5om4Xgmhv57xpGOg3d/NIqryOR7z+r+MC6qBJB/ZB2t9Om1D5lFm843G/3E3HI7Yh1xDRAfzLQr5EClBf/HBHK462TG2J0OABXeyWDPZ8VqxmBWYscpyghwtTd4EKpDTjCZdCNmzFM9k+4LHXIFACJN94Z6FiFEpKDQw9HndWsEuhnADVMhAUaYJBp9XrcGQKJ4qFE9k+6r2+MG3k5N8VQ22TVglbX2ZwOzX2VvNKr91zmY6S7N6zqZicVT2WNLyVSehESaBhxnOALfMeYX+K/S2yv7wmMAlvwyuR7FxQUyf0fgc/jztfkJr7XeGgC8BJJgWNV8ImT+AAAAAElFTkSuQmCC'
    }

    TriggerEvent('esx_phone:addSpecialContact', specialContact.name,
                 specialContact.number, specialContact.base64Icon)
end)



-- Create Blips
Citizen.CreateThread(function()

	for k, v in pairs(Config.MechanicStation) do
		local blip = AddBlipForCoord(v.Blip.Coords)

		SetBlipSprite(blip, v.Blip.Sprite)
		SetBlipDisplay(blip, v.Blip.Display)
		SetBlipScale(blip, v.Blip.Scale)
		SetBlipColour(blip, v.Blip.Colour)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString('Mechanic')
		EndTextCommandSetBlipName(blip)
	end
end)



Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local letSleep, isInMarker, hasExited = true, false, false
		local currentMechanic, currentPart, currentPartNum

		for hospitalNum,mechanic in pairs(Config.MechanicStation) do

			-- Mechanic Cloakrooms
			for k,v in ipairs(mechanic.Cloakrooms) do
				local distance = GetDistanceBetweenCoords(playerCoords, v, true)

				if distance < Config.DrawDistance and ESX.PlayerData.job.name == "mechanic" then
					DrawMarker(Config.Marker.type, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
					letSleep = false
				end

				if distance < Config.Marker.x and ESX.PlayerData.job.name == "mechanic" then
					isInMarker, currentMechanic, currentPart, currentPartNum = true, hospitalNum, 'Cloakrooms', k
				end
			end
			
			-- Mechanic Vehicle
			for k,v in ipairs(mechanic.Vehicles) do
				local distanceVeh = GetDistanceBetweenCoords(playerCoords, v.Spawner, true)

				if distanceVeh < Config.DrawDistance and ESX.PlayerData.job.name == "mechanic" then
					DrawMarker(Config.Marker.type, v.Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
					letSleep = false
				end

				if distanceVeh < Config.Marker.x and ESX.PlayerData.job.name == "mechanic" then
					isInMarker, currentMechanic, currentPart, currentPartNum = true, hospitalNum, 'Vehicles', k
				end
			end
		end
		
		if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastHospital ~= currentMechanic or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then

			if
				(LastHospital ~= nil and LastPart ~= nil and LastPartNum ~= nil) and
				(LastHospital ~= currentMechanic or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
			then
				TriggerEvent('esx_mechanicjob:hasExitedMarker', LastHospital, LastPart, LastPartNum)
				hasExited = true
			end

			HasAlreadyEnteredMarker, LastHospital, LastPart, LastPartNum = true, currentMechanic, currentPart, currentPartNum

			TriggerEvent('esx_mechanicjob:hasEnteredMarker', currentMechanic, currentPart, currentPartNum)

		end
			

		if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_mechanicjob:hasExitedMarker', LastHospital, LastPart, LastPartNum)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)


AddEventHandler('esx_mechanicjob:hasEnteredMarker', function(mechanic, part, partNum)
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
		if part == 'Cloakrooms' then
			CurrentAction = part
			CurrentActionMsg = _U('actions_prompt')
			CurrentActionData = {}
		elseif part == 'Vehicles' then
			CurrentAction = part
			CurrentActionMsg = _U('garage_prompt')
			CurrentActionData = {mechanic = mechanic, partNum = partNum, part = part}
		end
	end
end)

AddEventHandler('esx_mechanicjob:hasExitedMarker', function(mechanic, part, partNum)
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

				if CurrentAction == 'Cloakrooms' then
					OpenMechanicActionsMenu()
				elseif CurrentAction == 'Vehicles' then
					OpenVehicleSpawnerMenu(CurrentActionData.mechanic, CurrentActionData.partNum, CurrentActionData.part)
				end

				CurrentAction = nil

			end
			
		elseif ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'mechanic'  then
			if IsControlJustReleased(0, Keys['F6']) then
				OpenMechanicMenu()
			end

		else
			Citizen.Wait(500)
		end
	end
end)


function OpenMechanicActionsMenu()
	local elements = {
		{label = _U('cloakroom'), value = 'cloakroom'}
	}


	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'actions', {
		title    = 'Mechanic Locker',
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


function OpenCloakroomMenu()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title    = _U('cloakroom'),
		align    = 'top-right',
		elements = {
			{label = _U('mc_clothes_civil'), value = 'citizen_wear'},
			{label = _U('mc_clothes'), value = 'mc_wear'},
		}
	}, function(data, menu)
		if data.current.value == 'citizen_wear' then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		elseif data.current.value == 'mc_wear' then
			ChangeUnifrom()
		end

		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end



function ChangeUnifrom()
	if Config.MechanicUniforms[ESX.GetPlayerData().job.grade_name] then
		TriggerEvent('skinchanger:getSkin', function(skin)
			if skin.sex == 0 then
				TriggerEvent('skinchanger:loadClothes', skin, Config.MechanicUniforms[ESX.GetPlayerData().job.grade_name].male)
			else
				TriggerEvent('skinchanger:loadClothes', skin, Config.MechanicUniforms[ESX.GetPlayerData().job.grade_name].female)
			end
		end)
	end
end


AddEventHandler('esx:onPlayerDeath', function(data) isDead = true end)
AddEventHandler('playerSpawned', function(spawn) isDead = false end)


RegisterNetEvent('esx_mechanicjob:onFixkit')
AddEventHandler('esx_mechanicjob:onFixkit', function()
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end

		if DoesEntityExist(vehicle) then
			TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
			Citizen.CreateThread(function()
				    TriggerEvent("mythic_progressbar:client:progress")
					Citizen.Wait(20000)
				SetVehicleFixed(vehicle)
				SetVehicleDeformationFixed(vehicle)
				SetVehicleUndriveable(vehicle, false)
				ClearPedTasksImmediately(playerPed)
				ESX.ShowNotification(_U('veh_repaired'))
			end)
		end
	end
end)


RegisterNetEvent('esx_mechanicjob:userepairkit')
AddEventHandler('esx_mechanicjob:userepairkit', function()
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end

		if DoesEntityExist(vehicle) then
			TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
			Citizen.CreateThread(function()
				    TriggerEvent("mythic_progressbar:client:progress")
					Citizen.Wait(20000)
				SetVehicleFixed(vehicle)
				SetVehicleDeformationFixed(vehicle)
				SetVehicleUndriveable(vehicle, false)
				ClearPedTasksImmediately(playerPed)
				ESX.ShowNotification(_U('veh_repaired'))
			end)
		end
	end
end)


RegisterNetEvent('esx_mechanicjob:userepairkit')
AddEventHandler('esx_mechanicjob:userepairkit', function()
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle

		if IsPedInAnyVehicle(playerPed, false) then
			exports['mythic_notify']:SendAlert('inform', 'คุณกำลังอยู่บนรถ !')
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
			if DoesEntityExist(vehicle) then
				local trunkpos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "engine"))
				local distanceToTrunk = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), trunkpos, 1)
				if distanceToTrunk <= 1.5 then
					local vehhealth = GetVehicleEngineHealth(vehicle)
					Citizen.CreateThread(function()
						SetVehicleDoorOpen(vehicle, 4, false)
						TriggerEvent("mythic_progbar:client:progress", {
							name = "Repair",
							duration = Config.HalfKitTime,
							label = "Repairing In Progress",
							useWhileDead = false,
							canCancel = true,
							controlDisables = {
								disableMovement = true,
								disableCarMovement = true,
								disableMouse = false,
								disableCombat = true,
							},
							animation = {
								animDict = "mini@repair",
								anim = "fixing_a_player",
								flags = 49,
							},
						}, function(status)
							if not status then
								cancel = false
								if IsPedInAnyVehicle(playerPed, false) then
									exports['mythic_notify']:SendAlert('inform', 'คุณกำลังอยู่บนรถ !')
								else
									SetVehicleDeformationFixed(vehicle)
									SetVehicleFixed(vehicle)
									SetVehicleDeformationFixed(vehicle)
									SetVehicleUndriveable(vehicle, false)
									ClearPedTasksImmediately(playerPed)
									if(vehhealth < 300) then
										SetVehicleEngineHealth(vehicle, 600.0)
									else
										SetVehicleEngineHealth(vehicle, GetVehicleEngineHealth(vehicle))
									end
									SetVehicleDoorShut(vehicle, 4, false)
									SetVehicleUndriveable(vehicle, false)
									SetVehicleEngineOn(vehicle, true, true)
									ClearPedTasksImmediately(playerPed)
									
									exports.mythic_notify:SendAlert('success', _U('vehicle_repaired'))
								end
							else
								cancel = true
								SetVehicleDoorShut(vehicle, 4, false)
							end
						end)	
					end)
				else
					exports.mythic_notify:SendAlert('inform', 'ต้องใช้ที่ฝากระโปรงรถเท่านั้น')
				end
			end
		end
	end
end)

RegisterNetEvent('esx_mechanicjob:Getcount')
AddEventHandler('esx_mechanicjob:Getcount', function()
    if exports["stk_check"]:CheckJob('mechanic', 1) then
		TriggerEvent("pNotify:SendNotification", {
            text = "มีช่างอยู่ในเมือง ไม่สามารถซ่อมได้ กรุณาเรียกช่าง!!",
            type = "error",
            queue = "lmao",
            timeout = 10000,
            layout = "bottomCenter"
        })
	else
		TriggerEvent('esx_mechanicjob:userepairkit')
		TriggerEvent('esx:showNotification', ('You use repairkit'))
		TriggerServerEvent('esx_mechanicjob:removeitem', 'repairkit', 1)
	end
end)

function OpenIdentityCardMenu(player)

	ESX.TriggerServerCallback('esx_mechanicjob:getOtherPlayerData', function(data)

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
			title    = "ตรวจบัตรประชาชน",
			align    = 'right',
			elements = elements,
		}, function(data, menu)
	
		end, function(data, menu)
			menu.close()
		end)
	
	end, GetPlayerServerId(player))

end


function OpenVehicleSpawnerMenu(type, partNum, part)
	local playerCoords = GetEntityCoords(PlayerPedId())
	PlayerData = ESX.GetPlayerData()
	local elements = {
		{label = "โรงรถ", action = 'garage'},
		{label = "เก็บรถ", action = 'store_garage'},
		{label = "ซื้อรถ", action = 'buy_vehicle'},
	}

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle', {
		title    = _U('garage_title'),
		align    = 'right',
		elements = elements
	}, function(data, menu)

		if data.current.action == 'buy_vehicle' then
			local shopElements, shopCoords = {}
	
			if type then
				shopCoords = Config.MechanicStation[type].Vehicles[partNum].InsideShop
				local authorizedVehicles = Config.AuthorizedVehicles[ESX.PlayerData.job.grade_name]

				if #Config.AuthorizedVehicles['Shared'] > 0 then
					for k,vehicle in ipairs(Config.AuthorizedVehicles['Shared']) do
						table.insert(shopElements, {
							label = ('%s - <span class="green-text">%s</span>'):format(vehicle.label, _U('shop_item', ESX.Math.GroupDigits(vehicle.price))),
							name  = vehicle.label,
							model = vehicle.model,
							price = vehicle.price,
							type  = 'mechanic'
						})
					end
				else
					if #Config.AuthorizedVehicles['Shared'] == 0 then
						return
					end
					OpenShopMenu(shopElements, playerCoords, shopCoords)
				end

				if #Config.AuthorizedVehicles > 0 then
					for k,vehicle in ipairs(authorizedVehicles) do
						table.insert(shopElements, {
							label = ('%s - <span class="green-text">%s</span>'):format(vehicle.label, _U('shop_item', ESX.Math.GroupDigits(vehicle.price))),
							name  = vehicle.label,
							model = vehicle.model,
							price = vehicle.price,
							type  = 'mechanic'
						})
					end
				else
					if #Config.AuthorizedVehicles['Shared'] == 0 then
						return
					end
					OpenShopMenu(shopElements, playerCoords, shopCoords)
				end
			end
		elseif data.current.action == 'garage' then
			local garage = {}

			ESX.TriggerServerCallback('esx_vehicleshop:retrieveJobVehicles', function(jobVehicles)
				if #jobVehicles > 0 then
					for k,v in ipairs(jobVehicles) do
						local props = json.decode(v.vehicle)
						local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
						local label = ('%s - <span class="orange-text">%s</span>: '):format(vehicleName, props.plate)

						if v.stored then
							label = label .. ('<span class="green-text">%s</span>'):format(_U('garage_stored'))
						else
							label = label .. ('<span class="red-text">%s</span>'):format(_U('garage_notstored'))
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
						align    = 'right',
						elements = garage
					}, function(data2, menu2)
						if data2.current.stored then
							local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(type, partNum, part)

							if foundSpawn then
								menu2.close()

								ESX.Game.SpawnVehicle(data2.current.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
									ESX.Game.SetVehicleProperties(vehicle, data2.current.vehicleProps)

									TriggerServerEvent('esx_vehicleshop:setJobVehicleState', data2.current.vehicleProps.plate, false)
									TriggerEvent("pNotify:SendNotification", {
										text = '<strong class="green-text">นำรถของคุณออกมาเรียบร้อยแล้ว</strong>',
										type = "success",
										timeout = 3000,
										layout = "bottomCenter",
										queue = "global"
									})
								end)
							end
						else
							TriggerEvent("pNotify:SendNotification", {
								text = 'รถของคุณไม่ได้เก็บไว้ในโรงรถ',
								type = "success",
								timeout = 3000,
								layout = "bottomCenter",
								queue = "global"
							})
						end
					end, function(data2, menu2)
						menu2.close()
					end)

				else
					TriggerEvent("pNotify:SendNotification", {
						text = 'ไม่มีรถในโรงรถ',
						type = "success",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				end
			end, 'mechanic')

		elseif data.current.action == 'store_garage' then
			StoreNearbyVehicle(playerCoords)
		elseif data.current.action == 'mod_vehicle' then
			
			local garage_mod = {}
			ESX.TriggerServerCallback('esx_mechanicjob:getVehicleFrommod', function(jobVehicles)
				if #jobVehicles > 0 then
					for k,v in ipairs(jobVehicles) do
						local props = json.decode(v.vehicle)
						local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
						local label = ('<span class="orange-text">%s</span>: '):format(props.plate)

						if v.mod_by then
							label = label .. ('โดย: %s'):format(v.mod_by).." ".. v.time
						else
							label = label .. ('โดย: %s'):format("Unknow").." ".. v.time
						end

						table.insert(garage_mod, {
							label = label,
							value = k
							-- stored = v.stored,
							-- value = props
						})
					end

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_garage1', {
						title    = "รายชื่อรถ",
						align    = 'right',
						elements = garage_mod
					}, function(data2, menu2)
						local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(type, partNum, part)
						if foundSpawn then
							local value = data2.current.value
							local props = json.decode(jobVehicles[value].vehicle)

							ESX.Game.SpawnVehicle(props.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
								ESX.Game.SetVehicleProperties(vehicle, props)

								TriggerServerEvent('esx_mechanicjob:setVehicleFrommod', props.plate)
								TriggerEvent("pNotify:SendNotification", {
									text = '<strong class="green-text">เบิกรถเรียบร้อยแล้ว</span>',
									type = "success",
									timeout = 3000,
									layout = "bottomCenter",
									queue = "global"
								})
							end)
							menu2.close()
						end
					end, function(data2, menu2)
						menu2.close()
					end)

				else
					TriggerEvent("pNotify:SendNotification", {
						text = 'ไม่มีรถที่โดนยึด',
						type = "error",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				end
			end)

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
		TriggerEvent("pNotify:SendNotification", {
			text = 'ไม่มียานพาหนะใกล้เคียง',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
		return
	end

	ESX.TriggerServerCallback('esx_mechanicjob:storeNearbyVehicle', function(storeSuccess, foundNum)
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
			TriggerEvent("pNotify:SendNotification", {
				text = '<strong class="green-text">เก็บรถเรียบร้อยแล้ว</strong>',
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		else
			TriggerEvent("pNotify:SendNotification", {
				text = 'ไม่พบยานพาหนะที่เป็นของใกล้เคียง',
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		end
	end, vehiclePlates)
end

function GetAvailableVehicleSpawnPoint(type, partNum, part)
	-- print(partNum)
	-- print(type)
	local spawnPoints = Config.MechanicStation[type][part][partNum].SpawnPoints
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
		TriggerEvent("pNotify:SendNotification", {
			text = 'จุดเรียกรถที่มีอยู่ทั้งหมดถูกบล็อกในขณะนี้',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
		return false
	end
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

				ESX.TriggerServerCallback('esx_mechanicjob:buyJobVehicle', function (bought)
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

function SendToCommunityService(player)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'Community Service Menu', {
		title = "Community Service Menu",
	}, function (data2, menu)
		local community_services_count = tonumber(data2.value)
		
		if community_services_count == nil then
			ESX.ShowNotification('Invalid services count.')
		else
			TriggerServerEvent("esx_communityservice:sendToCommunityService", player, community_services_count)
			menu.close()
		end
	end, function (data2, menu)
		menu.close()
	end)
end


function AnnoucementMC()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'Annoucement Medical', {
		title = "ประกาศช่าง",
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
			TriggerServerEvent("esx_mechanicjob:sendAnnouce", AnnouceText)
			menu.close()
		end
	
	end, function (data2, menu)
		menu.close()
	end)
end

Citizen.CreateThread(function()
    while true do
        local sleepP = 1000
        local p = PlayerPedId()
        local pc = GetEntityCoords(p)
        local bcoord = vector3(Config.BossMenu.Pos.x,Config.BossMenu.Pos.y,Config.BossMenu.Pos.z)
        local d = Vdist(pc, bcoord)
        
        if d < 30 and ESX.GetPlayerData().job.name == 'mechanic' then sleepP = 7
            DrawMarker(22, bcoord.x, bcoord.y, bcoord.z,nil,nil,nil,nil,nil,nil,1.0,1.0,1.0,255,161,0,100,false,false,2,true,false,false,false)
        end
        
        if d < 1.5 and ESX.GetPlayerData().job.name == 'mechanic' then sleepP = 1
            exports["esx_text_ui"]:Help('~INPUT_PICKUP~ ~b~BossMenu')
            if IsControlJustPressed(0,38) then
                if ESX.GetPlayerData().job.name == 'mechanic' and ESX.GetPlayerData().job.grade_name == 'boss' then
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
            TriggerServerEvent('esx_mechanicjob:GetDepartMent')
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
            TriggerServerEvent('esx_mechanicjob:setJobforid', data.value, ESX.GetPlayerData().job.name)
        end
        menu.close()
    end,function(data, menu)
		menu.close()
		end
	)
end

RegisterNetEvent('esx_mechanicjob:SetDepartment')
AddEventHandler('esx_mechanicjob:SetDepartment', function(data)
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
    ESX.TriggerServerCallback('esx_mechanicjob:getjob', function(result)
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
                TriggerServerEvent('esx_mechanicjob:SetJobPlayer_online', dataPlayer.id, data.current.name, data.current.grade)
            else
                TriggerServerEvent('esx_mechanicjob:SetJobPlayer_offline', dataPlayer.id, data.current.name, data.current.grade)
            end
            menu.close()
        end, function(data, menu)
            menu.close()
        end)
    end, ESX.GetPlayerData().job.name) 
end


