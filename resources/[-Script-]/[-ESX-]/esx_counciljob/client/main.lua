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
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local GUI = {}
local HasAlreadyEnteredMarker = false
local LastStation, LastPart, LastPartNum, LastEntity
local CurrentAction = nil
local CurrentActionMsg  = ''
local CurrentActionData = {}
local IsHandcuffed = false
local HandcuffTimer = {}
local DragStatus = {}
DragStatus.IsDragged = false
DragStatus.draganim = false
local hasAlreadyJoined = false
local blipsCops = {}
local isDead = false
local CurrentTask = {}
local playerInService = false
local spawnedVehicles, isInShopMenu = {}, false
local stk = true




function cleanPlayer(playerPed)
	SetPedArmour(playerPed, 0)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0)
end

function setUniform(job, playerPed)
	if Config.Uniforms[ESX.GetPlayerData().job.grade_name] then
		TriggerEvent('skinchanger:getSkin', function(skin)
			if skin.sex == 0 then
				TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[ESX.GetPlayerData().job.grade_name].male)
			else
				TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[ESX.GetPlayerData().job.grade_name].female)
			end
		end)
	end
end

function OpenCloakroomMenu()

	local playerPed = PlayerPedId()
	local grade = ESX.PlayerData.job.grade_name

	local elements = {
		{ label = _U('citizen_wear'), value = 'citizen_wear' },
		{ label = _U('council_wear'), value = 'council_wear' },
	}


	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom',
	{
		title    = _U('cloakroom'),
		align    = 'right',
		elements = elements
	}, function(data, menu)

		cleanPlayer(playerPed)

		if data.current.value == 'citizen_wear' then
			
			if Config.EnableNonFreemodePeds then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					local isMale = skin.sex == 0

					TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
						ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin)
							TriggerEvent('esx:restoreLoadout')
						end)
					end)

				end)
			else
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)
			end

			if Config.MaxInService ~= -1 then

				ESX.TriggerServerCallback('esx_service:isInService', function(isInService)
					if isInService then

						playerInService = false

						local notification = {
							title    = _U('service_anonunce'),
							subject  = '',
							msg      = _U('service_out_announce', GetPlayerName(PlayerId())),
							iconType = 1
						}

						TriggerServerEvent('esx_service:notifyAllInService', notification, 'council')

						TriggerServerEvent('esx_service:disableService', 'council')
						TriggerEvent('esx_counciljob:updateBlip')
						ESX.ShowNotification(_U('service_out'))
					end
				end, 'council')
			end
		end

		if data.current.value == 'council_wear' then
			setUniform()
		end

		if data.current.value == 'freemode_ped' then
			local modelHash = ''

			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin.sex == 0 then
					modelHash = GetHashKey(data.current.maleModel)
				else
					modelHash = GetHashKey(data.current.femaleModel)
				end

				ESX.Streaming.RequestModel(modelHash, function()
					SetPlayerModel(PlayerId(), modelHash)
					SetModelAsNoLongerNeeded(modelHash)

					TriggerEvent('esx:restoreLoadout')
				end)
			end)

		end

	end, function(data, menu)
		menu.close()

		CurrentAction     = 'menu_cloakroom'
		CurrentActionMsg  = _U('open_cloackroom')
		CurrentActionData = {}
	end)
end

function OpenArmoryMenu(station)
	local elements = {
		{label = _U('buy_weapons'), value = 'buy_weapons'}
	}



	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory',
	{
		title    = _U('armory'),
		align    = 'right',
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

		CurrentAction     = 'menu_armory'
		CurrentActionMsg  = _U('open_armory')
		CurrentActionData = {station = station}
	end)
end

function OpenVehicleSpawnerMenu(type, station, part, partNum)
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

			if type == 'car' then
				shopCoords = Config.CouncilStation[station].Vehicles[partNum].InsideShop
				local authorizedVehicles = Config.AuthorizedVehicles[ESX.PlayerData.job.grade_name]

				if #Config.AuthorizedVehicles['Shared'] > 0 then
					for k,vehicle in ipairs(Config.AuthorizedVehicles['Shared']) do
						table.insert(shopElements, {
							label = ('%s - <span class="green-text">%s</span>'):format(vehicle.label, _U('shop_item', ESX.Math.GroupDigits(vehicle.price))),
							name  = vehicle.label,
							model = vehicle.model,
							price = vehicle.price,
							type  = 'car'
						})
					end
				end

				if #authorizedVehicles > 0 then
					for k,vehicle in ipairs(authorizedVehicles) do
						table.insert(shopElements, {
							label = ('%s - <span class="green-text">%s</span>'):format(vehicle.label, _U('shop_item', ESX.Math.GroupDigits(vehicle.price))),
							name  = vehicle.label,
							model = vehicle.model,
							price = vehicle.price,
							type  = 'car'
						})
					end
				else
					if #Config.AuthorizedVehicles['Shared'] == 0 then
						return
					end
				end
			elseif type == 'helicopter' then
				shopCoords = Config.CouncilStation[station].Helicopters[partNum].InsideShop
				local authorizedHelicopters = Config.AuthorizedHelicopters[ESX.PlayerData.job.grade_name]

				if #authorizedHelicopters > 0 then
					for k,vehicle in ipairs(authorizedHelicopters) do
						table.insert(shopElements, {
							label = ('%s - <span class="green-text">%s</span>'):format(vehicle.label, _U('shop_item', ESX.Math.GroupDigits(vehicle.price))),
							name  = vehicle.label,
							model = vehicle.model,
							price = vehicle.price,
							livery = vehicle.livery or nil,
							type  = 'helicopter'
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
						align    = 'right',
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
			end, type)

		elseif data.current.action == 'store_garage' then
			StoreNearbyVehicle(playerCoords)
		elseif data.current.action == 'mod_vehicle' then
			
			local garage_mod = {}
			ESX.TriggerServerCallback('esx_counciljob:getVehicleFrommod', function(jobVehicles)
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
						})
					end

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_garage1', {
						title    = "รายชื่อรถ",
						align    = 'right',
						elements = garage_mod
					}, function(data2, menu2)
						local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(station, part, partNum)
						if foundSpawn then
							local value = data2.current.value
							local props = json.decode(jobVehicles[value].vehicle)

							ESX.Game.SpawnVehicle(props.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
								ESX.Game.SetVehicleProperties(vehicle, props)

								TriggerServerEvent('esx_counciljob:setVehicleFrommod', props.plate)
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

	ESX.TriggerServerCallback('esx_counciljob:storeNearbyVehicle', function(storeSuccess, foundNum)
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

			while DoesEntityExist(vehicleId.vehicle) do
				Citizen.Wait(500)
				attempts = attempts + 1

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

function GetAvailableVehicleSpawnPoint(station, part, partNum)
	local spawnPoints = Config.CouncilStation[station][part][partNum].SpawnPoints
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
		align    = 'right',
		elements = elements
	}, function(data, menu)

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop_confirm',
		{
			title    = _U('vehicleshop_confirm', data.current.name, data.current.price),
			align    = 'right',
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

				ESX.TriggerServerCallback('esx_counciljob:buyJobVehicle', function (bought)
					if bought then
						TriggerEvent("pNotify:SendNotification", {
							text = _U('vehicleshop_bought', data.current.name, ESX.Math.GroupDigits(data.current.price)),
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

			if data.current.livery then
				SetVehicleModKit(vehicle, 0)
				SetVehicleLivery(vehicle, data.current.livery)
			end
		end)
	end)

	WaitForVehicleToLoad(elements[1].model)
	ESX.Game.SpawnLocalVehicle(elements[1].model, shopCoords, 0.0, function(vehicle)
		table.insert(spawnedVehicles, vehicle)
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		FreezeEntityPosition(vehicle, true)

		if elements[1].livery then
			SetVehicleModKit(vehicle, 0)
			SetVehicleLivery(vehicle,elements[1].livery)
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		sleepshop = 1000

		if isInShopMenu then sleepshop = 1
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		end
		
		Citizen.Wait(sleepshop)
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

function OpenmodActionsMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mod_actions',
	{
		title    = 'Council',
		align    = 'right',
		elements = {
			{label = _U('citizen_interaction'),	value = 'citizen_interaction'},
			{label = _U('vehicle_interaction'),	value = 'vehicle_interaction'},
			{label = '<span style="color:white;">ประกาศสภา', value = 'annconcil'}
		}
	}, function(data, menu)

		if data.current.value == 'jail_menu' then
            TriggerEvent("esx-qalle-jail:openJailMenu")		
		elseif data.current.value == 'citizen_interaction' then
			local elements = {
				{label = "อุ้ม", value = 'canCarry'},
				{label = _U('id_card'),			value = 'identity_card'},
				{label = _U('search'),			value = 'body_search'},
				{label = _U('handcuff'),		value = 'handcuff'},
				{label = _U('unhandcuff'),		value = 'unhandcuff'},
				{label = _U('drag'),			value = 'drag'},
				{label = _U('put_in_vehicle'),	value = 'put_in_vehicle'},
				{label = _U('out_the_vehicle'),	value = 'out_the_vehicle'},
				{label = _U('fine'),			value = 'fine'},
			}
		
			if Config.EnableLicenses then
				table.insert(elements, { label = _U('license_check'), value = 'license' })
			end
		
			ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'citizen_interaction',
			{
				title    = _U('citizen_interaction'),
				align    = 'right',
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
						OpenBodySearchMenu(closestPlayer)
						TriggerServerEvent('esx_counciljob:message', GetPlayerServerId(closestPlayer), _U('being_searched'))
						
					elseif action == 'handcuff' then
						playerheading = GetEntityHeading(GetPlayerPed(-1))
						playerlocation = GetEntityForwardVector(PlayerPedId())
						playerCoords = GetEntityCoords(GetPlayerPed(-1))
						TriggerServerEvent('esx_counciljob:handcuff', GetPlayerServerId(closestPlayer), playerheading, playerCoords, playerlocation)
					elseif action == 'unhandcuff' then
						playerheading = GetEntityHeading(GetPlayerPed(-1))
						playerlocation = GetEntityForwardVector(PlayerPedId())
						playerCoords = GetEntityCoords(GetPlayerPed(-1))
						TriggerServerEvent('esx_counciljob:unhandcuff', GetPlayerServerId(closestPlayer), playerheading, playerCoords, playerlocation)
					elseif action == 'drag' then
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
					elseif action == 'put_in_vehicle' then
						TriggerServerEvent('esx_counciljob:putInVehicle', GetPlayerServerId(closestPlayer))
					elseif action == 'out_the_vehicle' then
						TriggerServerEvent('esx_counciljob:OutVehicle', GetPlayerServerId(closestPlayer))
					elseif action == 'fine' then
						OpenFineMenu(closestPlayer)
					elseif action == 'license' then
						ShowPlayerLicense(closestPlayer)
					elseif action == 'unpaid_bills' then
						OpenUnpaidBillsMenu(closestPlayer)
					elseif action == 'communityservice' then
						SendToCommunityService(GetPlayerServerId(closestPlayer))
					elseif action == 'canCarry' then
						TriggerEvent('CarryPeople:command')
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
			end, function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'vehicle_interaction' then
			local elements  = {}
			local playerPed = PlayerPedId()
			local coords    = GetEntityCoords(playerPed)
			local vehicle   = ESX.Game.GetVehicleInDirection()
			
			if DoesEntityExist(vehicle) then
				table.insert(elements, {label = "ข้อมูลรถ",	value = 'vehicle_infos'})
				table.insert(elements, {label = "ปลดล็อครถ",	value = 'hijack_vehicle'})
				table.insert(elements, {label = "พาวท์รถ",		value = 'impound'})
			end
			
			table.insert(elements, {label = _U('search_database'), value = 'search_database'})

			ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'vehicle_interaction',
			{
				title    = _U('vehicle_interaction'),
				align    = 'right',
				elements = elements
			}, function(data2, menu2)
				coords  = GetEntityCoords(playerPed)
				vehicle = ESX.Game.GetVehicleInDirection()
				action  = data2.current.value
				
				if action == 'search_database' then
					LookupVehicle()
				elseif DoesEntityExist(vehicle) then
					local vehicleData = ESX.Game.GetVehicleProperties(vehicle)
					if action == 'vehicle_infos' then
						OpenVehicleInfosMenu(vehicleData)
						
					elseif action == 'hijack_vehicle' then
						if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
							TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)
							Citizen.Wait(20000)
							ClearPedTasksImmediately(playerPed)

							SetVehicleDoorsLocked(vehicle, 1)
							SetVehicleDoorsLockedForAllPlayers(vehicle, false)
							TriggerEvent("pNotify:SendNotification", {
								text = '<strong class="green-text">ปลดล็อครถเรียบร้อยแล้ว</span>',
								type = "success",
								timeout = 3000,
								layout = "bottomCenter",
								queue = "global"
							})
						end
					elseif action == 'impound' then
					
						-- is the script busy?
						if CurrentTask.Busy then
							return
						end

						exports["esx_text_ui"]:Help(_U('impound_prompt'))
						
						TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
						
						CurrentTask.Busy = true
						CurrentTask.Task = ESX.SetTimeout(10000, function()
							ClearPedTasks(playerPed)
							ImpoundVehicle(vehicle)
							Citizen.Wait(100) -- sleep the entire script to let stuff sink back to reality
						end)
						
						-- keep track of that vehicle!
						Citizen.CreateThread(function()
							while CurrentTask.Busy do
								Citizen.Wait(1000)
							
								vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
								if not DoesEntityExist(vehicle) and CurrentTask.Busy then
									TriggerEvent("pNotify:SendNotification", {
										text = 'พาวท์รถถูกยกเลิกเนื่องจากรถเคลื่อนที่',
										type = "success",
										timeout = 3000,
										layout = "bottomCenter",
										queue = "global"
									})
									ESX.ClearTimeout(CurrentTask.Task)
									ClearPedTasks(playerPed)
									CurrentTask.Busy = false
									break
								end
							end
						end)
					elseif action == 'impound_mod' then

						-- print(GetVehicleNumberPlateText(vehicle))
						ESX.UI.Menu.CloseAll()

						-- is the script busy?
						if CurrentTask.Busy then
							return
						end

						exports["esx_text_ui"]:Help(_U('impound_prompt'))
						
						TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
						
						CurrentTask.Busy = true
						CurrentTask.Task = ESX.SetTimeout(10000, function()
							ClearPedTasks(playerPed)
							ImpoundVehiclemod(vehicle)
							Citizen.Wait(100) -- sleep the entire script to let stuff sink back to reality
						end)
						
						-- keep track of that vehicle!
						Citizen.CreateThread(function()
							while CurrentTask.Busy do
								Citizen.Wait(1000)
							
								vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
								if not DoesEntityExist(vehicle) and CurrentTask.Busy then
									TriggerEvent("pNotify:SendNotification", {
										text = 'พาวท์รถถูกยกเลิกเนื่องจากรถเคลื่อนที่',
										type = "success",
										timeout = 3000,
										layout = "bottomCenter",
										queue = "global"
									})
									ESX.ClearTimeout(CurrentTask.Task)
									ClearPedTasks(playerPed)
									CurrentTask.Busy = false
									break
								end
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

			end, function(data2, menu2)
				menu2.close()
			end)

		elseif data.current.value == 'annconcil' then
			AnnoucementCouncil()
			menu.close()
		end

	end, function(data, menu)
		menu.close()
	end)
end



function OpenIdentityCardMenu(player)

	ESX.TriggerServerCallback('esx_counciljob:getOtherPlayerData', function(data)

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

function OpenBodySearchMenu(player)

	-- TriggerEvent("rdx_mini-inventory:getOtherPlayerInventory", player)
	exports.nc_inventory:SearchInventory(GetPlayerServerId(player),'council')

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
			TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_mod',"Fine: "..value, tonumber(data2.value))
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





function LookupVehicle()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'lookup_vehicle',
	{
		title = _U('search_database_title'),
	}, function(data, menu)
		local length = string.len(data.value)
		if data.value == nil or length < 2 or length > 13 then
			TriggerEvent("pNotify:SendNotification", {
				text = 'เลขทะเบียนไม่ถูกต้อง',
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		else
			ESX.TriggerServerCallback('esx_counciljob:getVehicleFromPlate', function(owner, found)
				if found then
					TriggerEvent("pNotify:SendNotification", {
						text = 'รถคันนี้ลงทะเบียนโดย <strong class="green-text">'..owner..'</strong>',
						type = "success",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				else
					TriggerEvent("pNotify:SendNotification", {
						text = 'ไม่มีข้อมูลนี้อยู่ในระบบ',
						type = "success",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				end
			end, data.value)
			menu.close()
		end
	end, function(data, menu)
		menu.close()
	end)
end

function ShowPlayerLicense(player)
	local elements = {}
	local targetName
	ESX.TriggerServerCallback('esx_counciljob:getOtherPlayerData', function(data)
		if data.licenses then
			for i=1, #data.licenses, 1 do
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
			title    = _U('license_revoke'),
			align    = 'right',
			elements = elements,
		}, function(data, menu)
			TriggerEvent("pNotify:SendNotification", {
				text = 'คุณเพิกถอน <strong class="blue-text">'..data.current.label..'</strong> ซึ่งเป็นของ <strong class="yellow-text">'..targetName..'</strong>',
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
			TriggerServerEvent('esx_counciljob:message', GetPlayerServerId(player), _U('license_revoked', data.current.label))
			
			TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(player), data.current.type)
			
			ESX.SetTimeout(300, function()
				ShowPlayerLicense(player)
			end)
		end, function(data, menu)
			menu.close()
		end)

	end, GetPlayerServerId(player))
end

function OpenUnpaidBillsMenu(player)
	local elements = {}

	ESX.TriggerServerCallback('esx_billing:getTargetBills', function(bills)
		if #bills > 0 then
			for i=1, #bills, 1 do
				table.insert(elements, {
					label = bills[i].label .. ' - <span class="red-text"">$' .. bills[i].amount .. '</span>',
					value = bills[i].id
				})
			end
		else
			table.insert(elements, {
				label = '<strong class="black-text">ไม่มีบิล</strong>'
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billing-list',
		{
			title    = _U('unpaid_bills'),
			align    = 'right',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback('esx_billing:getBillsIdView', function(data_billing)
				
				local elements1 = {}
				table.insert(elements1, {label = data_billing.label, value = data_billing.id})
				table.insert(elements1, {label = "วันที่แจ้งบิล : "..data_billing.time, value = data_billing.id})
				table.insert(elements1, {label = "ลบบิล", value = "pay"})

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billing-list-'..data.current.value,
				{
					title    = "#"..data.current.value,
					align    = 'right',
					elements = elements1
				}, function(data2, menu2)

					menu2.close()

					if data2.current.value == "pay" then
						TriggerServerEvent('esx_billing:sendBill', data_billing.id)
						OpenUnpaidBillsMenu(player)
					end

				end, function(data2, menu2)
					menu2.close()
				end)

			end, data.current.value)
		end, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

function OpenVehicleInfosMenu(vehicleData)

	ESX.TriggerServerCallback('esx_counciljob:getVehicleInfos', function(retrivedInfo)

		local elements = {}

		table.insert(elements, {label = _U('plate', retrivedInfo.plate), value = nil})

		if retrivedInfo.owner == nil then
			table.insert(elements, {label = _U('owner_unknown'), value = nil})
		else
			table.insert(elements, {label = _U('owner', retrivedInfo.owner), value = nil})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_infos',
		{
			title    = _U('vehicle_info'),
			align    = 'right',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)

	end, vehicleData.plate)

end

function OpenGetWeaponMenu()

	ESX.TriggerServerCallback('esx_counciljob:getArmoryWeapons', function(weapons)
		local elements = {}

		for i=1, #weapons, 1 do
			if weapons[i].count > 0 then
				table.insert(elements, {
					label = 'x' .. weapons[i].count .. ' ' .. ESX.GetWeaponLabel(weapons[i].name),
					value = weapons[i].name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_get_weapon',
		{
			title    = _U('get_weapon_menu'),
			align    = 'right',
			elements = elements
		}, function(data, menu)

			menu.close()

			ESX.TriggerServerCallback('esx_counciljob:removeArmoryWeapon', function()
				OpenGetWeaponMenu()
			end, data.current.value)

		end, function(data, menu)
			menu.close()
		end)
	end)

end

function OpenPutWeaponMenu()
	local elements   = {}
	local playerPed  = PlayerPedId()
	local weaponList = ESX.GetWeaponList()

	for i=1, #weaponList, 1 do
		local weaponHash = GetHashKey(weaponList[i].name)

		if HasPedGotWeapon(playerPed, weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
			table.insert(elements, {
				label = weaponList[i].label,
				value = weaponList[i].name
			})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_put_weapon',
	{
		title    = _U('put_weapon_menu'),
		align    = 'right',
		elements = elements
	}, function(data, menu)

		menu.close()

		ESX.TriggerServerCallback('esx_counciljob:addArmoryWeapon', function()
			OpenPutWeaponMenu()
		end, data.current.value, true)

	end, function(data, menu)
		menu.close()
	end)
end

function OpenBuyWeaponsMenu()

	local elements = {}
	local playerPed = PlayerPedId()
	PlayerData = ESX.GetPlayerData()

	for k,v in ipairs(Config.AuthorizedWeapons[ESX.PlayerData.job.grade_name]) do
		local weaponNum, weapon = ESX.GetWeapon(v.weapon)
		local components, label = {}

		local hasWeapon = HasPedGotWeapon(playerPed, GetHashKey(v.weapon), false)

		if v.components then
			for i=1, #v.components do
				if v.components[i] then

					local component = weapon.components[i]
					local hasComponent = HasPedGotWeaponComponent(playerPed, GetHashKey(v.weapon), component.hash)

					if hasComponent then
						label = ('%s: <span class="green-text">%s</span>'):format(component.label, _U('armory_owned'))
					else
						if v.components[i] > 0 then
							label = ('%s: <span class="green-text">%s</span>'):format(component.label, _U('armory_item', ESX.Math.GroupDigits(v.components[i])))
						else
							label = ('%s: <span class="green-text">%s</span>'):format(component.label, _U('armory_free'))
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
				label = ('%s: <span class="green-text">%s</span>'):format(weapon.label, _U('armory_item', ESX.Math.GroupDigits(v.price)))
			else
				label = ('%s: <span class="green-text">%s</span>'):format(weapon.label, _U('armory_free'))
			end
		end

		table.insert(elements, {
			label = label,
			weaponLabel = weapon.label,
			name = weapon.name,
			components = components,
			price = v.price,
			hasWeapon = hasWeapon
		})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_buy_weapons', {
		title    = 'คลังแสง - ซื้ออาวุธ',
		align    = 'right',
		elements = elements
	}, function(data, menu)

		if data.current.hasWeapon then
			if #data.current.components > 0 then
				OpenWeaponComponentShop(data.current.components, data.current.name, menu)
			end
		else
			ESX.TriggerServerCallback('esx_counciljob:buyWeapon', function(bought)
				if bought then
					if data.current.price > 0 then
						TriggerEvent("pNotify:SendNotification", {
							text = 'คุณซื้อ <strong class="yellow-text">'..data.current.weaponLabel..'</strong> ราคา <strong class="green-text">$'..ESX.Math.GroupDigits(data.current.price)..'</strong>',
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

	end, function(data, menu)
		menu.close()
	end)

end

function OpenWeaponComponentShop(components, weaponName, parentShop)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_buy_weapons_components', {
		title    = 'คลังแสง - ตกแต่งอาวุธ',
		align    = 'right',
		elements = components
	}, function(data, menu)

		if data.current.hasComponent then
			TriggerEvent("pNotify:SendNotification", {
				text = '<strong class="green-text">แต่งอุปกรณ์ปืนเรียบร้อยแล้ว</strong>',
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		else
			ESX.TriggerServerCallback('esx_counciljob:buyWeapon', function(bought)
				if bought then
					if data.current.price > 0 then
						TriggerEvent("pNotify:SendNotification", {
							text = 'คุณซื้อ <strong class="yellow-text">'..data.current.componentLabel..'</strong> ราคา <strong class="green-text">$'..ESX.Math.GroupDigits(data.current.price)..'</strong>',
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
						type = "error",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				end
			end, weaponName, 2, data.current.componentNum)
		end

	end, function(data, menu)
		menu.close()
	end)
end

function OpenGetStocksMenu()

	ESX.TriggerServerCallback('esx_counciljob:getStockItems', function(items)

		local elements = {}

		for i=1, #items, 1 do
			table.insert(elements, {
				label = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu',
		{
			title    = _U('mod_stock'),
			align    = 'right',
			elements = elements
		}, function(data, menu)

			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)

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
					TriggerServerEvent('esx_counciljob:getStockItem', itemName, count)
					
					Citizen.Wait(300)
					OpenGetStocksMenu()
				end

			end, function(data2, menu2)
				menu2.close()
			end)

		end, function(data, menu)
			menu.close()
		end)

	end)

end

function OpenPutStocksMenu()

	ESX.TriggerServerCallback('esx_counciljob:getPlayerInventory', function(inventory)

		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu',
		{
			title    = _U('inventory'),
			align    = 'right',
			elements = elements
		}, function(data, menu)

			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)

				local count = tonumber(data2.value)

				if count == nil then
					TriggerEvent("pNotify:SendNotification", {
						text = 'ปริมาณที่ไม่ถูกต้อง',
						type = "error",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_counciljob:putStockItems', itemName, count)
					TriggerServerEvent("discordbot:bodysearch_sv", GetPlayerName(PlayerId()), vehicleData.name, vehicleData.price)
					Citizen.Wait(300)
					OpenPutStocksMenu()
				end

			end, function(data2, menu2)
				menu2.close()
			end)

		end, function(data, menu)
			menu.close()
		end)
	end)

end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	
	Citizen.Wait(5000)
	TriggerServerEvent('esx_counciljob:forceBlip')
end)

AddEventHandler('esx_counciljob:hasEnteredMarker', function(station, part, partNum)

	if part == 'Cloakroom' then
		CurrentAction     = 'menu_cloakroom'
		CurrentActionMsg  = _U('open_cloackroom')
		CurrentActionData = {}

	elseif part == 'Armory' then

		CurrentAction     = 'menu_armory'
		CurrentActionMsg  = _U('open_armory')
		CurrentActionData = {station = station}

	elseif part == 'Vehicles' then

		CurrentAction     = 'menu_vehicle_spawner'
		CurrentActionMsg  = _U('garage_prompt')
		CurrentActionData = {station = station, part = part, partNum = partNum}

	elseif part == 'Helicopters' then

		CurrentAction     = 'Helicopters'
		CurrentActionMsg  = _U('helicopter_prompt')
		CurrentActionData = {station = station, part = part, partNum = partNum}

	end

end)

AddEventHandler('esx_counciljob:hasExitedMarker', function(station, part, partNum)
	if not isInShopMenu then
		ESX.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)

AddEventHandler('esx_counciljob:hasEnteredEntityZone', function(entity)
	local playerPed = PlayerPedId()

	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'council' and IsPedOnFoot(playerPed) then
		CurrentAction     = 'remove_entity'
		CurrentActionMsg  = _U('remove_prop')
		CurrentActionData = {entity = entity}
	end

	if GetEntityModel(entity) == GetHashKey('p_ld_stinger_s') then
		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)

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

AddEventHandler('esx_counciljob:hasExitedEntityZone', function(entity)
	if CurrentAction == 'remove_entity' then
		CurrentAction = nil
	end
end)

RegisterNetEvent('esx_counciljob:getarrested')
AddEventHandler('esx_counciljob:getarrested', function(playerheading, playercoords, playerlocation)
	playerPed = GetPlayerPed(-1)
	local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
	SetEntityCoords(GetPlayerPed(-1), x, y, z)
	SetEntityHeading(GetPlayerPed(-1), playerheading)
	Citizen.Wait(250)
	ESX.Streaming.RequestAnimDict("mp_arrest_paired", function()
		TaskPlayAnim(GetPlayerPed(-1), 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8,3750, 2, 0, 0, 0, 0)
		Citizen.Wait(3060)
		TriggerEvent("esx_counciljob:handcuff")
	end)
	
end)

RegisterNetEvent('esx_counciljob:douncuffing')
AddEventHandler('esx_counciljob:douncuffing', function()
	Citizen.Wait(250)
	ESX.Streaming.RequestAnimDict("mp_arresting", function()
		TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'a_uncuff', 8.0, -8,3750, 2, 0, 0, 0, 0)
	end)
	Citizen.Wait(5500)
	ClearPedTasks(GetPlayerPed(-1))
end)

RegisterNetEvent('esx_counciljob:getuncuffed')
AddEventHandler('esx_counciljob:getuncuffed', function(playerheading, playercoords, playerlocation)
	local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
	SetEntityCoords(GetPlayerPed(-1), x, y, z)
	SetEntityHeading(GetPlayerPed(-1), playerheading)
	Citizen.Wait(250)
	ESX.Streaming.RequestAnimDict("mp_arresting", function()
		TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'b_uncuff', 8.0, -8,3750, 2, 0, 0, 0, 0)
		Citizen.Wait(3000)
		TriggerEvent("esx_counciljob:handcuff")
	end)
	
end)


RegisterNetEvent('esx_counciljob:doarrested')
AddEventHandler('esx_counciljob:doarrested', function()
	Citizen.Wait(250)
	ESX.Streaming.RequestAnimDict("mp_arrest_paired", function()
		TaskPlayAnim(GetPlayerPed(-1), 'mp_arrest_paired', 'cop_p2_back_right', 8.0, -8,3750, 2, 0, 0, 0, 0)
	end)
	Citizen.Wait(3000)
end)


RegisterNetEvent('esx_counciljob:handcuff')
AddEventHandler('esx_counciljob:handcuff', function()
	IsHandcuffed    = not IsHandcuffed
	local playerPed = PlayerPedId()

	Citizen.CreateThread(function()
		
		if IsHandcuffed then

			SetEnableHandcuffs(playerPed, true)
			DisablePlayerFiring(playerPed, true)
			SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
			SetPedCanPlayGestureAnims(playerPed, false)
			--FreezeEntityPosition(playerPed, true)
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

RegisterNetEvent('esx_counciljob:unrestrain')
AddEventHandler('esx_counciljob:unrestrain', function()
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


RegisterNetEvent('esx_counciljob:drag')
AddEventHandler('esx_counciljob:drag', function(copID)
	if not IsHandcuffed then
		return
	end
	
	DragStatus.IsDragged = not DragStatus.IsDragged
	DragStatus.CopId     = tonumber(copID)
	
end)

Citizen.CreateThread(function()
	local playerPed
	local targetPed

	while true do
		sleepHandcuff = 750
		if IsHandcuffed then sleepHandcuff = 1
			playerPed = PlayerPedId()

			if DragStatus.IsDragged then
			
				targetPed = GetPlayerPed(GetPlayerFromServerId(DragStatus.CopId))

				-- undrag if target is in an vehicle
				if not IsPedSittingInAnyVehicle(targetPed) then
					AttachEntityToEntity(playerPed, targetPed, 11816, -0.06, 0.65, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
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
		
		Citizen.Wait(sleepHandcuff)
	end
end)

RegisterNetEvent('esx_counciljob:putInVehicle')
AddEventHandler('esx_counciljob:putInVehicle', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	if not IsHandcuffed then
		return
	end

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
				DragStatus.IsDragged = false
			end
		end
	end
end)

RegisterNetEvent('esx_counciljob:OutVehicle')
AddEventHandler('esx_counciljob:OutVehicle', function()
	local playerPed = PlayerPedId()

	if not IsPedSittingInAnyVehicle(playerPed) then
		return
	end

	local vehicle = GetVehiclePedIsIn(playerPed, false)
	TaskLeaveVehicle(playerPed, vehicle, 16)
end)

-- Handcuff
Citizen.CreateThread(function()
	while true do
		sleepp = 850
		local playerPed = PlayerPedId()

		if IsHandcuffed then sleepp = 1
			DisableControlAction(0, 1, true) -- Disable pan
			DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, Keys['W'], true) -- W
			DisableControlAction(0, Keys['A'], true) -- A
			DisableControlAction(0, 31, true) -- S (fault in Keys table!)
			DisableControlAction(0, 30, true) -- D (fault in Keys table!)

			DisableControlAction(0, Keys['R'], true) -- Reload
			DisableControlAction(0, Keys['SPACE'], true) -- Jump
			DisableControlAction(0, Keys['Q'], true) -- Cover
			DisableControlAction(0, Keys['TAB'], true) -- Select Weapon
			DisableControlAction(0, Keys['F'], true) -- Also 'enter'?

			DisableControlAction(0, Keys['F1'], true) -- Disable phone
			DisableControlAction(0, Keys['F2'], true) -- Inventory
			DisableControlAction(0, Keys['F3'], true) -- Animations
			DisableControlAction(0, Keys['F6'], true) -- Job

			DisableControlAction(0, Keys['V'], true) -- Disable changing view
			DisableControlAction(0, Keys['C'], true) -- Disable looking behind
			DisableControlAction(0, Keys['X'], true) -- Disable clearing animation
			DisableControlAction(2, Keys['P'], true) -- Disable pause screen
 
			DisableControlAction(0, Keys['M'], true) -- Phone
			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle
            
			
			
			DisableControlAction(2, Keys['LEFTCTRL'], true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle

			if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 then stk = false
				ESX.Streaming.RequestAnimDict('mp_arresting', function()
					TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
				end)
			end
		end
			
		Citizen.Wait(sleepp)
	end
end)

-- Create blips
Citizen.CreateThread(function()

	for k,v in pairs(Config.CouncilStation) do
		local blip = AddBlipForCoord(v.Blip.Coords)

		SetBlipSprite (blip, v.Blip.Sprite)
		SetBlipDisplay(blip, v.Blip.Display)
		SetBlipScale  (blip, v.Blip.Scale)
		SetBlipColour (blip, v.Blip.Colour)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('map_blip'))
		EndTextCommandSetBlipName(blip)
	end

end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2)
		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'council' then

			local playerPed = PlayerPedId()
			local coords    = GetEntityCoords(playerPed)
			local isInMarker, hasExited, letSleep = false, false, true
			local currentStation, currentPart, currentPartNum

			for k,v in pairs(Config.CouncilStation) do

				for i=1, #v.Cloakrooms, 1 do
					local distance = GetDistanceBetweenCoords(coords, v.Cloakrooms[i], true)

					if distance < Config.DrawDistance then
						DrawMarker(20, v.Cloakrooms[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false
					end

					if distance < Config.MarkerSize.x then
						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Cloakroom', i
					end
				end

				for i=1, #v.Armories, 1 do
					local distance = GetDistanceBetweenCoords(coords, v.Armories[i], true)

					if distance < Config.DrawDistance then
						DrawMarker(21, v.Armories[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false
					end

					if distance < Config.MarkerSize.x then
						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Armory', i
					end
				end

				for i=1, #v.Vehicles, 1 do
					local distance = GetDistanceBetweenCoords(coords, v.Vehicles[i].Spawner, true)

					if distance < Config.DrawDistance then
						DrawMarker(36, v.Vehicles[i].Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false
					end

					if distance < Config.MarkerSize.x then
						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Vehicles', i
					end
				end

				for i=1, #v.Helicopters, 1 do
					local distance =  GetDistanceBetweenCoords(coords, v.Helicopters[i].Spawner, true)

					if distance < Config.DrawDistance then
						DrawMarker(34, v.Helicopters[i].Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false
					end

					if distance < Config.MarkerSize.x then
						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Helicopters', i
					end
				end



			end

			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
	
				if
					(LastStation ~= nil and LastPart ~= nil and LastPartNum ~= nil) and
					(LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
				then
					TriggerEvent('esx_counciljob:hasExitedMarker', LastStation, LastPart, LastPartNum)
					hasExited = true
				end

				HasAlreadyEnteredMarker = true
				LastStation             = currentStation
				LastPart                = currentPart
				LastPartNum             = currentPartNum

				TriggerEvent('esx_counciljob:hasEnteredMarker', currentStation, currentPart, currentPartNum)

			end

			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_counciljob:hasExitedMarker', LastStation, LastPart, LastPartNum)
			end

			if letSleep then
				Citizen.Wait(500)
			end

		else
			Citizen.Wait(500)
		end

	end
end)

-- Enter / Exit entity zone events
Citizen.CreateThread(function()
	local trackedEntities = {
		'prop_roadcone02a',
		'prop_barrier_work05',
		'p_ld_stinger_s',
		'prop_boxpile_07d',
		'hei_prop_cash_crate_half_full'
	}

	while true do
		Citizen.Wait(500)
		stk = true
		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)

		local closestDistance = -1
		local closestEntity   = nil

		for i=1, #trackedEntities, 1 do
			local object = GetClosestObjectOfType(coords, 3.0, GetHashKey(trackedEntities[i]), false, false, false)

			if DoesEntityExist(object) then stk = false
				local objCoords = GetEntityCoords(object)
				local distance  = GetDistanceBetweenCoords(coords, objCoords, true)

				if closestDistance == -1 or closestDistance > distance then stk = false
					closestDistance = distance
					closestEntity   = object
				end
			end
		end

		if closestDistance ~= -1 and closestDistance <= 3.0 then stk = false
			if LastEntity ~= closestEntity then stk = false
				TriggerEvent('esx_counciljob:hasEnteredEntityZone', closestEntity)
				LastEntity = closestEntity
			end
		else
			if LastEntity ~= nil then stk = false
				TriggerEvent('esx_counciljob:hasExitedEntityZone', LastEntity)
				LastEntity = nil
			end
		end
		if stk then
            Citizen.Wait(500)
        end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(3)

		if CurrentAction ~= nil then
			exports["esx_text_ui"]:Help(CurrentActionMsg)

			if IsControlJustReleased(0, Keys['E']) and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'council' then

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
						OpenVehicleSpawnerMenu('car', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
					elseif playerInService then
						OpenVehicleSpawnerMenu('car', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
					else
						ESX.ShowNotification(_U('service_not'))
					end
				elseif CurrentAction == 'Helicopters' then
					if Config.MaxInService == -1 then
						OpenVehicleSpawnerMenu('helicopter', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
					elseif playerInService then
						OpenVehicleSpawnerMenu('helicopter', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
					else
						ESX.ShowNotification(_U('service_not'))
					end
				elseif CurrentAction == 'delete_vehicle' then
					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
				end
				
				CurrentAction = nil
			end
		end -- CurrentAction end
		
		if IsControlJustReleased(0, Keys['F6']) and not isDead and ESX.PlayerData.job ~= nil and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'mod_actions') then
			if ESX.PlayerData.job.name == 'council' then	
				if Config.MaxInService == -1 then
					-- OpenmodActionsMenu()
					OpenCouncilMenu()
				elseif playerInService then
					-- OpenmodActionsMenu()
					OpenCouncilMenu()
				else
					ESX.ShowNotification(_U('service_not'))
				end
			end
		end
		
		if IsControlJustReleased(0, Keys['E']) and CurrentTask.Busy then
			ESX.ShowNotification(_U('impound_canceled'))
			ESX.ClearTimeout(CurrentTask.Task)
			ClearPedTasks(PlayerPedId())
			
			CurrentTask.Busy = false
		end
	end
end)


AddEventHandler('playerSpawned', function(spawn)
	isDead = false
	TriggerEvent('esx_counciljob:unrestrain')
	
	if not hasAlreadyJoined then
		TriggerServerEvent('esx_counciljob:spawned')
	end
	hasAlreadyJoined = true
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'council' then
		-- print('test gps')
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
		TriggerEvent('esx_counciljob:unrestrain')
		HandcuffTimer.Active = false
	end)
end

-- TODO
--   - return to garage if owned
--   - message owner that his vehicle has been impounded
function ImpoundVehicle(vehicle)
	ESX.Game.DeleteVehicle(vehicle) 
	TriggerEvent("pNotify:SendNotification", {
		text = '<strong class="green-text">พาวน์รถเรียบร้อยแล้ว</strong>',
		type = "success",
		timeout = 3000,
		layout = "bottomCenter",
		queue = "global"
	})
	CurrentTask.Busy = false
end

function ImpoundVehiclemod(vehicle)
	TriggerServerEvent('esx_counciljob:updateVehicleFrommod', GetVehicleNumberPlateText(vehicle))
	ESX.Game.DeleteVehicle(vehicle) 
	TriggerEvent("pNotify:SendNotification", {
		text = '<strong class="green-text">พาวน์รถเรียบร้อยแล้ว</strong>',
		type = "success",
		timeout = 3000,
		layout = "bottomCenter",
		queue = "global"
	})
	CurrentTask.Busy = false
end

Citizen.CreateThread(function()
	while true do
		sleepToggle = 1000
		local playerPed = PlayerPedId()
		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'council' then sleepToggle = 1
			if IsControlJustPressed(0, 313) and IsPedInAnyVehicle(playerPed, false) then
				togglecounter()
			end
		end
		
		Citizen.Wait(sleepToggle)
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

	if iscounter then
		Citizen.CreateThread(function()
			while true do
				sleepCounter = 1000
				if iscounter then sleepCounter = 1
					Citizen.Wait(1000)
					timecounter = timecounter + 1
					text = _U('counter', secondsToClock(timecounter))
					exports.mythic_notify:PersistentAlert('start', counter, 'inform', text, { ['background-color'] = '#e74c3c' })
				else
					exports.mythic_notify:PersistentAlert('end', counter)
					break
				end
				
				Citizen.Wait(sleepCounter)
			end
		end)
	end
end

function AnnoucementCouncil()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'Annoucement Council', {
		title = "ประกาศสภา",
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
			TriggerServerEvent("esx_counciljob:sendAnnoucecouncil", AnnouceText)
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
        
        if d < 30 and ESX.GetPlayerData().job.name == "council" then sleepP = 7
            DrawMarker(22, bcoord.x, bcoord.y, bcoord.z,nil,nil,nil,nil,nil,nil,1.0,1.0,1.0,0,255,255,100,false,false,2,true,false,false,false)
        end
        
        if d < 1.5 and ESX.GetPlayerData().job.name == "council" then sleepP = 1
            exports["esx_text_ui"]:Help('~INPUT_PICKUP~ ~b~BossMenu')
            if IsControlJustPressed(0,38) then
                if ESX.GetPlayerData().job.name == 'council' and ESX.GetPlayerData().job.grade_name == 'boss' then
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
            TriggerServerEvent('esx_counciljob:GetDepartMent')
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
            TriggerServerEvent('esx_counciljob:setJobforid', data.value, ESX.GetPlayerData().job.name)
        end
        menu.close()
    end,function(data, menu)
		menu.close()
		end
	)
end

RegisterNetEvent('esx_counciljob:SetDepartment')
AddEventHandler('esx_counciljob:SetDepartment', function(data)
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
    ESX.TriggerServerCallback('esx_counciljob:getjob', function(result)
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
                TriggerServerEvent('esx_counciljob:SetJobPlayer_online', dataPlayer.id, data.current.name, data.current.grade)
            else
                TriggerServerEvent('esx_counciljob:SetJobPlayer_offline', dataPlayer.id, data.current.name, data.current.grade)
            end
            menu.close()
        end, function(data, menu)
            menu.close()
        end)
    end, ESX.GetPlayerData().job.name) 
end