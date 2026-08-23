ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118, ["Enter"] = 191
}



local HasAlreadyEnteredMarker = false
local LastStation, LastPart, LastPartNum, LastEntity
local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}
local IsHandcuffed = false
local HandcuffTimer = {}
local DragStatus = {}
DragStatus.IsDragged = false
local hasAlreadyJoined = false
local blipsCops = {}
local isDead = false
local CurrentTask = {}
local playerInService = false
local spawnedVehicles, isInShopMenu = {}, false


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)


AddEventHandler("playerSpawned", function()
	TriggerEvent('CarryPeople:cl_stop')
end)


function cleanPlayer(playerPed)
    SetPedArmour(playerPed, 0)
    ClearPedBloodDamage(playerPed)
    ResetPedVisibleDamage(playerPed)
    ClearPedLastWeaponDamage(playerPed)
    ResetPedMovementClipset(playerPed, 0)
end


function OpenArmoryMenu(station)
    local elements = {{label = _U('buy_weapons'), value = 'buy_weapons'}}

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory', {
        title = _U('armory'),
        align = 'top-right',
        elements = elements
    }, function(data, menu)

        if data.current.value == 'get_weapon' then
            OpenGetWeaponMenu()
        elseif data.current.value == 'put_weapon' then
            OpenPutWeaponMenu()
        elseif data.current.value == 'buy_weapons' then
            OpenBuyWeaponsMenu()
        elseif data.current.value == 'put_stock' then
            OpenPutStocksMenu()
        elseif data.current.value == 'get_stock' then
            OpenGetStocksMenu()
        end

    end, function(data, menu)
        menu.close()

        CurrentAction = 'menu_armory'
        CurrentActionMsg = _U('open_armory')
        CurrentActionData = {station = station}
    end)
end

function OpenVehicleSpawnerMenu(type, station, part, partNum)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local elements = {
        {label = "โรงรถ", action = 'garage'},
        {label = "เก็บรถ", action = 'store_garage'},
        {label = "ซื้อยานพาหนะเจ้าหน้าที่", action = 'buy_vehicle'},
        -- {label = "รถที่ถูกยึด", action = 'police_vehicle'}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle', {
        title = _U('garage_title'),
        align = 'top-right',
        elements = elements
    }, function(data, menu)

        if data.current.action == 'buy_vehicle' then
            local shopElements, shopCoords = {}

            if type == 'car' then
                shopCoords = Config.PoliceStations[station].Vehicles[partNum]
                                 .InsideShop
                local authorizedVehicles =
                    Config.AuthorizedVehicles[ESX.PlayerData.job.grade_name]

                if #Config.AuthorizedVehicles['Shared'] > 0 then
                    for k, vehicle in
                        ipairs(Config.AuthorizedVehicles['Shared']) do
                        table.insert(shopElements, {
                            label = ('%s - <span class="green-text">%s</span>'):format(
                                vehicle.label, _U('shop_item', ESX.Math
                                                      .GroupDigits(vehicle.price))),
                            name = vehicle.label,
                            model = vehicle.model,
                            price = vehicle.price,
                            type = 'car'
                        })
                    end
                end

                if #authorizedVehicles > 0 then
                    for k, vehicle in ipairs(authorizedVehicles) do
                        table.insert(shopElements, {
                            label = ('%s - <span class="green-text">%s</span>'):format(
                                vehicle.label, _U('shop_item', ESX.Math
                                                      .GroupDigits(vehicle.price))),
                            name = vehicle.label,
                            model = vehicle.model,
                            price = vehicle.price,
                            type = 'car'
                        })
                    end
                else
                    if #Config.AuthorizedVehicles['Shared'] == 0 then
                        return
                    end
                end
            elseif type == 'helicopter' then
                shopCoords = Config.PoliceStations[station].Helicopters[partNum]
                                 .InsideShop
                local authorizedHelicopters =
                    Config.AuthorizedHelicopters[ESX.PlayerData.job.grade_name]

                if #authorizedHelicopters > 0 then
                    for k, vehicle in ipairs(authorizedHelicopters) do
                        table.insert(shopElements, {
                            label = ('%s - <span class="green-text">%s</span>'):format(
                                vehicle.label, _U('shop_item', ESX.Math
                                                      .GroupDigits(vehicle.price))),
                            name = vehicle.label,
                            model = vehicle.model,
                            price = vehicle.price,
                            livery = vehicle.livery or nil,
                            type = 'helicopter'
                        })
                    end
                else
                    TriggerEvent("pNotify:SendNotification", {
                        text = 'คุณไม่ได้รับอนุญาตให้ซื้อเฮลิคอปเตอร์',
                        type = "success",
                        timeout = 3000,
                        layout = "bottomCenter",
                        queue = "global"
                    })
                    return
                end
            end

            OpenShopMenu(shopElements, playerCoords, shopCoords)
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
						align    = 'top-right',
						elements = garage
					}, function(data2, menu2)
						if data2.current.stored then
							local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(station, part, partNum)

							if foundSpawn then
								menu2.close()

								ESX.Game.SpawnVehicle(data2.current.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
									ESX.Game.SetVehicleProperties(vehicle, data2.current.vehicleProps)

									TriggerServerEvent('esx_vehicleshop:setJobVehicleState', data2.current.vehicleProps.plate, false)
									TriggerEvent("pNotify:SendNotification", {
										text = 'นำรถของคุณออกมาเรียบร้อยแล้ว',
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
			end, type)

        elseif data.current.action == 'store_garage' then
            StoreNearbyVehicle(playerCoords)
        elseif data.current.action == 'police_vehicle' then

            local garage_police = {}
            ESX.TriggerServerCallback('esx_policejob:getVehicleFromPolice',
                                      function(jobVehicles)
                if #jobVehicles > 0 then
                    for k, v in ipairs(jobVehicles) do
                        local props = json.decode(v.vehicle)
                        local vehicleName = GetLabelText(
                                                GetDisplayNameFromVehicleModel(
                                                    props.model))
                        local label =
                            ('<span class="orange-text">%s</span>: '):format(
                                props.plate)

                        if v.police_by then
                            label = label ..
                                        ('ยึดโดย: %s'):format(
                                            v.police_by) .. " " .. v.time
                        else
                            label = label ..
                                        ('ยึดโดย: %s'):format(
                                            "Unknow") .. " " .. v.time
                        end

                        table.insert(garage_police, {
                            label = label,
                            value = k
                            -- stored = v.stored,
                            -- value = props
                        })
                    end

                    ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                                     'vehicle_garage1', {
                        title = "รายชื่อรถที่ถูกยึด",
                        align = 'top-right',
                        elements = garage_police
                    }, function(data2, menu2)
                        local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(station, part, partNum)
                        if foundSpawn then
                            local value = data2.current.value
                            local props =
                                json.decode(jobVehicles[value].vehicle)

                            ESX.Game.SpawnVehicle(props.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
                                ESX.Game.SetVehicleProperties(vehicle, props)

                                TriggerServerEvent('esx_policejob:setVehicleFromPolice', props.plate)

                                TriggerEvent("pNotify:SendNotification", {
                                    text = 'เบิกรถเรียบร้อยแล้ว',
                                    type = "success",
                                    timeout = 3000,
                                    layout = "bottomCenter",
                                    queue = "global"
                                })

                                local sendToDiscord = ''..GetPlayerName(PlayerId())..' นำรถที่ถูกยึด ทะเบียน '..props.plate..' ออกจากโรงพัก'
                                TriggerEvent('azael_dc-serverlogs:insertData', 'PoliceReturn', sendToDiscord, GetPlayerServerId(PlayerId()), '^5')
                            end)
                            menu2.close()
                        end
                    end, function(data2, menu2) menu2.close() end)

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

    end, function(data, menu) menu.close() end)

end

function StoreNearbyVehicle(playerCoords)
    local vehicles, vehiclePlates = ESX.Game.GetVehiclesInArea(playerCoords,
                                                               30.0), {}

    if #vehicles > 0 then
        for k, v in ipairs(vehicles) do

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

    ESX.TriggerServerCallback('esx_policejob:storeNearbyVehicle',
                              function(storeSuccess, foundNum)
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
                if attempts > 30 then break end

                vehicles = ESX.Game.GetVehiclesInArea(playerCoords, 30.0)
                if #vehicles > 0 then
                    for k, v in ipairs(vehicles) do
                        if ESX.Math.Trim(GetVehicleNumberPlateText(v)) ==
                            vehicleId.plate then
                            ESX.Game.DeleteVehicle(v)
                            break
                        end
                    end
                end
            end

            IsBusy = false
            TriggerEvent("pNotify:SendNotification", {
                text = 'เก็บรถเรียบร้อยแล้ว',
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

function GetAvailableVehicleSpawnPoint(station, part, partNum)
    local spawnPoints = Config.PoliceStations[station][part][partNum].SpawnPoints
    local found, foundSpawnPoint = false, nil

    for i = 1, #spawnPoints, 1 do
        if ESX.Game.IsSpawnPointClear(spawnPoints[i].coords,
                                      spawnPoints[i].radius) then
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
        title = _U('vehicleshop_title'),
        align = 'top-right',
        elements = elements
    }, function(data, menu)

        ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                         'vehicle_shop_confirm', {
            title = _U('vehicleshop_confirm', data.current.name,
                       data.current.price),
            align = 'top-right',
            elements = {
                {label = _U('confirm_no'), value = 'no'},
                {label = _U('confirm_yes'), value = 'yes'}
            }
        }, function(data2, menu2)

            if data2.current.value == 'yes' then
                local newPlate = exports['esx_vehicleshop']:GeneratePlate()
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                local props = ESX.Game.GetVehicleProperties(vehicle)
                props.plate = newPlate

                ESX.TriggerServerCallback('esx_policejob:buyJobVehicle',
                                          function(bought)
                    if bought then
                        TriggerEvent("pNotify:SendNotification", {
                            text = _U('vehicleshop_bought', data.current.name,
                                      ESX.Math.GroupDigits(data.current.price)),
                            type = "success",
                            timeout = 3000,
                            layout = "bottomCenter",
                            queue = "global"
                        })

                        isInShopMenu = false
                        ESX.UI.Menu.CloseAll()

                        DeleteSpawnedVehicles()
                        FreezeEntityPosition(playerPed, false)
                        SetEntityVisible(playerPed, true)

                        ESX.Game.Teleport(playerPed, restoreCoords)
                    else
                        TriggerEvent("pNotify:SendNotification", {
                            text = "คุณมีเงินไม่เพียงพอ",
                            type = "error",
                            timeout = 3000,
                            layout = "bottomCenter",
                            queue = "global"
                        })
                        menu2.close()
                    end
                end, props, data.current.type)
            else
                menu2.close()
            end

        end, function(data2, menu2) menu2.close() end)

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
        ESX.Game.SpawnLocalVehicle(data.current.model, shopCoords, 0.0,
                                   function(vehicle)
            table.insert(spawnedVehicles, vehicle)
            TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
            FreezeEntityPosition(vehicle, true)

            if data.current.livery then
                SetVehicleModKit(vehicle, 0)
                SetVehicleLivery(vehicle, data.current.livery)
            end
        end)
    end)

    WaitForVehicleToLoad(elements[1].model)
    ESX.Game.SpawnLocalVehicle(elements[1].model, shopCoords, 0.0,
                               function(vehicle)
        table.insert(spawnedVehicles, vehicle)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        FreezeEntityPosition(vehicle, true)

        if elements[1].livery then
            SetVehicleModKit(vehicle, 0)
            SetVehicleLivery(vehicle, elements[1].livery)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        local sleepc = 1000

        if isInShopMenu then sleepc = 1
            DisableControlAction(0, 75, true) -- Disable exit vehicle
            DisableControlAction(27, 75, true) -- Disable exit vehicle
        end
		Citizen.Wait(sleepc)
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
    modelHash = (type(modelHash) == 'number' and modelHash or
                    GetHashKey(modelHash))

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

function OpenPoliceActionsMenu()
    ESX.UI.Menu.CloseAll()
    local elements = {}

    table.insert(elements, {label = _U('citizen_interaction'), value = 'citizen_interaction'})
    table.insert(elements, {label = _U('vehicle_interaction'), value = 'vehicle_interaction'})
    table.insert(elements, {label = _U('object_spawner'), value = 'object_spawner'})
	-- table.insert(elements, {label = "Jail คุกตู้ปลา", value = 'jail_fishtank'})
    table.insert(elements, {label = "Jail คุกใหญ่", value = 'jail_menu'})
    table.insert(elements, {label = '<span style="color:red;">วงเคอร์ฟิว 1', value = 'curfew'})
    table.insert(elements, {label = '<span style="color:red;">วงเคอร์ฟิว 2', value = 'curfew2'})
    table.insert(elements, {label = '<span style="color:red;">วงเคอร์ฟิว 3', value = 'curfew3'})
    table.insert(elements, {label = '<span style="color:white;">ประกาศตำรวจ', value = 'annPol'})
	table.insert(elements, {label = "เคสตำรวจ", value = 'case_police'})
    
    if ESX.GetPlayerData().job.grade_name == 'boss' then
        table.insert(elements, {label = "แต่งตั้ง", value = 'setjob'})
        table.insert(elements, {label = "ปลดยศ", value = 'setjobdefault'})
        table.insert(elements, {label = "เบิกของในคลัง", value = 'boss_opensafe'})
    end
    
    

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'police_actions', {
        title = 'Police',
        align = 'top-right',
        elements = elements
    }, function(data, menu)

        if data.current.value == 'jail_menu' then
            -- TriggerEvent("esx-qalle-jail:openJailMenu")
			exports['MRB_FUNNY__JailX']:OPENUI()
        elseif data.current.value == 'jail_fishtank' then
            TriggerEvent("esx-qalle-jail:openJailMenuTank")
        elseif data.current.value == 'citizen_interaction' then
            local elements = {
				{label = "อุ้ม", value = 'canCarry'},
                {label = _U('id_card'), value = 'identity_card'},
                {label = _U('search'), value = 'body_search'},
                {label = _U('handcuff'), value = 'handcuff'},
                {label = _U('unhandcuff'), value = 'unhandcuff'},
                {label = _U('drag'), value = 'drag'},
                {label = _U('put_in_vehicle'), value = 'put_in_vehicle'},
                {label = _U('out_the_vehicle'), value = 'out_the_vehicle'},
                {label = _U('fine'), value = 'fine'},
                {label = _U('unpaid_bills'), value = 'unpaid_bills'},
				{label = "Community Service", value = 'communityservice'},
                -- {label = 'ตรวจสารเสพติด', value = 'drugs'}
            }

            -- if Config.EnableLicenses then
            --     table.insert(elements,
            --                  {label = _U('license_check'), value = 'license'})
            -- end

            ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                             'citizen_interaction', {
                title = _U('citizen_interaction'),
                align = 'top-right',
                elements = elements
            }, function(data2, menu2)
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    local action = data2.current.value

                    if action == 'identity_card' then
                        OpenIdentityCardMenu(closestPlayer)
						TriggerServerEvent('cdc5be83-c880-48c9-93a8-c57db0c8f87e', GetPlayerServerId(closestPlayer), GetPlayerServerId(PlayerId()))
                    elseif action == 'body_search' then
                        ESX.UI.Menu.CloseAll()
                        local closestPlayerPed = GetPlayerPed(closestPlayer)
                        if not IsPedDeadOrDying(closestPlayerPed, 1) then
                            TriggerServerEvent('esx_policejob:body_search', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))

                            OpenBodySearchMenu(closestPlayer)
                        else
                            TriggerEvent("pNotify:SendNotification", {
                                text = 'คุณไม่สามารถค้นตัวผู้บาดเจ็บได้',
                                type = "error",
                                timeout = 3000,
                                layout = "bottomCenter",
                                queue = "global"
                            })
                            return
                        end
                    elseif action == 'handcuff' then
                        playerheading = GetEntityHeading(GetPlayerPed(-1))
                        playerlocation = GetEntityForwardVector(PlayerPedId())
                        playerCoords = GetEntityCoords(GetPlayerPed(-1))
                        TriggerServerEvent('esx_policejob:handcuff',
                                           GetPlayerServerId(closestPlayer),
                                           playerheading, playerCoords,
                                           playerlocation)
						Wait(2000)
                    elseif action == 'unhandcuff' then
                        playerheading = GetEntityHeading(GetPlayerPed(-1))
                        playerlocation = GetEntityForwardVector(PlayerPedId())
                        playerCoords = GetEntityCoords(GetPlayerPed(-1))
                        TriggerServerEvent('esx_policejob:unhandcuff',
                                           GetPlayerServerId(closestPlayer),
                                           playerheading, playerCoords,
                                           playerlocation)
                    elseif action == 'drag' then
                        TriggerServerEvent('esx_policejob:SendDrag',
                                           GetPlayerServerId(closestPlayer))
                    elseif action == 'put_in_vehicle' then
                        TriggerServerEvent('esx_policejob:putInVehicle',
                                           GetPlayerServerId(closestPlayer))
                    elseif action == 'out_the_vehicle' then
                        TriggerServerEvent('esx_policejob:OutVehicle',
                                           GetPlayerServerId(closestPlayer))
                    elseif action == 'fine' then
                        OpenFineMenu(closestPlayer)
                    elseif action == 'license' then
                        ShowPlayerLicense(closestPlayer)
                    elseif action == 'canCarry' then
                        TriggerEvent('CarryPeople:command')
					elseif action == 'unpaid_bills' then
                        TriggerServerEvent('esx_policejob:GetBillPlayer', GetPlayerServerId(closestPlayer))

                    elseif action == 'drugs' then
                        ESX.TriggerServerCallback('crossover_drugs:GetStatusDrugs', function(status)
                            if status == nil then
                                TriggerEvent("pNotify:SendNotification", {
                                    text = 'ไม่พบสารเสพติด',
                                    type = "success",
                                    timeout = 3000,
                                    layout = "bottomCenter",
                                    queue = "global"
                                })
                            elseif status == 'weed' then
                                TriggerEvent("pNotify:SendNotification", {
                                    text = 'พบสารเสพติด กัญชา',
                                    type = "alert",
                                    timeout = 3000,
                                    layout = "bottomCenter",
                                    queue = "global"
                                })
                            elseif status == 'alcohol' then
                                TriggerEvent("pNotify:SendNotification", {
                                    text = 'พบสาร แอลกอฮอล์',
                                    type = "alert",
                                    timeout = 3000,
                                    layout = "bottomCenter",
                                    queue = "global"
                                })
                            elseif status == 'meth' then
                                TriggerEvent("pNotify:SendNotification", {
                                    text = 'พบสารเสพติด แอมเฟตามีน',
                                    type = "alert",
                                    timeout = 3000,
                                    layout = "bottomCenter",
                                    queue = "global"
                                })
                            elseif status == 'cocain' then
                                TriggerEvent("pNotify:SendNotification", {
                                    text = 'พบสารเสพติด โคเคน',
                                    type = "alert",
                                    timeout = 3000,
                                    layout = "bottomCenter",
                                    queue = "global"
                                })
                            end
                        end, GetPlayerServerId(closestPlayer))
					elseif action == 'communityservice' then
						SendToCommunityService(GetPlayerServerId(closestPlayer))  
					end
                else
                    TriggerEvent("pNotify:SendNotification", {
                        text = "ไม่มีผู้เล่นอยู่ใกล้คุณ",
                        type = "success",
                        timeout = 3000,
                        layout = "bottomCenter",
                        queue = "global"
                    })
                end
            end, function(data2, menu2) menu2.close() end)
        elseif data.current.value == 'vehicle_interaction' then
            local elements = {}
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local vehicle = ESX.Game.GetVehicleInDirection()

            if DoesEntityExist(vehicle) then
                table.insert(elements, {
                    label = "ข้อมูลรถ",
                    value = 'vehicle_infos'
                })
                table.insert(elements, {
                    label = "ปลดล็อครถ",
                    value = 'hijack_vehicle'
                })
                table.insert(elements, {
                    label = "ส่งรถไปยังพาว",
                    value = 'impound'
                })
                -- table.insert(elements, {
                    -- label = "ยึดรถ",
                    -- value = 'impound_police'
                -- })
            end

            -- table.insert(elements, {
            --     label = _U('search_database'),
            --     value = 'search_database'
            -- })

            ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                             'vehicle_interaction', {
                title = _U('vehicle_interaction'),
                align = 'top-right',
                elements = elements
            }, function(data2, menu2)
                coords = GetEntityCoords(playerPed)
                vehicle = ESX.Game.GetVehicleInDirection()
                action = data2.current.value

                if action == 'search_database' then
                    ESX.UI.Menu.CloseAll()
                    --LookupVehicle()

                elseif DoesEntityExist(vehicle) then
                    local vehicleData = exports.nc_garage:GetVehicleProperties(vehicle)
                    
                    if action == 'vehicle_infos' then
                        OpenVehicleInfosMenu(vehicleData)

                    elseif action == 'hijack_vehicle' then
                        if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z,
                                                 3.0) then
                            TaskStartScenarioInPlace(playerPed,
                                                     "WORLD_HUMAN_WELDING", 0,
                                                     true)
                            Citizen.Wait(20000)
                            ClearPedTasksImmediately(playerPed)

                            SetVehicleDoorsLocked(vehicle, 1)
                            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                            TriggerEvent("pNotify:SendNotification", {
                                text = 'ปลดล็อครถเรียบร้อยแล้ว',
                                type = "success",
                                timeout = 3000,
                                layout = "bottomCenter",
                                queue = "global"
                            })
                            local sendToDiscord = '' ..
                                                      GetPlayerName(PlayerId()) ..
                                                      ' งัดรถ ทะเบียน ' ..
                                                      vehicleData.plate .. ''
                            TriggerServerEvent(
                                'azael_dc-serverlogs:insertData',
                                'PoliceHijack', sendToDiscord,
                                GetPlayerServerId(PlayerId()), '^5')
                        end
                    elseif action == 'impound' then
                        ESX.UI.Menu.CloseAll()
                        TriggerEvent("mythic_progbar:client:progress", {
                            name = "unique_action_name",
                            duration = 3000,
                            label = "ลบรถ",
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            },
                            animation = {
                                animDict = "amb@medic@standing@tendtodead@base",
                                anim = "base",
                            },
                        }, function(status)
                            if not status then
                                ImpoundVehicle(vehicle)
                                local sendToDiscord1 = '' ..GetPlayerName(PlayerId()) ..' ลบรถทะเบียน ' ..vehicleData.plate.. ''
                                TriggerEvent('azael_dc-serverlogs:insertData','PoliceDelVeh', sendToDiscord1, GetPlayerServerId(PlayerId()), '^5')
                            end
                        end)

                        
                        
                    elseif action == 'impound_police' then
                        ESX.UI.Menu.CloseAll()
                        TriggerEvent("mythic_progbar:client:progress", {
                            name = "unique_action_name",
                            duration = 10000,
                            label = "ยึดรถ",
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            },
                            animation = {
                                animDict = "amb@medic@standing@tendtodead@base",
                                anim = "base",
                            },
                        }, function(status)
                            if not status then
                                ImpoundVehiclePolice(vehicle)
                                local sendToDiscord2 = '' ..GetPlayerName(PlayerId()) ..' ยึดรถทะเบียน ' ..vehicleData.plate.. ''
                                TriggerEvent('azael_dc-serverlogs:insertData','PoliceVehseize', sendToDiscord2, GetPlayerServerId(PlayerId()), '^5')
                            end
                        end)
                       
                        
                    end
                else
                    TriggerEvent("pNotify:SendNotification", {
                        text = 'คุณอยู่ไกลจากรถเกินไป',
                        type = "success",
                        timeout = 3000,
                        layout = "bottomCenter",
                        queue = "global"
                    })
                end

            end, function(data2, menu2) menu2.close() end)

        -- elseif data.current.value == 'case_police' then
				-- TriggerEvent('replayx.alertpolice:OpenUi')
				-- ESX.UI.Menu.CloseAll()
        elseif data.current.value == 'object_spawner' then
            ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                             'citizen_interaction', {
                title = _U('traffic_interaction'),
                align = 'top-right',
                elements = {
                    {label = _U('cone'), value = 'prop_roadcone02a'},
                    {label = _U('barrier'), value = 'prop_barrier_work05'},
                    {label = _U('spikestrips'), value = 'p_ld_stinger_s'},
                    {label = _U('box'), value = 'prop_boxpile_07d'},
                    {
                        label = _U('cash'),
                        value = 'hei_prop_cash_crate_half_full'
                    }
                }
            }, function(data2, menu2)
                local model = data2.current.value
                local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
                local forward = GetEntityForwardVector(playerPed)
                local x, y, z = table.unpack(coords + forward * 1.0)

                if model == 'prop_roadcone02a' then z = z - 2.0 end
                TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0,
                             -8.0, -1, 0, 0, false, false, false)
                Citizen.Wait(1000)
                ClearPedTasks(PlayerPedId())
                ESX.Game.SpawnObject(model, {x = x, y = y, z = z}, function(obj)
                    SetEntityHeading(obj, GetEntityHeading(playerPed))
                    PlaceObjectOnGroundProperly(obj)
					FreezeEntityPosition(obj, true)
                end)

            end, function(data2, menu2) menu2.close() end)
        elseif data.current.value == 'jail_fishtank' then
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                TriggerEvent("esx-qalle-jail:openJailFishtank")
            end
        elseif data.current.value == 'setjob' then
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                local elements = {}
                
					table.insert(elements, {label = "นักเรียนตำรวจ", value = '0'})
                    table.insert(elements, {label = "จ่า", value = '1'})
                    table.insert(elements, {label = "หมวด", value = '2'})
                    table.insert(elements, {label = "ผู้กอง", value = '3'})
                    table.insert(elements, {label = "สารวัตร", value = '4'})
                    table.insert(elements, {label = "ผู้กำกับ", value = '5'})
                    table.insert(elements, {label = "รองผบ.ตร", value = '6'})
                
                
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'setjob',
                                 {
                    title = 'Setjob',
                    align = 'top-right',
                    elements = elements
                }, function(data2, menu2)
                    TriggerServerEvent('Bosssetjobpolice:police', GetPlayerServerId(closestPlayer), data2.current.value)
                    menu2.close()
                end, function(data2, menu2) menu2.close() end)
            else
                ESX.ShowNotification(_U('no_players'))
            end

        elseif data.current.value == 'boss_opensafe' then
			OpenGetStocksMenu()
        elseif data.current.value == 'setjobdefault' then
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                
                ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                                'setjobdefalut', {
                    title = 'Setjob',
                    align = 'top-right',
                    elements = {{label = "ประชาชน", value = '0'}}
                }, function(data, menu)
                    TriggerServerEvent('Bosssetjobpolice:unemployed',
                                    GetPlayerServerId(closestPlayer),
                                    data.current.value)
                    menu.close()
                end, function(data, menu) menu.close() end)
            else
                ESX.ShowNotification(_U('no_players'))
            end
        elseif data.current.value == 'curfew' then
            -- TriggerEvent('curfew:start')
            TriggerServerEvent('esx_policejob:ensurecurfew1')
            menu.close()
		elseif data.current.value == 'curfew2' then
            TriggerServerEvent('esx_policejob:ensurecurfew2')
            menu.close()
		elseif data.current.value == 'curfew3' then
            TriggerServerEvent('esx_policejob:ensurecurfew3')
            menu.close()
		elseif data.current.value == 'annPol' then
			AnnoucementPolice()
			menu.close()
        end

    end, function(data, menu) menu.close() end)
end

function OpenBodySearchMenu(player)

	-- TriggerEvent("rdx_mini-inventory:getOtherPlayerInventory", player)
	exports.nc_inventory:SearchInventory(GetPlayerServerId(player), 'police')
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

function AnnoucementPolice()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'Annoucement Police', {
		title = "ประกาศตำรวจ",
	}, function (data2, menu)
		local AnnouceText = data2.value
		
		if AnnouceText == nil then
			TriggerEvent("pNotify:SendNotification", {
                text = "กรุณาใส่รายละเอียดด้วย",
                type = "error",
                timeout = 3000,
                layout = "bottomCenter",
                queue = "global"
            })
		else
			TriggerServerEvent("esx_policejob:sendAnnoucePolice", AnnouceText)
			menu.close()
		end
	
	end, function (data2, menu)
		menu.close()
	end)
end

function OpenFineMenu(player)
    local elements = {}
    table.insert(elements, {label = 'อื่นๆ', value = 'other'})
    -- for k, v in pairs(Config.billpolice) do
        -- local text = ''..k..' ราคา '.. v.cost..' ฿'
        -- table.insert(elements, {label = text, price = v.cost, reason = k})
    -- end
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine', {
        title = _U('fine'),
        align = 'top-right',
        elements = elements
            
    }, function(data, menu)
        
        if data.current.value == 'other' then
            CreateBilling(player)
        else
            TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), '', data.current.reason, tonumber(data.current.price))
			TriggerServerEvent('striker:entrybill', tonumber(data.current.price) * 0.3)
            TriggerEvent("pNotify:SendNotification", {
				text = "สร้างบิล "..data.current.reason.."",
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
        end
        menu.close()
    end, function(data, menu) menu.close() end)

end

function CreateBilling(player)
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'dialog_createbill',
                     {title = "ใส่ชื่อบิล"},
                     function(data, menu)
        -- local length = string.len(data.value)
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
    end, function(data, menu) menu.close() end)
end

function CreateBillingPrice(player, value)
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(),
                     'dialog_createbill_price',
                     {title = "ใส่จำนวนเงิน"},
                     function(data2, menu2)
        -- local length = string.len(data.value)
        if tonumber(data2.value) then
            TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), '', value, tonumber(data2.value))
			TriggerServerEvent('striker:entrybill', tonumber(data2.value) * 0.3)
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
    end, function(data2, menu2) menu2.close() end)
end

function OpenFineCategoryMenu(player, category)

    ESX.TriggerServerCallback('esx_policejob:getFineList', function(fines)

        local elements = {}

        for i = 1, #fines, 1 do
            table.insert(elements, {
                label = fines[i].label .. ' <span class="green-text"">$' ..
                    fines[i].amount .. '</span>',
                value = fines[i].id,
                amount = fines[i].amount,
                fineLabel = fines[i].label
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine_category',
                         {
            title = _U('fine'),
            align = 'top-right',
            elements = elements
        }, function(data, menu)

            local label = data.current.fineLabel
            local amount = data.current.amount

            menu.close()

            if Config.EnablePlayerManagement then
                TriggerServerEvent('esx_billing:sendBill',
                                   GetPlayerServerId(player), 'society_police',
                                   _U('fine_total', label), amount)
            else
                TriggerServerEvent('esx_billing:sendBill',
                                   GetPlayerServerId(player), '',
                                   _U('fine_total', label), amount)
            end

            ESX.SetTimeout(300, function()
                OpenFineCategoryMenu(player, category)
            end)

        end, function(data, menu) menu.close() end)

    end, category)

end

function OpenSearchInfo()
    local elements = {
        {
            label = "ข้อมูลการซื้อรถ",
            value = 'history_vehicle'
        }, {
            label = "ข้อมูลการซื้อบ้าน",
            value = 'history_house'
        }
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'seach_info', {
        title = "ฐานข้อมูล",
        align = 'top-right',
        elements = elements
    }, function(data, menu)

        if data.current.value == 'history_vehicle' then
            SearchHistoryVehicleByName()
        elseif data.current.value == 'history_house' then
            SearchHistoryHouseByName()
        end

    end, function(data, menu)
        menu.close()

        CurrentAction = 'menu_search_actions'
        CurrentActionMsg = 'press ~INPUT_PICKUP~ to open the menu'
        CurrentActionData = {station = station}
    end)
end

function SearchHistoryVehicleByName()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'lookup_vehicle', {
        title = "ตรวจสอบข้อมูลการซื้อรถของประชาชน (ชื่อ นามสกุล)"
    }, function(data, menu)
        -- local length = string.len(data.value)
        if data.value == nil then
            TriggerEvent("pNotify:SendNotification", {
                text = "ชื่อ-นามสกุล ไม่ถูกต้อง",
                type = "success",
                timeout = 3000,
                layout = "bottomCenter",
                queue = "global"
            })
        else
            ESX.TriggerServerCallback('esx_policejob:getVehicleByName',
                                      function(result, found)
                if found then
                    ShowSearchVehicle(result, data.value)
                else
                    TriggerEvent("pNotify:SendNotification", {
                        text = "ไม่พบข้อมูล",
                        type = "success",
                        timeout = 3000,
                        layout = "bottomCenter",
                        queue = "global"
                    })
                end
            end, data.value)
            menu.close()
        end
    end, function(data, menu) menu.close() end)
end

function ShowSearchVehicle(result, name)

    local elements = {}

    for k, v in pairs(result) do
        table.insert(elements, {label = "Plate : " .. v.plate, value = nil})
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                     'vehicle_search_infos', {
        title = 'ข้อมูลรถของ ' .. name,
        align = 'top-right',
        elements = elements
    }, nil, function(data, menu) menu.close() end)

end

function SearchHistoryHouseByName()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'lookup_vehicle', {
        title = "ตรวจสอบข้อมูลการซื้อบ้านของประชาชน (ชื่อ นามสกุล)"
    }, function(data, menu)
        -- local length = string.len(data.value)
        if data.value == nil then
            TriggerEvent("pNotify:SendNotification", {
                text = "ชื่อ-นามสกุล ไม่ถูกต้อง",
                type = "success",
                timeout = 3000,
                layout = "bottomCenter",
                queue = "global"
            })
        else
            ESX.TriggerServerCallback('esx_policejob:getHouseByName',
                                      function(result, found)
                if found then
                    ShowSearchHouse(result, data.value)
                else
                    TriggerEvent("pNotify:SendNotification", {
                        text = "ไม่พบข้อมูล",
                        type = "success",
                        timeout = 3000,
                        layout = "bottomCenter",
                        queue = "global"
                    })
                end
            end, data.value)
            menu.close()
        end
    end, function(data, menu) menu.close() end)
end

function ShowSearchHouse(result, name)

    local elements = {}

    for k, v in pairs(result) do
        table.insert(elements,
                     {label = "บ้าน : " .. v.name, value = nil})
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                     'vehicle_search_infos', {
        title = 'ข้อมูลบ้านของ ' .. name,
        align = 'top-right',
        elements = elements
    }, nil, function(data, menu) menu.close() end)

end


function ShowPlayerLicense(player)
    local elements = {}
    local targetName
    ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData',
                              function(data)
        if data.licenses then
            for i = 1, #data.licenses, 1 do
                if data.licenses[i].label and data.licenses[i].type then
                    table.insert(elements, {
                        label = data.licenses[i].label,
                        type = data.licenses[i].type
                    })
                end
            end
        end

        if Config.EnableESXIdentity then
            targetName = data.firstname .. ' ' .. data.lastname
        else
            targetName = data.name
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_license',
                         {
            title = _U('license_revoke'),
            align = 'top-right',
            elements = elements
        }, function(data, menu)
            TriggerEvent("pNotify:SendNotification", {
                text = 'คุณเพิกถอน ' ..
                    data.current.label ..
                    ' ซึ่งเป็นของ ' ..
                    targetName .. '',
                type = "success",
                timeout = 3000,
                layout = "bottomCenter",
                queue = "global"
            })
            TriggerServerEvent('esx_policejob:message',
                               GetPlayerServerId(player),
                               _U('license_revoked', data.current.label))

            TriggerServerEvent('esx_license:removeLicense',
                               GetPlayerServerId(player), data.current.type)

            ESX.SetTimeout(300, function() ShowPlayerLicense(player) end)
        end, function(data, menu) menu.close() end)

    end, GetPlayerServerId(player))
end



function OpenVehicleInfosMenu(vehicleData)

    ESX.TriggerServerCallback('esx_policejob:getVehicleInfos',
                              function(retrivedInfo)

        local elements = {}

        table.insert(elements,
                     {label = _U('plate', retrivedInfo.plate), value = nil})

        if retrivedInfo.owner == nil then
            table.insert(elements, {label = _U('owner_unknown'), value = nil})
        else
            table.insert(elements,
                         {label = _U('owner', retrivedInfo.owner), value = nil})
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_infos',
                         {
            title = _U('vehicle_info'),
            align = 'top-right',
            elements = elements
        }, nil, function(data, menu) menu.close() end)

    end, vehicleData.plate)

end

function OpenGetWeaponMenu()

    ESX.TriggerServerCallback('esx_policejob:getArmoryWeapons',
                              function(weapons)
        local elements = {}

        for i = 1, #weapons, 1 do
            if weapons[i].count > 0 then
                table.insert(elements, {
                    label = 'x' .. weapons[i].count .. ' ' ..
                        ESX.GetWeaponLabel(weapons[i].name),
                    value = weapons[i].name
                })
            end
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                         'armory_get_weapon', {
            title = _U('get_weapon_menu'),
            align = 'top-right',
            elements = elements
        }, function(data, menu)

            menu.close()

            ESX.TriggerServerCallback('esx_policejob:removeArmoryWeapon',
                                      function() OpenGetWeaponMenu() end,
                                      data.current.value)

        end, function(data, menu) menu.close() end)
    end)

end

function OpenPutWeaponMenu()
    local elements = {}
    local playerPed = PlayerPedId()
    local weaponList = ESX.GetWeaponList()

    for i = 1, #weaponList, 1 do
        local weaponHash = GetHashKey(weaponList[i].name)

        if HasPedGotWeapon(playerPed, weaponHash, false) and weaponList[i].name ~=
            'WEAPON_UNARMED' then
            table.insert(elements, {
                label = weaponList[i].label,
                value = weaponList[i].name
            })
        end
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_put_weapon',
                     {
        title = _U('put_weapon_menu'),
        align = 'top-right',
        elements = elements
    }, function(data, menu)

        menu.close()

        ESX.TriggerServerCallback('esx_policejob:addArmoryWeapon',
                                  function() OpenPutWeaponMenu() end,
                                  data.current.value, true)

    end, function(data, menu) menu.close() end)
end

function OpenBuyWeaponsMenu()

    local elements = {}
    local playerPed = PlayerPedId()

    for k, v in ipairs(Config.AuthorizedWeapons[ESX.PlayerData.job.grade_name]) do
        local weaponNum, weapon = ESX.GetWeapon(v.weapon)
        local components, label = {}

        local hasWeapon =
            HasPedGotWeapon(playerPed, GetHashKey(v.weapon), false)

        if v.components then
            for i = 1, #v.components do
                if v.components[i] then

                    local component = weapon.components[i]
                    local hasComponent =
                        HasPedGotWeaponComponent(playerPed,GetHashKey(v.weapon),component.hash)

                    if hasComponent then
                        label = ('%s: <span class="green-text">%s</span>'):format(component.label, _U('armory_owned'))
                    else
                        if v.components[i] > 0 then
                            label = ('%s: <span class="green-text">%s</span>'):format(component.label, _U('armory_item', ESX.Math.GroupDigits(v.components[i])))
                        else
                            label =('%s: <span class="green-text">%s</span>'):format(component.label, _U('armory_free'))
                        end
                    end

                    table.insert(components, {
                        label = label,
                        componentLabel = component.label,
                        hash = component.hash,
                        name = component.name,
                        price = v.components[i],
                        hasComponent = hasComponent,
                        componentNum = i
                    })
                end
            end
        end

        if hasWeapon and v.components then
            label = ('%s: <span class="green-text">></span>'):format(weapon.label)
        elseif hasWeapon and not v.components then
            label = ('%s: <span class="green-text">%s</span>'):format(weapon.label, _U('armory_owned'))
        else
			if v.price > 0 then
				-- label = ('%s: <span class="green-text">%s</span>'):format(weapon.label, _U('armory_item', ESX.Math.GroupDigits(v.price)))
				label = ('%s: <span class="green-text">%s</span>'):format(weapon.label, ESX.Math.GroupDigits(v.price) .. "$ [ " .. ESX.Math.GroupDigits(v.items) .. " Coins ]")
			else
                -- label = ('%s: <span class="green-text">%s</span>'):format(weapon.label, _U('armory_free'))
				label = ('%s: <span class="green-text">%s</span>'):format(weapon.label, 'Free' .. " [ " .. ESX.Math.GroupDigits(v.items) .. " Coins ]")
            end
        end

        table.insert(elements, {
            label = label,
            weaponLabel = weapon.label,
            name = weapon.name,
            components = components,
            price = v.price,
            items = v.items,
            hasWeapon = hasWeapon
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_buy_weapons',
                     {
        title = 'คลังแสง - ซื้ออาวุธ',
        align = 'top-right',
        elements = elements
    }, function(data, menu)

        if data.current.hasWeapon then
            if #data.current.components > 0 then
                OpenWeaponComponentShop(data.current.components,
                                        data.current.name, menu)
            end
        else
            ESX.TriggerServerCallback('esx_policejob:buyWeapon',
                                      function(bought)
                if bought then
                    if data.current.price > 0 then
                        TriggerEvent("pNotify:SendNotification", {
                            text = 'คุณซื้อ ' ..
                                data.current.weaponLabel ..
                                ' ราคา $' ..
                                ESX.Math.GroupDigits(data.current.price) ..
                                '',
                            type = "success",
                            timeout = 3000,
                            layout = "bottomCenter",
                            queue = "global"
                        })
                    end

                    menu.close()

                    OpenBuyWeaponsMenu()
                else
                    TriggerEvent("pNotify:SendNotification", {
                        text = 'คุณมีเงินไม่เพียงพอ',
                        type = "success",
                        timeout = 3000,
                        layout = "bottomCenter",
                        queue = "global"
                    })
                end
            end, data.current.name, 1)
        end

    end, function(data, menu) menu.close() end)

end

function OpenWeaponComponentShop(components, weaponName, parentShop)
    ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                     'armory_buy_weapons_components', {
        title = 'คลังแสง - ตกแต่งอาวุธ',
        align = 'top-right',
        elements = components
    }, function(data, menu)

        if data.current.hasComponent then
            TriggerEvent("pNotify:SendNotification", {
                text = 'แต่งอุปกรณ์ปืนเรียบร้อยแล้ว',
                type = "success",
                timeout = 3000,
                layout = "bottomCenter",
                queue = "global"
            })
        else
            ESX.TriggerServerCallback('esx_policejob:buyWeapon',
                                      function(bought)
                if bought then
                    if data.current.price > 0 then
                        TriggerEvent("pNotify:SendNotification", {
                            text = 'คุณซื้อ ' ..
                                data.current.componentLabel ..
                                ' ราคา $' ..
                                ESX.Math.GroupDigits(data.current.price) ..
                                '',
                            type = "success",
                            timeout = 3000,
                            layout = "bottomCenter",
                            queue = "global"
                        })
                    end

                    menu.close()
                    parentShop.close()

                    OpenBuyWeaponsMenu()
                else
                    TriggerEvent("pNotify:SendNotification", {
                        text = 'คุณมีเงินไม่เพียงพอ',
                        type = "success",
                        timeout = 3000,
                        layout = "bottomCenter",
                        queue = "global"
                    })
                end
            end, weaponName, 2, data.current.componentNum)
        end

    end, function(data, menu) menu.close() end)
end

function OpenGetStocksMenu()

    ESX.TriggerServerCallback('esx_policejob:getStockItems', function(items)

        local elements = {}

        for i = 1, #items, 1 do
            table.insert(elements, {
                -- label = 'x' .. items[i].count .. ' ' .. items[i].label,
                label = 'x' .. items[i].count .. ' ' .. items[i].name,
                value = items[i].name
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
            title = _U('police_stock'),
            align = 'top-right',
            elements = elements
        }, function(data, menu)

            local itemName = data.current.value

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(),
                             'stocks_menu_get_item_count',
                             {title = _U('quantity')}, function(data2, menu2)

                local count = tonumber(data2.value)

                if count == nil then
                    TriggerEvent("pNotify:SendNotification", {
                        text = 'ปริมาณที่ไม่ถูกต้อง',
                        type = "success",
                        timeout = 3000,
                        layout = "bottomCenter",
                        queue = "global"
                    })
                else
                    menu2.close()
                    menu.close()
                    TriggerServerEvent('esx_policejob:getStockItem', itemName,
                                       count)

                    Citizen.Wait(300)
                    OpenGetStocksMenu()
                end

            end, function(data2, menu2) menu2.close() end)

        end, function(data, menu) menu.close() end)

    end)

end

function OpenPutStocksMenu()

    ESX.TriggerServerCallback('esx_policejob:getPlayerInventory',
                              function(inventory)

        local elements = {}

        for i = 1, #inventory.items, 1 do
            local item = inventory.items[i]

            if item.count > 0 then
                table.insert(elements, {
                    label = item.label .. ' x' .. item.count,
                    type = 'item_standard',
                    value = item.name
                })
            end
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
            title = _U('inventory'),
            align = 'top-right',
            elements = elements
        }, function(data, menu)

            local itemName = data.current.value

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(),
                             'stocks_menu_put_item_count',
                             {title = _U('quantity')}, function(data2, menu2)

                local count = tonumber(data2.value)

                if count == nil then
                    TriggerEvent("pNotify:SendNotification", {
                        text = 'ปริมาณที่ไม่ถูกต้อง',
                        type = "success",
                        timeout = 3000,
                        layout = "bottomCenter",
                        queue = "global"
                    })
                else
                    menu2.close()
                    menu.close()
                    TriggerServerEvent('esx_policejob:putStockItems', itemName, count)

                    Citizen.Wait(300)
                    OpenPutStocksMenu()
                end

            end, function(data2, menu2) menu2.close() end)

        end, function(data, menu) menu.close() end)
    end)

end


RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
    local specialContact = {
        name = _U('phone_police'),
        number = 'police',
        base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NDFGQTJDRkI0QUJCMTFFN0JBNkQ5OENBMUI4QUEzM0YiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NDFGQTJDRkM0QUJCMTFFN0JBNkQ5OENBMUI4QUEzM0YiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo0MUZBMkNGOTRBQkIxMUU3QkE2RDk4Q0ExQjhBQTMzRiIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo0MUZBMkNGQTRBQkIxMUU3QkE2RDk4Q0ExQjhBQTMzRiIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PoW66EYAAAjGSURBVHjapJcLcFTVGcd/u3cfSXaTLEk2j80TCI8ECI9ABCyoiBqhBVQqVG2ppVKBQqUVgUl5OU7HKqNOHUHU0oHamZZWoGkVS6cWAR2JPJuAQBPy2ISEvLN57+v2u2E33e4k6Ngz85+9d++95/zP9/h/39GpqsqiRYsIGz8QZAq28/8PRfC+4HT4fMXFxeiH+GC54NeCbYLLATLpYe/ECx4VnBTsF0wWhM6lXY8VbBE0Ch4IzLcpfDFD2P1TgrdC7nMCZLRxQ9AkiAkQCn77DcH3BC2COoFRkCSIG2JzLwqiQi0RSmCD4JXbmNKh0+kc/X19tLtc9Ll9sk9ZS1yoU71YIk3xsbEx8QaDEc2ttxmaJSKC1ggSKBK8MKwTFQVXRzs3WzpJGjmZgvxcMpMtWIwqsjztvSrlzjYul56jp+46qSmJmMwR+P3+4aZ8TtCprRkk0DvUW7JjmV6lsqoKW/pU1q9YQOE4Nxkx4ladE7zd8ivuVmJQfXZKW5dx5EwPRw4fxNx2g5SUVLw+33AkzoRaQDP9SkFu6OKqz0uF8yaz7vsOL6ycQVLkcSg/BlWNsjuFoKE1knqDSl5aNnmPLmThrE0UvXqQqvJPyMrMGorEHwQfEha57/3P7mXS684GFjy8kreLppPUuBXfyd/ibeoS2kb0mWPANhJdYjb61AxUvx5PdT3+4y+Tb3mTd19ZSebE+VTXVGNQlHAC7w4VhH8TbA36vKq6ilnzlvPSunHw6Trc7XpZ14AyfgYeyz18crGN1Alz6e3qwNNQSv4dZox1h/BW9+O7eIaEsVv41Y4XeHJDG83Nl4mLTwzGhJYtx0PzNTjOB9KMTlc7Nkcem39YAGU7cbeBKVLMPGMVf296nMd2VbBq1wmizHoqqm/wrS1/Zf0+N19YN2PIu1fcIda4Vk66Zx/rVi+jo9eIX9wZGGcFXUMR6BHUa76/2ezioYcXMtpyAl91DSaTfDxlJbtLprHm2ecpObqPuTPzSNV9yKz4a4zJSuLo71/j8Q17ON69EmXiPIlNMe6FoyzOqWPW/MU03Lw5EFcyKghTrNDh7+/vw545mcJcWbTiGKpRdGPMXbx90sGmDaux6sXk+kimjU+BjnMkx3kYP34cXrFuZ+3nrHi6iDMt92JITcPjk3R3naRwZhpuNSqoD93DKaFVU7j2dhcF8+YzNlpErbIBTVh8toVccbaysPB+4pMcuPw25kwSsau7BIlmHpy3guaOPtISYyi/UkaJM5Lpc5agq5Xkcl6gIHkmqaMn0dtylcjIyPThCNyhaXyfR2W0I1our0v6qBii07ih5rDtGSOxNVdk1y4R2SR8jR/g7hQD9l1jUeY/WLJB5m39AlZN4GZyIQ1fFJNsEgt0duBIc5GRkcZF53mNwIzhXPDgQPoZIkiMkbTxtstDMVnmFA4cOsbz2/aKjSQjev4Mp9ZAg+hIpFhB3EH5Yal16+X+Kq3dGfxkzRY+KauBjBzREvGN0kNCTARu94AejBLMHorAQ7cEQMGs2cXvkWshYLDi6e9l728O8P1XW6hKeB2yv42q18tjj+iFTGoSi+X9jJM9RTxS9E+OHT0krhNiZqlbqraoT7RAU5bBGrEknEBhgJks7KXbLS8qERI0ErVqF/Y4K6NHZfLZB+/wzJvncacvFd91oXO3o/O40MfZKJOKu/rne+mRQByXM4lYreb1tUnkizVVA/0SpfpbWaCNBeEE5gb/UH19NLqEgDF+oNDQWcn41Cj0EXFEWqzkOIyYekslFkThsvMxpIyE2hIc6lXGZ6cPyK7Nnk5OipixRdxgUESAYmhq68VsGgy5CYKCUAJTg0+izApXne3CJFmUTwg4L3FProFxU+6krqmXu3MskkhSD2av41jLdzlnfFrSdCZxyqfMnppN6ZUa7pwt0h3fiK9DCt4IO9e7YqisvI7VYgmNv7mhBKKD/9psNi5dOMv5ZjukjsLdr0ffWsyTi6eSlfcA+dmiVyOXs+/sHNZu3M6PdxzgVO9GmDSHsSNqmTz/R6y6Xxqma4fwaS5Mn85n1ZE0Vl3CHBER3lUNEhiURpPJRFdTOcVnpUJnPIhR7cZXfoH5UYc5+E4RzRH3sfSnl9m2dSMjE+Tz9msse+o5dr7UwcQ5T3HwlWUkNuzG3dKFSTbsNs7m/Y8vExOlC29UWkMJlAxKoRQMR3IC7x85zOn6fHS50+U/2Untx2R1voinu5no+DQmz7yPXmMKZnsu0wrm0Oe3YhOVHdm8A09dBQYhTv4T7C+xUPrZh8Qn2MMr4qcDSRfoirWgKAvtgOpv1JI8Zi77X15G7L+fxeOUOiUFxZiULD5fSlNzNM62W+k1yq5gjajGX/ZHvOIyxd+Fkj+P092rWP/si0Qr7VisMaEWuCiYonXFwbAUTWWPYLV245NITnGkUXnpI9butLJn2y6iba+hlp7C09qBcvoN7FYL9mhxo1/y/LoEXK8Pv6qIC8WbBY/xr9YlPLf9dZT+OqKTUwfmDBm/GOw7ws4FWpuUP2gJEZvKqmocuXPZuWYJMzKuSsH+SNwh3bo0p6hao6HeEqwYEZ2M6aKWd3PwTCy7du/D0F1DsmzE6/WGLr5LsDF4LggnYBacCOboQLHQ3FFfR58SR+HCR1iQH8ukhA5s5o5AYZMwUqOp74nl8xvRHDlRTsnxYpJsUjtsceHt2C8Fm0MPJrphTkZvBc4It9RKLOFx91Pf0Igu0k7W2MmkOewS2QYJUJVWVz9VNbXUVVwkyuAmKTFJayrDo/4Jwe/CT0aGYTrWVYEeUfsgXssMRcpyenraQJa0VX9O3ZU+Ma1fax4xGxUsUVFkOUbcama1hf+7+LmA9juHWshwmwOE1iMmCFYEzg1jtIm1BaxW6wCGGoFdewPfvyE4ertTiv4rHC73B855dwp2a23bbd4tC1hvhOCbX7b4VyUQKhxrtSOaYKngasizvwi0RmOS4O1QZf2yYfiaR+73AvhTQEVf+rpn9/8IMAChKDrDzfsdIQAAAABJRU5ErkJggg=='
    }

    TriggerEvent('esx_phone:addSpecialContact', specialContact.name,
                 specialContact.number, specialContact.base64Icon)
end)

-- don't show dispatches if the player isn't in service
AddEventHandler('esx_phone:cancelMessage', function(dispatchNumber)
    if type(ESX.PlayerData.job.name) == 'string' and ESX.PlayerData.job.name == 'police' and
        ESX.PlayerData.job.name == dispatchNumber then
        -- if esx_service is enabled
        if Config.MaxInService ~= -1 and not playerInService then
            CancelEvent()
        end
    end
end)

AddEventHandler('esx_policejob:hasEnteredMarker',
                function(station, part, partNum)

    if part == 'Cloakroom' then
        CurrentAction = 'menu_cloakroom'
        CurrentActionMsg = _U('open_cloackroom')
        CurrentActionData = {}

    elseif part == 'Armory' then

        CurrentAction = 'menu_armory'
        CurrentActionMsg = _U('open_armory')
        CurrentActionData = {station = station}

    elseif part == 'Vehicles' then

        CurrentAction = 'menu_vehicle_spawner'
        CurrentActionMsg = _U('garage_prompt')
        CurrentActionData = {station = station, part = part, partNum = partNum}

    elseif part == 'Helicopters' then

        CurrentAction = 'Helicopters'
        CurrentActionMsg = _U('helicopter_prompt')
        CurrentActionData = {station = station, part = part, partNum = partNum}


    end

end)

AddEventHandler('esx_policejob:hasExitedMarker',
                function(station, part, partNum)
    if not isInShopMenu then ESX.UI.Menu.CloseAll() end

    CurrentAction = nil
end)

AddEventHandler('esx_policejob:hasEnteredEntityZone', function(entity)
    local playerPed = PlayerPedId()

    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'police' and
        IsPedOnFoot(playerPed) then
        CurrentAction = 'remove_entity'
        CurrentActionMsg = _U('remove_prop')
        CurrentActionData = {entity = entity}
    end

    if GetEntityModel(entity) == GetHashKey('p_ld_stinger_s') then
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed)

            SetVehicleTyreBurst(vehicle, 0, true, 1000.0)
            SetVehicleTyreBurst(vehicle, 1, true, 1000.0)
            Citizen.Wait(200)
            SetVehicleTyreBurst(vehicle, 2, true, 1000.0)
            SetVehicleTyreBurst(vehicle, 3, true, 1000.0)
            Citizen.Wait(200)
            SetVehicleTyreBurst(vehicle, 4, true, 1000.0)
            SetVehicleTyreBurst(vehicle, 5, true, 1000.0)
            SetVehicleTyreBurst(vehicle, 6, true, 1000.0)
            SetVehicleTyreBurst(vehicle, 7, true, 1000.0)

            -- for i=0, 7, 1 do
            --	SetVehicleTyreBurst(vehicle, i, true, 1000)
            -- end
        end
    end
end)

AddEventHandler('esx_policejob:hasExitedEntityZone', function(entity)
    if CurrentAction == 'remove_entity' then CurrentAction = nil end
end)

RegisterNetEvent('esx_policejob:getarrested')
AddEventHandler('esx_policejob:getarrested',
                function(playerheading, playercoords, playerlocation)
    playerPed = GetPlayerPed(-1)
    local x, y, z = table.unpack(playercoords + playerlocation * 1.0)
    SetEntityCoords(GetPlayerPed(-1), x, y, z)
    SetEntityHeading(GetPlayerPed(-1), playerheading)
    Citizen.Wait(250)
    ESX.Streaming.RequestAnimDict("mp_arrest_paired", function()
        TaskPlayAnim(GetPlayerPed(-1), 'mp_arrest_paired',
                     'crook_p2_back_right', 8.0, -8, 3750, 2, 0, 0, 0, 0)
        Citizen.Wait(3060)
        TriggerEvent("esx_policejob:handcuff")
    end)

end)


RegisterNetEvent('esx_policejob:douncuffing')
AddEventHandler('esx_policejob:douncuffing', function()
    Citizen.Wait(250)
    ESX.Streaming.RequestAnimDict("mp_arresting", function()
        TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'a_uncuff', 8.0, -8,
                     3750, 2, 0, 0, 0, 0)
    end)
    Citizen.Wait(5500)
    ClearPedTasks(GetPlayerPed(-1))
end)

RegisterNetEvent('esx_policejob:getuncuffed')
AddEventHandler('esx_policejob:getuncuffed',
                function(playerheading, playercoords, playerlocation)
    local x, y, z = table.unpack(playercoords + playerlocation * 1.0)
    SetEntityCoords(GetPlayerPed(-1), x, y, z)
    SetEntityHeading(GetPlayerPed(-1), playerheading)
    Citizen.Wait(250)
    ESX.Streaming.RequestAnimDict("mp_arresting", function()
        TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'b_uncuff', 8.0, -8,
                     3750, 2, 0, 0, 0, 0)
        Citizen.Wait(3000)
        TriggerEvent("esx_policejob:handcuff")
    end)

end)

RegisterNetEvent('esx_policejob:doarrested')
AddEventHandler('esx_policejob:doarrested', function()
    Citizen.Wait(250)
    ESX.Streaming.RequestAnimDict("mp_arrest_paired", function()
        TaskPlayAnim(GetPlayerPed(-1), 'mp_arrest_paired', 'cop_p2_back_right',
                     8.0, -8, 3750, 2, 0, 0, 0, 0)
    end)
    Citizen.Wait(3000)
end)


-- RegisterCommand('ttt', function()
    -- TriggerServerEvent('award:addcaraward')
	-- OpenGetStocksMenu()
-- end)

-- RegisterCommand('wwww', function()
   -- TriggerServerEvent('esx_policejob:putStockItems', 'water', 1)
-- end)



RegisterNetEvent('esx_policejob:handcuff')
AddEventHandler('esx_policejob:handcuff', function()
    IsHandcuffed = not IsHandcuffed
    local playerPed = PlayerPedId()
	
	TriggerEvent('CarryPeople:cl_stop')	

    Citizen.CreateThread(function()

        if IsHandcuffed then

            SetEnableHandcuffs(playerPed, true)
            DisablePlayerFiring(playerPed, true)
            SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
            SetPedCanPlayGestureAnims(playerPed, false)
            -- FreezeEntityPosition(playerPed, true)
            DisableControlAction(0, Keys['M'], true)
            DisplayRadar(false)

            if Config.EnableHandcuffTimer then

                if HandcuffTimer.Active then
                    ESX.ClearTimeout(HandcuffTimer.Task)
                end

                StartHandcuffTimer()
            end

        else

            if Config.EnableHandcuffTimer and HandcuffTimer.Active then
                ESX.ClearTimeout(HandcuffTimer.Task)
            end

            ClearPedSecondaryTask(playerPed)
            SetEnableHandcuffs(playerPed, false)
            DisablePlayerFiring(playerPed, false)
            SetPedCanPlayGestureAnims(playerPed, true)
            FreezeEntityPosition(playerPed, false)
            DisplayRadar(true)
        end
    end)

end)

RegisterNetEvent('esx_policejob:unrestrain')
AddEventHandler('esx_policejob:unrestrain', function()
    if IsHandcuffed then
        local playerPed = PlayerPedId()
        IsHandcuffed = false

        ClearPedSecondaryTask(playerPed)
        SetEnableHandcuffs(playerPed, false)
        DisablePlayerFiring(playerPed, false)
        SetPedCanPlayGestureAnims(playerPed, true)
        FreezeEntityPosition(playerPed, false)
        DisplayRadar(true)

        -- end timer
        if Config.EnableHandcuffTimer and HandcuffTimer.Active then
            ESX.ClearTimeout(HandcuffTimer.Task)
        end
    end
end)

RegisterNetEvent('esx_policejob:drag')
AddEventHandler('esx_policejob:drag', function(copID)
    if not IsHandcuffed then 
		return 
	end

    DragStatus.IsDragged = not DragStatus.IsDragged
    DragStatus.CopId = tonumber(copID)
end)

Citizen.CreateThread(function()

    ObjectName = GetHashKey("prop_gas_pump_1b")
    RequestModel(ObjectName)
    while not HasModelLoaded(ObjectName) do Wait(1) end

    local object = CreateObject(ObjectName, 442.05, -1014.26, 27.64, false,
                                false, true)
    PlaceObjectOnGroundProperly(object)
    FreezeEntityPosition(object, true)

    local playerPed
    local targetPed

    while true do
        sleephd = 1000

        if IsHandcuffed then sleephd = 5
            playerPed = PlayerPedId()

            if DragStatus.IsDragged then
                targetPed =
                    GetPlayerPed(GetPlayerFromServerId(DragStatus.CopId))

                -- undrag if target is in an vehicle
                if not IsPedSittingInAnyVehicle(targetPed) then
                    AttachEntityToEntity(playerPed, targetPed, 11816, 0.54,
                                         0.54, 0.0, 0.0, 0.0, 0.0, false, false,
                                         false, false, 2, true)
                else
                    DragStatus.IsDragged = false
                    DetachEntity(playerPed, true, false)
                end

                if IsPedDeadOrDying(targetPed, true) then
                    DragStatus.IsDragged = false
                    DetachEntity(playerPed, true, false)
                end

            else
                DetachEntity(playerPed, true, false)
            end
        end
		Citizen.Wait(sleephd)
    end
end)

RegisterNetEvent('esx_policejob:putInVehicle')
AddEventHandler('esx_policejob:putInVehicle', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    if not IsHandcuffed then return end

    if IsAnyVehicleNearPoint(coords, 5.0) then
        local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

        if DoesEntityExist(vehicle) then
            local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

            for i = maxSeats - 1, 0, -1 do
                if IsVehicleSeatFree(vehicle, i) then
                    freeSeat = i
                    break
                end
            end

            if freeSeat then
                TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
                DragStatus.IsDragged = false
            end
        end
    end
end)

RegisterNetEvent('esx_policejob:OutVehicle')
AddEventHandler('esx_policejob:OutVehicle', function()
    local playerPed = PlayerPedId()

    if not IsPedSittingInAnyVehicle(playerPed) then return end

    local vehicle = GetVehiclePedIsIn(playerPed, false)
    TaskLeaveVehicle(playerPed, vehicle, 16)
end)

-- Handcuff
Citizen.CreateThread(function()
    while true do
        local blcokhandsleep = 1000
        local playerPed = PlayerPedId()

        if IsHandcuffed then blcokhandsleep = 1
            DisableControlAction(0, 1, true) -- Disable pan
            DisableControlAction(0, 2, true) -- Disable tilt
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 263, true) -- Melee Attack 1
            -- DisableControlAction(0, Keys['W'], true) -- W
            -- DisableControlAction(0, Keys['A'], true) -- A
            -- DisableControlAction(0, 31, true) -- S 
            -- DisableControlAction(0, 30, true) -- D 

            DisableControlAction(0, Keys['R'], true) -- Reload
            DisableControlAction(0, Keys['SPACE'], true) -- Jump
            DisableControlAction(0, Keys['Q'], true) -- Cover
            DisableControlAction(0, Keys['TAB'], true) -- Select Weapon
            DisableControlAction(0, Keys['F'], true) -- Also 'enter'?

            DisableControlAction(0, Keys['F1'], true) -- Disable phone
            DisableControlAction(0, Keys['F9'], true) -- Disable phone
            DisableControlAction(0, Keys['F5'], true) -- Disable phone
            DisableControlAction(0, Keys['F2'], true) -- Inventory
            DisableControlAction(0, Keys['F3'], true) -- Animations
            DisableControlAction(0, Keys['F6'], true) -- Job
            DisableControlAction(2, Keys['F4'], true) -- Disable QUiT
            DisableControlAction(2, Keys['ALT'], true) -- Disable QUiT
            DisableControlAction(2, Keys['F10'], true)

            DisableControlAction(0, Keys['V'], true) -- Disable changing view
            DisableControlAction(0, Keys['C'], true) -- Disable looking behind
            DisableControlAction(0, Keys['X'], true) -- Disable clearing animation
            DisableControlAction(2, Keys['P'], true) -- Disable pause screen
            DisableControlAction(2, Keys['Y'], true) -- Disable pause screen
            DisableControlAction(2, Keys['T'], true) -- Disable pause screen
            DisableControlAction(0, Keys['M'], true) -- Phone
            -- DisableControlAction(0, 59, true) -- D
            -- DisableControlAction(0, 71, true) -- W
            -- DisableControlAction(0, 72, true) -- S

            DisableControlAction(2, Keys['LEFTCTRL'], true) -- Disable going stealth

            DisableControlAction(0, 47, true) -- Disable weapon
            DisableControlAction(0, 264, true) -- Disable melee
            DisableControlAction(0, 257, true) -- Disable melee
            DisableControlAction(0, 140, true) -- Disable melee
            DisableControlAction(0, 141, true) -- Disable melee
            DisableControlAction(0, 142, true) -- Disable melee
            DisableControlAction(0, 143, true) -- SPACEBAR
            DisableControlAction(0, 75, true) -- Disable exit vehicle
            DisableControlAction(27, 75, true) -- Disable exit vehicle

            if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 then
                ESX.Streaming.RequestAnimDict('mp_arresting', function()
                    TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1,
                                 49, 0.0, false, false, false)
                end)
            end
        else
            Citizen.Wait(500)
        end
		Citizen.Wait(blcokhandsleep)
    end
end)

-- Create blips
Citizen.CreateThread(function()

    for k, v in pairs(Config.PoliceStations) do
        local blip = AddBlipForCoord(v.Blip.Coords)

        SetBlipSprite(blip, v.Blip.Sprite)
        SetBlipDisplay(blip, v.Blip.Display)
        SetBlipScale(blip, v.Blip.Scale)
        SetBlipColour(blip, v.Blip.Colour)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(_U('map_blip'))
        EndTextCommandSetBlipName(blip)
    end

end)

-- Display markers
Citizen.CreateThread(function()
    while true do
        SleepMarker = 1000
		
        if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'police' then SleepMarker = 7

            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local isInMarker, hasExited, letSleep = false, false, true
            local currentStation, currentPart, currentPartNum

            for k, v in pairs(Config.PoliceStations) do

                for i = 1, #v.Cloakrooms, 1 do
                    local distance = GetDistanceBetweenCoords(coords,
                                                              v.Cloakrooms[i],
                                                              true)

                    if distance < Config.DrawDistance then
                        DrawMarker(20, v.Cloakrooms[i], 0.0, 0.0, 0.0, 0, 0.0,
                                   0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r,
                                   Config.MarkerColor.g, Config.MarkerColor.b,
                                   100, false, true, 2, true, false, false,
                                   false)
                        letSleep = false
                    end

                    if distance < Config.MarkerSize.x then
                        isInMarker, currentStation, currentPart, currentPartNum =
                            true, k, 'Cloakroom', i
                    end
                end

                for i = 1, #v.Armories, 1 do
                    local distance = GetDistanceBetweenCoords(coords,
                                                              v.Armories[i],
                                                              true)

                    if distance < Config.DrawDistance then
                        DrawMarker(21, v.Armories[i], 0.0, 0.0, 0.0, 0.0, 0.0,
                                   0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r,
                                   Config.MarkerColor.g, Config.MarkerColor.b,
                                   100, false, true, 2, true, false, false,
                                   false)
                        letSleep = false
                    end

                    if distance < Config.MarkerSize.x then
                        isInMarker, currentStation, currentPart, currentPartNum =
                            true, k, 'Armory', i
                    end
                end

                for i = 1, #v.Vehicles, 1 do
                    local distance = GetDistanceBetweenCoords(coords,
                                                              v.Vehicles[i]
                                                                  .Spawner, true)

                    if distance < Config.DrawDistance then
                        DrawMarker(36, v.Vehicles[i].Spawner, 0.0, 0.0, 0.0,
                                   0.0, 0.0, 0.0, 1.0, 1.0, 1.0,
                                   Config.MarkerColor.r, Config.MarkerColor.g,
                                   Config.MarkerColor.b, 100, false, true, 2,
                                   true, false, false, false)
                        letSleep = false
                    end

                    if distance < Config.MarkerSize.x then
                        isInMarker, currentStation, currentPart, currentPartNum =
                            true, k, 'Vehicles', i
                    end
                end

                for i = 1, #v.Helicopters, 1 do
                    local distance = GetDistanceBetweenCoords(coords,
                                                              v.Helicopters[i]
                                                                  .Spawner, true)

                    if distance < Config.DrawDistance then
                        DrawMarker(34, v.Helicopters[i].Spawner, 0.0, 0.0, 0.0,
                                   0.0, 0.0, 0.0, 1.0, 1.0, 1.0,
                                   Config.MarkerColor.r, Config.MarkerColor.g,
                                   Config.MarkerColor.b, 100, false, true, 2,
                                   true, false, false, false)
                        letSleep = false
                    end

                    if distance < Config.MarkerSize.x then
                        isInMarker, currentStation, currentPart, currentPartNum =
                            true, k, 'Helicopters', i
                    end
                end

               

            end

            if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and
                (LastStation ~= currentStation or LastPart ~= currentPart or
                    LastPartNum ~= currentPartNum)) then

                if (LastStation ~= nil and LastPart ~= nil and LastPartNum ~=
                    nil) and
                    (LastStation ~= currentStation or LastPart ~= currentPart or
                        LastPartNum ~= currentPartNum) then
                    TriggerEvent('esx_policejob:hasExitedMarker', LastStation,
                                 LastPart, LastPartNum)
                    hasExited = true
                end

                HasAlreadyEnteredMarker = true
                LastStation = currentStation
                LastPart = currentPart
                LastPartNum = currentPartNum

                TriggerEvent('esx_policejob:hasEnteredMarker', currentStation,
                             currentPart, currentPartNum)

            end

            if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
                HasAlreadyEnteredMarker = false
                TriggerEvent('esx_policejob:hasExitedMarker', LastStation,
                             LastPart, LastPartNum)
            end

            if letSleep then Citizen.Wait(500) end

        else
            Citizen.Wait(500)
        end

		Citizen.Wait(SleepMarker)
    end
end)

-- Enter / Exit entity zone events
Citizen.CreateThread(function()
    local trackedEntities = {
        'prop_roadcone02a', 'prop_barrier_work05', 'p_ld_stinger_s',
        'prop_boxpile_07d', 'hei_prop_cash_crate_half_full'
    }

    while true do
        sleepProp = 1000
		
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        local closestDistance = -1
        local closestEntity = nil

        for i = 1, #trackedEntities, 1 do
            local object = GetClosestObjectOfType(coords, 3.0, GetHashKey(
                                                      trackedEntities[i]),
                                                  false, false, false)

            if DoesEntityExist(object) then
                local objCoords = GetEntityCoords(object)
                local distance = GetDistanceBetweenCoords(coords, objCoords,
                                                          true)

                if closestDistance == -1 or closestDistance > distance then
                    closestDistance = distance
                    closestEntity = object
                end
            end
        end

        if closestDistance ~= -1 and closestDistance <= 1.5 then sleepProp = 100
            if LastEntity ~= closestEntity then
                TriggerEvent('esx_policejob:hasEnteredEntityZone', closestEntity)
                LastEntity = closestEntity
            end
        else
            if LastEntity ~= nil then
                TriggerEvent('esx_policejob:hasExitedEntityZone', LastEntity)
                LastEntity = nil
            end
        end
		
		Citizen.Wait(sleepProp)
    end
end)

-- Key Controls
Citizen.CreateThread(function()
    while true do

        if CurrentAction ~= nil then 
            exports["esx_text_ui"]:Help(CurrentActionMsg)

            if IsControlJustReleased(0, Keys['E']) and ESX.PlayerData.job ~= nil and
                ESX.PlayerData.job.name == 'police' then

                if CurrentAction == 'menu_cloakroom' then
                    OpenCloakroomMenu()
                elseif CurrentAction == 'menu_armory' then
                    if Config.MaxInService == -1 then
                        OpenArmoryMenu(CurrentActionData.station)
                    elseif playerInService then
                        OpenArmoryMenu(CurrentActionData.station)
                    else
                        ESX.ShowNotification(_U('service_not'))
                    end
                elseif CurrentAction == 'menu_vehicle_spawner' then
                    if Config.MaxInService == -1 then
                        OpenVehicleSpawnerMenu('car', CurrentActionData.station,
                                               CurrentActionData.part,
                                               CurrentActionData.partNum)
                    elseif playerInService then
                        OpenVehicleSpawnerMenu('car', CurrentActionData.station,
                                               CurrentActionData.part,
                                               CurrentActionData.partNum)
                    else
                        ESX.ShowNotification(_U('service_not'))
                    end
                elseif CurrentAction == 'Helicopters' then
                    if Config.MaxInService == -1 then
                        OpenVehicleSpawnerMenu('helicopter',
                                               CurrentActionData.station,
                                               CurrentActionData.part,
                                               CurrentActionData.partNum)
                    elseif playerInService then
                        OpenVehicleSpawnerMenu('helicopter',
                                               CurrentActionData.station,
                                               CurrentActionData.part,
                                               CurrentActionData.partNum)
                    else
                        ESX.ShowNotification(_U('service_not'))
                    end
                elseif CurrentAction == 'delete_vehicle' then
                    ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
                elseif CurrentAction == 'menu_boss_actions' then
                    ESX.UI.Menu.CloseAll()
                    TriggerEvent('esx_society:openBossMenu', 'police',
                                 function(data, menu)
                        menu.close()

                        CurrentAction = 'menu_boss_actions'
                        CurrentActionMsg = _U('open_bossmenu')
                        CurrentActionData = {}
                    end, {wash = false}) -- disable washing money
                elseif CurrentAction == 'menu_search_actions' then
                    ESX.UI.Menu.CloseAll()
                    -- OpenSearchInfo()
                elseif CurrentAction == 'remove_entity' then
                    TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low",
                                 8.0, -8.0, -1, 0, 0, false, false, false)
                    Citizen.Wait(800)
                    DeleteEntity(CurrentActionData.entity)
                end

                CurrentAction = nil
            end
        end

        if IsControlJustReleased(0, Keys['F6']) and not isDead and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'police' and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'police_actions') then
            if Config.MaxInService == -1 then
                OpenPoliceActionsMenu()
				-- OpenPoliceMenuUI()
            elseif playerInService then
                OpenPoliceActionsMenu()
				-- OpenPoliceMenuUI()
            else
                ESX.ShowNotification(_U('service_not'))
            end
        end

        if IsControlJustReleased(0, Keys['E']) and CurrentTask.Busy then
            ESX.ShowNotification(_U('impound_canceled'))
            ESX.ClearTimeout(CurrentTask.Task)
            ClearPedTasks(PlayerPedId())

            CurrentTask.Busy = false
        end
		
		Citizen.Wait(3)
    end
end)


function OpenCloakroomMenu()

    local playerPed = PlayerPedId()
    local grade = ESX.PlayerData.job.grade_name

    local elements = {}

    table.insert(elements, {
        label = 'ชุดธรรมดา',
        value = 'more'
    })
	table.insert(elements, {
        label = 'ชุดประจำตำแหน่ง',
        value = 'job'
    })


    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
        title = _U('cloakroom'),
        align = 'top-right',
        elements = elements
    }, function(data, menu)

        cleanPlayer(playerPed)

        if data.current.value ~= nil then

            if data.current.value == 'more' then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)
            else
                ChangeUnifrom()
            end

        end

    end, function(data, menu)
        menu.close()

        CurrentAction = 'menu_cloakroom'
        CurrentActionMsg = _U('open_cloackroom')
        CurrentActionData = {}
    end)
end


function ChangeUnifrom()
	if Config.PoliceUniforms[ESX.GetPlayerData().job.grade_name] then
		TriggerEvent('skinchanger:getSkin', function(skin)
			if skin.sex == 0 then
				TriggerEvent('skinchanger:loadClothes', skin, Config.PoliceUniforms[ESX.GetPlayerData().job.grade_name].male)
			else
				TriggerEvent('skinchanger:loadClothes', skin, Config.PoliceUniforms[ESX.GetPlayerData().job.grade_name].female)
			end
		end)
	end
end



-- Create blip for colleagues
function createBlip(id)
    local ped = GetPlayerPed(id)
    local blip = GetBlipFromEntity(ped)

    if not DoesBlipExist(blip) then -- Add blip and create head display on player
        blip = AddBlipForEntity(ped)
        SetBlipSprite(blip, 1)
        ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
        SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
        SetBlipNameToPlayerName(blip, id) -- update blip name
        SetBlipScale(blip, 0.85) -- set scale
        SetBlipAsShortRange(blip, true)

        table.insert(blipsCops, blip) -- add blip to array so we can remove it later
    end
end

RegisterNetEvent('esx_policejob:updateBlip')
AddEventHandler('esx_policejob:updateBlip', function()

    -- Refresh all blips
    for k, existingBlip in pairs(blipsCops) do RemoveBlip(existingBlip) end

    -- Clean the blip table
    blipsCops = {}

    -- Enable blip?
    if Config.MaxInService ~= -1 and not playerInService then return end


end)

AddEventHandler('playerSpawned', function(spawn)
    isDead = false
    TriggerEvent('esx_policejob:unrestrain')

    if not hasAlreadyJoined then TriggerServerEvent('esx_policejob:spawned') end
    hasAlreadyJoined = true
end)

AddEventHandler('esx:onPlayerDeath', function(data) isDead = true end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerEvent('esx_policejob:unrestrain')
        TriggerEvent('esx_phone:removeSpecialContact', 'police')

        if Config.MaxInService ~= -1 then
            TriggerServerEvent('esx_service:disableService', 'police')
        end

        if Config.EnableHandcuffTimer and HandcuffTimer.Active then
            ESX.ClearTimeout(HandcuffTimer.Task)
        end
    end
end)

-- handcuff timer, unrestrain the player after an certain amount of time
function StartHandcuffTimer()
    if Config.EnableHandcuffTimer and HandcuffTimer.Active then
        ESX.ClearTimeout(HandcuffTimer.Task)
    end

    HandcuffTimer.Active = true

    HandcuffTimer.Task = ESX.SetTimeout(Config.HandcuffTimer, function()
        -- ESX.ShowNotification(_U('unrestrained_timer'))
        TriggerEvent('esx_policejob:unrestrain')
        HandcuffTimer.Active = false
    end)
end

-- TODO
--   - return to garage if owned
--   - message owner that his vehicle has been impounded
function ImpoundVehicle(vehicle)
    ESX.Game.DeleteVehicle(vehicle)
    TriggerEvent("pNotify:SendNotification", {
        text = 'พาวน์รถเรียบร้อยแล้ว',
        type = "success",
        timeout = 3000,
        layout = "bottomCenter",
        queue = "global"
    })
end

function ImpoundVehiclePolice(vehicle)
    TriggerServerEvent('esx_policejob:updateVehicleFromPolice',
                       GetVehicleNumberPlateText(vehicle))
    ESX.Game.DeleteVehicle(vehicle)
    TriggerEvent("pNotify:SendNotification", {
        text = 'ยึดรถไว้ที่สน.แล้ว',
        type = "success",
        timeout = 3000,
        layout = "bottomCenter",
        queue = "global"
    })
end




function Upgrade()
    local elements = {}
    if ESX.PlayerData.job.name == "police" then
        table.insert(elements, {
            label = 'เลื่อนเป็นระดับ 1 ใช้เงินแดง<span style="color:red;"> 300,000</span>',
            value = 'grade1'
        })
        table.insert(elements, {
            label = 'เลื่อนเป็นระดับ 2 ใช้เงินแดง<span style="color:red;"> 500,000</span>',
            value = 'grade2'
        })
        table.insert(elements, {
            label = 'เลื่อนเป็นระดับ 3 ใช้เงินแดง<span style="color:red;"> 700,000</span>',
            value = 'grade3'
        })
        table.insert(elements, {
            label = 'เลื่อนเป็นระดับ 4 ใช้เงินแดง<span style="color:red;"> 1,000,000</span>',
            value = 'grade4'
        })
    end
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'upgrade', {
        title = 'เลื่อนขั้น',
        align = 'top-right',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'grade1' then
            ESX.UI.Menu.CloseAll()
            TriggerServerEvent('UpgradeJob1', GetPlayerServerId(PlayerPedId()),
                               1)
        elseif data.current.value == 'grade2' then
            ESX.UI.Menu.CloseAll()
            TriggerServerEvent('UpgradeJob2', GetPlayerServerId(PlayerPedId()),
                               2)

        elseif data.current.value == 'grade3' then
            ESX.UI.Menu.CloseAll()
            TriggerServerEvent('UpgradeJob3')
        elseif data.current.value == 'grade4' then
            ESX.UI.Menu.CloseAll()
            TriggerServerEvent('UpgradeJob4')
        end
        ESX.UI.Menu.CloseAll()
    end, function(data, menu) menu.close() end)
end

function hintToDisplay(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function playAnim(animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 49, 1,
                 false, false, false)
    RemoveAnimDict(animDict)
end


Citizen.CreateThread(function()
    while true do
        local sleepM = 1000 
        local p = PlayerPedId()
        local pc = GetEntityCoords(p)
        local d = Vdist(pc, Config.CheckPlate.x, Config.CheckPlate.y, Config.CheckPlate.z)
        if d < 20 and ESX.GetPlayerData().job.name == "police" then sleepM = 7
            DrawMarker(36, Config.CheckPlate.x, Config.CheckPlate.y, Config.CheckPlate.z+1.0,nil,nil,nil,nil,nil,nil,1.0,1.0,1.0,0,0,153,100,true,true,2,true,false,false,false)
        end
        if d < 1.5 and ESX.GetPlayerData().job.name == "police" then sleepM = 5
            exports["esx_text_ui"]:Help('~INPUT_PICKUP~ ~b~Check NumberPlate')
            if IsControlJustPressed(0, 38) then
                if ESX.GetPlayerData().job.name ~= 'police' then
                    ESX.ShowNotification('~y~Not Police')
                else
                    checkPlate()
                end
            end
        
        end
		Citizen.Wait(sleepM)
    end
end)

function checkPlate()
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'dialog_Plate', {
        title = 'ใส่เลขทะเบียนรถ',
    },function(data, menu)
        TriggerServerEvent('esx_policejob:checkplate', data.value)
        menu.close()
    end,function(data, menu)
		menu.close()
		end
	)
end

RegisterNetEvent('esx_policejob:detechPlate')
AddEventHandler('esx_policejob:detechPlate', function(name)
    local elements = {}
    table.insert(elements, {label = ''..name, value = 'name'})
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Check_plate',
    {
        title = 'ระบบเช็คทะเบียนรถ',
        align    = 'bottom-right',
		elements = elements,
    },
    function(data, menu)
        if data.current.value == 'name' then
            ESX.UI.Menu.CloseAll()
        end
    end,function(data, menu)
		menu.close()
		end
	)
end)

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
RegisterNetEvent('esx_policejob:showbill')
AddEventHandler('esx_policejob:showbill', function(data, name)
    local elements = {}
    ESX.UI.Menu.CloseAll()
    for _,v in pairs(data) do
       table.insert(elements, {label = 'ชื่อบิล: '..v.label..' ราคา '..v.amount..'' , value = v.id})
    end
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Check_Bill',
    {
        title = 'ตรวจสอบบิล '..name,
        align    = 'top-right',
        elements = elements,
    },
    function(data, menu)
        if data.current.value then
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Check_Bill2', {
                title = 'จัดการบิล',
                align    = 'top-right',
                elements = {
                    {label = 'ลบ', value = 'del'},
                    {label = 'ยกเลิก', value = 'cancle'},
                    
                }
            }, 
            function(data2, menu2)
                if data2.current.value == 'del' then
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestPlayer ~= -1 and closestDistance <= 3.0 then
                        TriggerServerEvent('esx_policejob:delbill', GetPlayerServerId(closestPlayer), tonumber(data.current.value))                    
                    end
                    menu2.close()
                    menu.close()
                elseif data2.current.value == 'cancle' then
                    menu2.close()
                    menu.close()
                end
            end, function(data2, menu2)
                menu2.close()
                menu.close()
            end)
        end
    end, function(data, menu)
        menu.close()
    end)
end)


function ClearBill(id)
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Check_Bill', {
        title = 'จัดการบิล',
        align    = 'top-right',
        elements = {
            {label = 'ลบ', value = 'del'},
            {label = 'ยกเลิก', value = 'cancle'},
            
        }
    }, 
    function(data, menu)
        if data.current.value == 'del' then
            menu.close()
        elseif data.current.value == 'cancle' then
            menu.close()
        end
    end, function(data, menu)
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
        
        if d < 30 and ESX.GetPlayerData().job.name == "police" then sleepP = 7
            DrawMarker(22, bcoord.x, bcoord.y, bcoord.z,nil,nil,nil,nil,nil,nil,1.0,1.0,1.0,0,0,153,100,false,false,2,true,false,false,false)
        end
        
        if d < 1.5 and ESX.GetPlayerData().job.name == "police" then sleepP = 1
            exports["esx_text_ui"]:Help('~INPUT_PICKUP~ ~b~BossMenu')
            if IsControlJustPressed(0,38) then
                if ESX.GetPlayerData().job.name == 'police' and ESX.GetPlayerData().job.grade_name == 'boss' then
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
            TriggerServerEvent('esx_policejob:GetDepartMent')
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
            TriggerServerEvent('esx_policejob:setJobforid', data.value, ESX.GetPlayerData().job.name)
        end
        menu.close()
    end,function(data, menu)
		menu.close()
		end
	)
end

RegisterNetEvent('esx_policejob:SetDepartment')
AddEventHandler('esx_policejob:SetDepartment', function(data)
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
    ESX.TriggerServerCallback('esx_policejob:getjob', function(result)
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
                TriggerServerEvent('esx_policejob:SetJobPlayer_online', dataPlayer.id, data.current.name, data.current.grade)
            else
                TriggerServerEvent('esx_policejob:SetJobPlayer_offline', dataPlayer.id, data.current.name, data.current.grade)
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

exports('handcuff', function() 
    if IsHandcuffed then
        return true
    else
        return false
    end
end)


Citizen.CreateThread(function()
	while true do
		sleepTOggle = 1000
		local playerPed = PlayerPedId()
		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then sleepTOggle = 3
			if IsControlJustPressed(0, 313) and IsPedInAnyVehicle(playerPed, false) then
				togglecounter()
			end
		end
		
		Citizen.Wait(sleepTOggle)
	end
end)


function secondsToClock(seconds)
	local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0

	if seconds <= 0 then
		return 0, 0
	else
		local hours = string.format("%02.f", math.floor(seconds / 3600))
		local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
		local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))

		return mins, secs
	end
end

function togglecounter()
	timecounter = 0
	iscounter = not iscounter
	if not iscounter then
		exports.mythic_notify:PersistentAlert('end', counter)
	end
	local text = _U('counter', secondsToClock(timecounter))
	--print(iscounter)
	if iscounter then
		Citizen.CreateThread(function()
			while true do
				SleepCounter = 1000
				if iscounter then SleepCounter = 3
					Citizen.Wait(1000)
					timecounter = timecounter + 1
					text = _U('counter', secondsToClock(timecounter))
					exports.mythic_notify:PersistentAlert('start', counter, 'inform', text, { ['background-color'] = '#e74c3c' })
				else
					exports.mythic_notify:PersistentAlert('end', counter)
					break
				end
				
				Citizen.Wait(SleepCounter)
			end
		end)
	end
end



RegisterNetEvent('esx_policejob:unhandcuff_item')
AddEventHandler('esx_policejob:unhandcuff_item', function()
	local playerPed = PlayerPedId()
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if closestPlayer ~= -1 and closestDistance <= 1.2 then
		playerheading = GetEntityHeading(GetPlayerPed(-1))
		playerCoords = GetEntityCoords(GetPlayerPed(-1))
		playerlocation = GetEntityForwardVector(PlayerPedId())
		TriggerServerEvent('esx_policejob:key_unhandcuff', GetPlayerServerId(closestPlayer), playerheading, playerCoords, playerlocation)
	end
end)


----------------------------------------------------------------------------------------


local carry = {
	InProgress = false,
	targetSrc = -1,
	type = "",
	personCarrying = {
		animDict = "missfinale_c2mcs_1",
		anim = "fin_c2_mcs_1_camman",
		flag = 49,
	},
	personCarried = {
		animDict = "nm",
		anim = "firemans_carry",
		attachX = 0.27,
		attachY = 0.15,
		attachZ = 0.63,
		flag = 33,
	}
}

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _,playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords-playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
	if closestDistance ~= -1 and closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end

local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end        
    end
    return animDict
end


RegisterNetEvent("CarryPeople:command")
AddEventHandler("CarryPeople:command", function()

	if not carry.InProgress then
		local closestPlayer = GetClosestPlayer(3)
		if closestPlayer then
			local targetSrc = GetPlayerServerId(closestPlayer)
			if targetSrc ~= -1 then
				carry.InProgress = true
				carry.targetSrc = targetSrc
				TriggerServerEvent("CarryPeople:sync",targetSrc)
				ensureAnimDict(carry.personCarrying.animDict)
				carry.type = "carrying"
			else
				drawNativeNotification("~r~No one nearby to carry!")
			end
		else
			drawNativeNotification("~r~No one nearby to carry!")
		end
	else
		carry.InProgress = false
		ClearPedSecondaryTask(PlayerPedId())
		DetachEntity(PlayerPedId(), true, false)
		TriggerServerEvent("CarryPeople:stop",carry.targetSrc)
		carry.targetSrc = 0
	end
	
end)

RegisterNetEvent("CarryPeople:syncTarget")
AddEventHandler("CarryPeople:syncTarget", function(targetSrc)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
	carry.InProgress = true
	ensureAnimDict(carry.personCarried.animDict)
	AttachEntityToEntity(PlayerPedId(), targetPed, 0, carry.personCarried.attachX, carry.personCarried.attachY, carry.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
	carry.type = "beingcarried"
end)

RegisterNetEvent("CarryPeople:cl_stop")
AddEventHandler("CarryPeople:cl_stop", function()
	carry.InProgress = false
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)
end)

Citizen.CreateThread(function()
	while true do
		CarryLoop = 1000
		if carry.InProgress then CarryLoop = 1
			if carry.type == "beingcarried" then
				if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 3) then
					TaskPlayAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 8.0, -8.0, 100000, carry.personCarried.flag, 0, false, false, false)
				end
			end
		end
		Wait(CarryLoop)
	end
end)

----------------------------------------------------------------------------------------

RegisterNetEvent("police:crateDrop1")
AddEventHandler("police:crateDrop1", function()
		local dropCoords = GetEntityCoords(GetPlayerPed(-1))
		TriggerServerEvent("police:blips1", dropCoords)
end)

RegisterNetEvent("police:crateDrop2")
AddEventHandler("police:crateDrop2", function()
		local dropCoords = GetEntityCoords(GetPlayerPed(-1))
		TriggerServerEvent("police:blips2", dropCoords)
end)

RegisterNetEvent("police:crateDrop3")
AddEventHandler("police:crateDrop3", function()
		local dropCoords = GetEntityCoords(GetPlayerPed(-1))
		TriggerServerEvent("police:blips3", dropCoords)
end)

local location_x1 = 0
local location_y1 = 0
local location_z1 = 0
local curfew1 = false
local location_x2 = 0
local location_y2 = 0
local location_z2 = 0
local curfew2 = false
local location_x3 = 0
local location_y3 = 0
local location_z3 = 0
local curfew3 = false

local colorfew1 = 0
local colorfew2 = 0
local colorfew3 = 0

local blip1
local blip2
local blip3


RegisterNetEvent("police:sendBlipscer1")
AddEventHandler("police:sendBlipscer1", function(xlocation_x, xlocation_y, xlocation_z)
			colorfew1 = 0
			curfew1 = true
			location_x1 = xlocation_x
			location_y1 = xlocation_y
			location_z1 = xlocation_z
			blip1 = AddBlipForCoord(xlocation_x, xlocation_y, xlocation_z)
			SetBlipSprite(blip1, 4)
			SetBlipColour(blip1, 1)
			SetBlipScale (blip1, 1.0)
			SetBlipAlpha(blip1, 255)
end)

RegisterNetEvent("police:sendBlipscer2")
AddEventHandler("police:sendBlipscer2", function(xlocation_x, xlocation_y, xlocation_z)
			colorfew2 = 0
			curfew2 = true
			location_x2 = xlocation_x
			location_y2 = xlocation_y
			location_z2 = xlocation_z
			blip2 = AddBlipForCoord(xlocation_x, xlocation_y, xlocation_z)
			SetBlipSprite(blip2, 4)
			SetBlipColour(blip2, 1)
			SetBlipScale (blip2, 1.0)
			SetBlipAlpha(blip2, 255)
end)

RegisterNetEvent("police:sendBlipscer3")
AddEventHandler("police:sendBlipscer3", function(xlocation_x, xlocation_y, xlocation_z)
			colorfew3 = 0
			curfew3 = true
			location_x3 = xlocation_x
			location_y3 = xlocation_y
			location_z3 = xlocation_z
			blip3 = AddBlipForCoord(xlocation_x, xlocation_y, xlocation_z)
			SetBlipSprite(blip3, 4)
			SetBlipColour(blip3, 1)
			SetBlipScale (blip3, 1.0)
			SetBlipAlpha(blip3, 255)
end)

Citizen.CreateThread(function()
    while true do
			loopCurfew = 1000
			if curfew1 or curfew2 or curfew3 then
				loopCurfew = 5
			else
				loopCurfew = 1000
			end
			if curfew1 and colorfew1 >= Config.CurfewCooldown then
				DrawMarker(1, location_x1, location_y1, location_z1 - 30, 0, 0, 0, 0, 0, 0, 50 * 2.0, 50 * 2.0, 80.0, 255, 0, 0, 200, 0, 0, 0, 0, 0, 0, 0)
			elseif curfew1 then
				DrawMarker(1, location_x1, location_y1, location_z1 - 30, 0, 0, 0, 0, 0, 0, 50 * 2.0, 50 * 2.0, 80.0, 255, 255, 0, 200, 0, 0, 0, 0, 0, 0, 0)
			end
			if curfew2 and colorfew2 >= Config.CurfewCooldown then
				DrawMarker(1, location_x2, location_y2, location_z2 - 30, 0, 0, 0, 0, 0, 0, 50 * 2.0, 50 * 2.0, 80.0, 255, 0, 0, 200, 0, 0, 0, 0, 0, 0, 0)
			elseif curfew2 then
				DrawMarker(1, location_x2, location_y2, location_z2 - 30, 0, 0, 0, 0, 0, 0, 50 * 2.0, 50 * 2.0, 80.0, 255, 255, 0, 200, 0, 0, 0, 0, 0, 0, 0)
			end
			if curfew3 and colorfew3 >= Config.CurfewCooldown then
				DrawMarker(1, location_x3, location_y3, location_z3 - 30, 0, 0, 0, 0, 0, 0, 50 * 2.0, 50 * 2.0, 80.0, 255, 0, 0, 200, 0, 0, 0, 0, 0, 0, 0)
			elseif curfew3 then
				DrawMarker(1, location_x3, location_y3, location_z3 - 30, 0, 0, 0, 0, 0, 0, 50 * 2.0, 50 * 2.0, 80.0, 255, 255, 0, 200, 0, 0, 0, 0, 0, 0, 0)
			end
        Wait(loopCurfew)
    end
end)


Citizen.CreateThread(function()
    while true do
			loopCurfew = 1000
			if curfew1 or curfew2 or curfew3 then
				loopCurfew = 5
			else
				loopCurfew = 1000
			end
			if curfew1 and colorfew1 <= Config.CurfewCooldown then
				colorfew1 = colorfew1 + 1
			end
			if curfew2 and colorfew2 < Config.CurfewCooldown then
				colorfew2 = colorfew2 + 1
			end
			if curfew3 and colorfew3 < Config.CurfewCooldown then
				colorfew3 = colorfew3 + 1
			end
			
        Wait(loopCurfew)
    end
end)

RegisterNetEvent("police:endcurfew1")
AddEventHandler("police:endcurfew1", function()
	curfew1 = false
    RemoveBlip(blip1)
end)

RegisterNetEvent("police:endcurfew2")
AddEventHandler("police:endcurfew2", function()
	curfew2 = false
    RemoveBlip(blip2)
end)

RegisterNetEvent("police:endcurfew3")
AddEventHandler("police:endcurfew3", function()
	curfew3 = false
    RemoveBlip(blip3)
end)

