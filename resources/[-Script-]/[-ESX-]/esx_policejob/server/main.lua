ESX = exports["es_extended"]:getSharedObject()



if Config.MaxInService ~= -1 then
	TriggerEvent('esx_service:activateService', 'police', Config.MaxInService)
end

TriggerEvent('esx_phone:registerNumber', 'police', _U('alert_police'), true, true)
TriggerEvent('esx_society:registerSociety', 'police', 'Police', 'society_police', 'society_police', 'society_police', {type = 'public'})

ESX.RegisterServerCallback('esx_policejob:getVehicleFromPolice', function (source, cb)
	MySQL.Async.fetchAll('SELECT *, date_format(time, "%Y-%m-%d") AS time FROM owned_vehicles WHERE police = @police', {
		['@police'] =1
	}, function (result)

		local vehicles = {}

		for i=1, #result, 1 do
			
			table.insert(vehicles, {
				owner         = result[i].owner,
				plate = result[i].plate,
				vehicle     = result[i].vehicle,
				type = result[i].type,
				job     = result[i].job,
				stored      = result[i].stored,
				fourrieremecano     = result[i].fourrieremecano,
				vehiclename		  = result[i].vehiclename,
				buyer		  = result[i].buyer,
				properties		  = result[i].properties,
				police		  = result[i].police,
				police_by		  = result[i].police_by,
				time		  = result[i].time
			})
		end

		cb(vehicles)
	end)
end)

RegisterServerEvent('esx_policejob:updateVehicleFromPolice')
AddEventHandler('esx_policejob:updateVehicleFromPolice', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('UPDATE owned_vehicles SET `police` = @police, `police_by` = @police_by, `time` = NOW() WHERE plate = @plate', {
		['@police'] = 1,
		['@plate'] = plate,
		['@police_by'] = xPlayer.name
	}, function(rowsChanged)
		if rowsChanged == 0 then
			print("ERROR Update setVehicleFromPolice")
		end
	end)
end)


RegisterServerEvent('esx_policejob:setVehicleFromPolice')
AddEventHandler('esx_policejob:setVehicleFromPolice', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('UPDATE owned_vehicles SET `police` = @police, `police_by` = @police_by WHERE plate = @plate', {
		['@police'] = 0,
		['@plate'] = plate,
		['@police_by'] = nil
	}, function(rowsChanged)
		if rowsChanged == 0 then
			print("ERROR Update setVehicleFromPolice")
		end
	end)
end)


RegisterServerEvent('esx_policejob:handcuff')
AddEventHandler('esx_policejob:handcuff', function(target, playerheading, playerCoords, playerlocation)
	local xPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if xPlayer.job.name == 'police' then
		--TriggerClientEvent('esx_policejob:handcuff', target)
		TriggerClientEvent('esx_policejob:getarrested', target, playerheading, playerCoords, playerlocation)
    	TriggerClientEvent('esx_policejob:doarrested', source)
		
		local sendToDiscord2 = '' .. xPlayer.name .. ' ได้ใส่กุญแจมือ ' .. targetXPlayer.name .. ''
		TriggerEvent('azael_dc-serverlogs:insertData', 'handcuff', sendToDiscord2, targetXPlayer.source, '^4')
	else
		print(('esx_policejob: %s attempted to handcuff a player (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_policejob:unhandcuff')
AddEventHandler('esx_policejob:unhandcuff', function(target, playerheading, playerCoords, playerlocation)
	local xPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if xPlayer.job.name == 'police' then
		--TriggerClientEvent('esx_policejob:handcuff', target)
		-- TriggerClientEvent('esx_policejob:drag', target, source)
		TriggerClientEvent('esx_policejob:getuncuffed', target, playerheading, playerCoords, playerlocation)
    	TriggerClientEvent('esx_policejob:douncuffing', source)
	
		local sendToDiscord2 = '' .. xPlayer.name .. ' ได้ปลดกุญแจมือ ' .. targetXPlayer.name .. ''
		TriggerEvent('azael_dc-serverlogs:insertData', 'handcuff', sendToDiscord2, targetXPlayer.source, '^4')
	else
		print(('esx_policejob: %s attempted to handcuff a player (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_policejob:key_unhandcuff')
AddEventHandler('esx_policejob:key_unhandcuff', function(target, playerheading, playerCoords, playerlocation)
	local xPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	TriggerClientEvent('esx_policejob:getuncuffed', target, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('esx_policejob:douncuffing', source)
	
	local sendToDiscord2 = '' .. xPlayer.name .. ' ได้ใช้กุญแจผีปลดมือ ' .. targetXPlayer.name .. ''
	TriggerEvent('azael_dc-serverlogs:insertData', 'handcuff', sendToDiscord2, targetXPlayer.source, '^1')
end)

RegisterServerEvent('esx_policejob:SendDrag')
AddEventHandler('esx_policejob:SendDrag', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'police' then
		TriggerClientEvent('esx_policejob:drag', target, source)
	else
		print(('esx_policejob: %s attempted to drag (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_policejob:putInVehicle')
AddEventHandler('esx_policejob:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'police' then
		TriggerClientEvent('esx_policejob:putInVehicle', target)
	else
		print(('esx_policejob: %s attempted to put in vehicle (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_policejob:OutVehicle')
AddEventHandler('esx_policejob:OutVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'police' then
		TriggerClientEvent('esx_policejob:OutVehicle', target)
	else
		print(('esx_policejob: %s attempted to drag out from vehicle (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_policejob:getStockItem')
AddEventHandler('esx_policejob:getStockItem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_police', function(inventory)

		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then
		
			-- can the player carry the said amount of x item?
			if not xPlayer.canCarryItem(itemName, count) then
				TriggerClientEvent("pNotify:SendNotification", _source, {
					text = 'ของชิ้นนี้ของคุณเต็ม',
					type = "error",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
			else
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent("pNotify:SendNotification", _source, {
					text = _U('have_withdrawn', count, inventoryItem.label),
					type = "success",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
			end
		else
			TriggerClientEvent("pNotify:SendNotification", _source, {
				text = 'จำนวนที่ไม่ถูกต้อง',
				type = "error",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		end
	end)

end)

RegisterServerEvent('esx_policejob:putStockItems')
AddEventHandler('esx_policejob:putStockItems', function(itemName, count)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_police', function(inventory)
		if itemName then
			inventory.addItem(itemName, count)
		else
			TriggerClientEvent("pNotify:SendNotification", source, {
				text = 'จำนวนที่ไม่ถูกต้อง',
				type = "error",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		end
	end)
end)

ESX.RegisterServerCallback('esx_policejob:getFineList', function(source, cb, category)
	MySQL.Async.fetchAll('SELECT * FROM fine_types WHERE category = @category', {
		['@category'] = category
	}, function(fines)
		cb(fines)
	end)
end)

ESX.RegisterServerCallback('esx_policejob:getVehicleInfos', function(source, cb, plate)

	MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)

		local retrivedInfo = {
			plate = plate
		}

		if result[1] then

			MySQL.Async.fetchAll('SELECT name, firstname, lastname FROM users WHERE identifier = @identifier',  {
				['@identifier'] = result[1].owner
			}, function(result2)

				if Config.EnableESXIdentity then
					retrivedInfo.owner = result2[1].firstname .. ' ' .. result2[1].lastname
				else
					retrivedInfo.owner = result2[1].name
				end

				cb(retrivedInfo)
			end)
		else
			cb(retrivedInfo)
		end
	end)
end)

function string:split(delimiter)
	local result = { }
	local from  = 1
	local delim_from, delim_to = string.find( self, delimiter, from  )
	while delim_from do
	  table.insert( result, string.sub( self, from , delim_from-1 ) )
	  from  = delim_to + 1
	  delim_from, delim_to = string.find( self, delimiter, from  )
	end
	table.insert( result, string.sub( self, from  ) )
	return result
  end

ESX.RegisterServerCallback('esx_policejob:getVehicleByName', function(source, cb, name)
	local FullName = name.split(name," +")
	MySQL.Async.fetchAll('SELECT * FROM users WHERE firstname = @firstname AND lastname = @lastname', {
		['@firstname'] = FullName[1],
		['@lastname'] = FullName[2],
	}, function(result)
		if result[1] ~= nil then

			MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @identifier',  {
				['@identifier'] = result[1].identifier
			}, function(result2)
				cb(result2, true)
				

			end)
		else
			cb(_U('unknown'), false)
		end
	end)
end)

ESX.RegisterServerCallback('esx_policejob:getHouseByName', function(source, cb, name)
	local FullName = name.split(name," +")
	MySQL.Async.fetchAll('SELECT * FROM users WHERE firstname = @firstname AND lastname = @lastname', {
		['@firstname'] = FullName[1],
		['@lastname'] = FullName[2],
	}, function(result)
		if result[1] ~= nil then

			MySQL.Async.fetchAll("SELECT * FROM owned_properties WHERE owner = @identifier", {
				['@identifier'] = result[1].identifier,
			}, function(result2)
	
				cb(result2, true)
	
			end)

		else
			cb(_U('unknown'), false)
		end
	end)
end)

ESX.RegisterServerCallback('esx_policejob:getVehicleFromPlate', function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)
		if result[1] ~= nil then

			MySQL.Async.fetchAll('SELECT name, firstname, lastname FROM users WHERE identifier = @identifier',  {
				['@identifier'] = result[1].owner
			}, function(result2)

				if Config.EnableESXIdentity then
					cb(result2[1].firstname .. ' ' .. result2[1].lastname, true)
				else
					cb(result2[1].name, true)
				end

			end)
		else
			cb(_U('unknown'), false)
		end
	end)
end)

ESX.RegisterServerCallback('esx_policejob:getArmoryWeapons', function(source, cb)

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_police', function(store)
		local weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end

		cb(weapons)
	end)

end)

ESX.RegisterServerCallback('esx_policejob:addArmoryWeapon', function(source, cb, weaponName, removeWeapon)

	local xPlayer = ESX.GetPlayerFromId(source)

	if removeWeapon then
		xPlayer.removeWeapon(weaponName)
	end

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_police', function(store)

		local weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end

		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = weapons[i].count + 1
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name  = weaponName,
				count = 1
			})
		end

		store.set('weapons', weapons)
		cb()
	end)

end)

ESX.RegisterServerCallback('esx_policejob:removeArmoryWeapon', function(source, cb, weaponName)

	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.addWeapon(weaponName, 500)

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_police', function(store)

		local weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end

		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name  = weaponName,
				count = 0
			})
		end

		store.set('weapons', weapons)
		cb()
	end)

end)

ESX.RegisterServerCallback('esx_policejob:buyWeapon', function(source, cb, weaponName, type, componentNum)
	local xPlayer = ESX.GetPlayerFromId(source)
	local authorizedWeapons, selectedWeapon = Config.AuthorizedWeapons[xPlayer.job.grade_name]

	for k,v in ipairs(authorizedWeapons) do
		if v.weapon == weaponName then
			selectedWeapon = v
			break
		end
	end

	if not selectedWeapon then
		print(('esx_policejob: %s attempted to buy an invalid weapon.'):format(xPlayer.identifier))
		cb(false)
	end

	-- Weapon
	if type == 1 then
	
		local GetCoinDuty = xPlayer.getInventoryItem(Config.CoinDutyName)
	

		if GetCoinDuty.count >= selectedWeapon.items and xPlayer.getMoney() >= selectedWeapon.price then
			local GetCoinDuty = xPlayer.getInventoryItem(Config.CoinDutyName)
			
			xPlayer.removeMoney(selectedWeapon.price)
			xPlayer.removeInventoryItem(Config.CoinDutyName, selectedWeapon.items)
			xPlayer.addWeapon(weaponName, 100)

			local sendToDiscord = '' .. xPlayer.name .. ' ซื้อ ' .. ESX.GetWeaponLabel(weaponName) .. ' และ กระสุน จำนวน 100 ในราคา ' .. ESX.Math.GroupDigits(selectedWeapon.price) .. '$ และใช้เหรียญเข้าเวรจำนวน ' .. selectedWeapon.items .. ' เหรียญ'
			TriggerEvent('azael_dc-serverlogs:insertData', 'PoliceBuyWeapon', sendToDiscord, xPlayer.source, '^4')

			cb(true)
		else
			cb(false)
		end

	-- Weapon Component
	elseif type == 2 then
		local price = selectedWeapon.components[componentNum]
		local weaponNum, weapon = ESX.GetWeapon(weaponName)

		local component = weapon.components[componentNum]

		if component then
			if xPlayer.getMoney() >= price then
				xPlayer.removeMoney(price)
				xPlayer.addWeaponComponent(weaponName, component.name)

				local sendToDiscord = '' .. xPlayer.name .. ' ซื้อ ' .. component.label .. ' ส่วนประกอบของอาวุธ ' .. ESX.GetWeaponLabel(weaponName) .. ' ราคา $' .. ESX.Math.GroupDigits(price)  .. ''
				TriggerEvent('azael_dc-serverlogs:insertData', 'PoliceBuyWeapon', sendToDiscord, xPlayer.source, '^5')

				cb(true)
			else
				cb(false)
			end
		else
			print(('esx_policejob: %s attempted to buy an invalid weapon component.'):format(xPlayer.identifier))
			cb(false)
		end
	end
end)


ESX.RegisterServerCallback('esx_policejob:buyJobVehicle', function(source, cb, vehicleProps, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = getPriceFromHash(vehicleProps.model, xPlayer.job.grade_name, type)

	-- vehicle model not found
	if price == 0 then
		print(('esx_policejob: %s attempted to exploit the shop! (invalid vehicle model)'):format(xPlayer.identifier))
		cb(false)
	end

	if xPlayer.getMoney() >= price then
		xPlayer.removeMoney(price)
		TriggerClientEvent("esx_inventoryhud:getOwnerVehicle", source)
		MySQL.Async.execute('INSERT INTO owned_vehicles (owner, vehicle, plate, type, job, `stored`) VALUES (@owner, @vehicle, @plate, @type, @job, @stored)', {
			['@owner'] = xPlayer.identifier,
			['@vehicle'] = json.encode(vehicleProps),
			['@plate'] = vehicleProps.plate,
			['@type'] = type,
			['@job'] = xPlayer.job.name,
			['@stored'] = true
		}, function (rowsChanged)
			cb(true)
		end)
		
		exports.nc_garage:AddVehicle(vehicleProps.plate)
		exports["xbase_invenkeys"]:AddNewPlate(source, vehicleProps.plate)
		exports.nc_vehiclestorage:ChangeVehicleOwner(vehicleProps.plate, xPlayer.identifier)
		
		local sendToDiscord = '' .. xPlayer.name .. ' ซื้อรถ ' .. vehicleProps.model .. ' ทะเบียน ' .. vehicleProps.plate .. ' ราคา $' .. ESX.Math.GroupDigits(price) .. ''
		TriggerEvent('azael_dc-serverlogs:insertData', 'PoliceBuyVehicle', sendToDiscord, xPlayer.source, '^2')

	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('esx_policejob:storeNearbyVehicle', function(source, cb, nearbyVehicles)
	local xPlayer = ESX.GetPlayerFromId(source)
	local foundPlate, foundNum

	for k,v in ipairs(nearbyVehicles) do
		local result = MySQL.Sync.fetchAll('SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate AND job = @job', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = v.plate,
			['@job'] = xPlayer.job.name
		})

		if result[1] then
			foundPlate, foundNum = result[1].plate, k
			break
		end
	end

	if not foundPlate then
		cb(false)
	else
		MySQL.Async.execute('UPDATE owned_vehicles SET `stored` = true WHERE owner = @owner AND plate = @plate AND job = @job', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = foundPlate,
			['@job'] = xPlayer.job.name
		}, function (rowsChanged)
			if rowsChanged == 0 then
				print(('esx_policejob: %s has exploited the garage!'):format(xPlayer.identifier))
				cb(false)
			else
				cb(true, foundNum)
			end
		end)
	end

end)

function getPriceFromHash(hashKey, jobGrade, type)
	if type == 'helicopter' then
		local vehicles = Config.AuthorizedHelicopters[jobGrade]

		for k,v in ipairs(vehicles) do
			if GetHashKey(v.model) == hashKey then
				return v.price
			end
		end
	elseif type == 'car' then
		local vehicles = Config.AuthorizedVehicles[jobGrade]
		local shared = Config.AuthorizedVehicles['Shared']

		for k,v in ipairs(vehicles) do
			if GetHashKey(v.model) == hashKey then
				return v.price
			end
		end

		for k,v in ipairs(shared) do
			if GetHashKey(v.model) == hashKey then
				return v.price
			end
		end
	end

	return 0
end

ESX.RegisterServerCallback('esx_policejob:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_police', function(inventory)
		cb(inventory.items)
	end)
end)

ESX.RegisterServerCallback('esx_policejob:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb( { items = items } )
end)

AddEventHandler('playerDropped', function()
	-- Save the source in case we lose it (which happens a lot)
	
	local _source = source
	
	-- Did the player ever join?
	if _source ~= nil then
		local xPlayer = ESX.GetPlayerFromId(_source)
		
		-- Is it worth telling all clients to refresh?
		if xPlayer ~= nil and xPlayer.job ~= nil and xPlayer.job.name == 'police' then
			Citizen.Wait(5000)
			TriggerClientEvent('esx_policejob:updateBlip', -1)
		end
	end	
end)

RegisterServerEvent('esx_policejob:spawned')
AddEventHandler('esx_policejob:spawned', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if xPlayer ~= nil and xPlayer.job ~= nil and xPlayer.job.name == 'police' then
		Citizen.Wait(5000)
		TriggerClientEvent('esx_policejob:updateBlip', -1)
	end
end)

RegisterServerEvent('esx_policejob:forceBlip')
AddEventHandler('esx_policejob:forceBlip', function()
	TriggerClientEvent('esx_policejob:updateBlip', -1)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(5000)
		TriggerClientEvent('esx_policejob:updateBlip', -1)
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('esx_phone:removeNumber', 'police')
	end
end)

RegisterServerEvent('esx_policejob:message')
AddEventHandler('esx_policejob:message', function(target, msg)
	TriggerClientEvent("pNotify:SendNotification", target, {
		text = msg,
		type = "success",
		timeout = 3000,
		layout = "bottomCenter",
		queue = "global"
	})
end)

RegisterServerEvent('esx_policejob:body_search')
AddEventHandler('esx_policejob:body_search', function(source, target)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xtarget = ESX.GetPlayerFromId(target)
	local sourcename = GetPlayerName(source)
	local targetname = GetPlayerName(target)
	print(xPlayer.name,xtarget.name)

	TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
		text = "คุณกำลังค้นตัว "..xtarget.name.."",
		type = "warning",
		timeout = 5000,
		layout = "bottomCenter",
		queue = "global"
	})

	local sendToDiscord = ''..sourcename..' กำลังค้นตัว ' ..targetname .. ''
	TriggerEvent('azael_dc-serverlogs:insertData', 'PoliceBodySearch', sendToDiscord, xPlayer.source, '^5')

	TriggerClientEvent("pNotify:SendNotification", xtarget.source, {
		text = "คุณกำลังถูกค้นตัวโดย "..xPlayer.name.."",
		type = "warning",
		timeout = 5000,
		layout = "bottomCenter",
		queue = "global"
	})
	local sendToDiscord = ''..targetname..' กำลังถูก ' ..sourcename .. ' ค้นตัว'
	TriggerEvent('azael_dc-serverlogs:insertData', 'PoliceBodySearch', sendToDiscord, xPlayer.source, '^5')
end)


RegisterServerEvent('Bosssetjobpolice:police')
AddEventHandler('Bosssetjobpolice:police', function(target, data)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xtarget = ESX.GetPlayerFromId(target)
	
	if xPlayer.job.grade > 3 then
		xtarget.setJob('police', data) 
		TriggerClientEvent("pNotify:SendNotification", target, {
			text = '<span class="red-text">คุณได้ยศเป็นตำรวจระดับ' ..data..'</span> ',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
		TriggerClientEvent("pNotify:SendNotification", source, {
			text = '<span class="red-text">แต่งตั้งยศแล้ว</span> ',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
	else
		TriggerClientEvent("pNotify:SendNotification", source, {
			text = '<span class="red-text">ระดับของคุณไม่เพียงพอ</span> ',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
	end
end)

RegisterServerEvent('Bosssetjobpolice:unemployed')
AddEventHandler('Bosssetjobpolice:unemployed', function(target, data)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xtarget = ESX.GetPlayerFromId(target)
	
	if xPlayer.job.grade > 3 then
		xtarget.setJob('unemployed', data) 
		TriggerClientEvent("pNotify:SendNotification", target, {
			text = '<span class="red-text">คุณถูกปลดยศ</span> ',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
		TriggerClientEvent("pNotify:SendNotification", source, {
			text = '<span class="red-text">ปลดยศแล้ว</span> ',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
	else
		TriggerClientEvent("pNotify:SendNotification", source, {
			text = '<span class="red-text">ระดับของคุณไม่เพียงพอ</span> ',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
	end
end)

RegisterServerEvent('UpgradeJob1')
AddEventHandler('UpgradeJob1', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local black_money = xPlayer.getAccount('black_money').money
	local amount = Config.Upgrade.upgradejob.Upto1
	if black_money < amount then
		notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~คุุณมีเงินแดงไม่พอ')
	else
		if xPlayer.job.grade == 1 then
		 	notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~ระดับยศ 1 อยู่แล้ว')
		elseif xPlayer.job.grade > 1 then
			notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~ต้องการระดับ 0 เท่านั้น')
		elseif xPlayer.job.grade == 0 then
			xPlayer.setJob('police', 1)
			xPlayer.removeAccountMoney('black_money', amount)
			notification('<font face="FC-Lamoon-Regular-ver-1.00">~g~เปลี่ยนยศเป็นระดับ 1 แล้ว')
		end
	end
end)

RegisterServerEvent('UpgradeJob2')
AddEventHandler('UpgradeJob2', function()

	local xPlayer = ESX.GetPlayerFromId(source)
	local black_money = xPlayer.getAccount('black_money').money
	local amount = Config.Upgrade.upgradejob.Upto2

	if black_money < amount then
		notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~คุุณมีเงินแดงไม่พอ')
	else
		if xPlayer.job.grade == 2 then
		 	notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~ระดับยศ 2 อยู่แล้ว')
		elseif xPlayer.job.grade == 0 then
			notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~ต้องการระดับ 1 เท่านั้น')
		elseif xPlayer.job.grade > 2 then
			notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~ต้องการระดับ 1 เท่านั้น')
		elseif xPlayer.job.grade == 1 then
			xPlayer.setJob('police', 2)
			xPlayer.removeAccountMoney('black_money', amount)
			notification('<font face="FC-Lamoon-Regular-ver-1.00">~g~เปลี่ยนยศเป็นระดับ 2 แล้ว')
		end
	end
end)

RegisterServerEvent('UpgradeJob3')
AddEventHandler('UpgradeJob3', function()

	local xPlayer = ESX.GetPlayerFromId(source)
	local black_money = xPlayer.getAccount('black_money').money
	local amount = Config.Upgrade.upgradejob.Upto3

	if black_money < amount then
		notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~คุุณมีเงินแดงไม่พอ')
	else
		if xPlayer.job.grade == 3 then
		 	notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~ระดับยศ 3 อยู่แล้ว')
		elseif xPlayer.job.grade == 0 or xPlayer.job.grade == 1 then
			notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~ต้องการระดับ 2 เท่านั้น')
		elseif xPlayer.job.grade > 3 then
			notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~ต้องการระดับ 2 เท่านั้น')
		elseif xPlayer.job.grade == 2 then
			xPlayer.setJob('police', 3)
			xPlayer.removeAccountMoney('black_money', amount)
			notification('<font face="FC-Lamoon-Regular-ver-1.00">~g~เปลี่ยนยศเป็นระดับ 3 แล้ว')
		end
	end
end)

RegisterServerEvent('UpgradeJob4')
AddEventHandler('UpgradeJob4', function()

	local xPlayer = ESX.GetPlayerFromId(source)
	local black_money = xPlayer.getAccount('black_money').money
	local amount = Config.Upgrade.upgradejob.Upto4

	if black_money < amount then
		notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~คุุณมีเงินแดงไม่พอ')
	else
		if xPlayer.job.grade == 4 then
		 	notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~ระดับยศ 4 อยู่แล้ว')
		elseif xPlayer.job.grade == 0 or xPlayer.job.grade == 1 or xPlayer.job.grade == 2 then
			notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~ต้องการระดับ 3 เท่านั้น')
		elseif xPlayer.job.grade > 4 then
			notification('<font face="FC-Lamoon-Regular-ver-1.00">~r~ต้องการระดับ 3 เท่านั้น')
		elseif xPlayer.job.grade == 3 then
			xPlayer.setJob('police', 4)
			xPlayer.removeAccountMoney('black_money', amount)
			notification('<font face="FC-Lamoon-Regular-ver-1.00">~g~เปลี่ยนยศเป็นระดับ 4 แล้ว')
		end
	end
end)

function notification(text)
	TriggerClientEvent('esx:showNotification', source, text)
end

RegisterServerEvent('esx_policejob:checkplate')
AddEventHandler('esx_policejob:checkplate', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	MySQL.Async.fetchAll('SELECT `plate`, `owner` FROM owned_vehicles ORDER BY `owner` DESC LIMIT 20', {

	}, function(result)
		for _,v in pairs(result) do
			if plate == v.plate then
				local ownercar = v.owner
				local player = ESX.GetPlayerFromIdentifier(ownercar)
				xPlayer.triggerEvent('esx_policejob:detechPlate', player.name)
			end
		end
	end)
end)

RegisterServerEvent('esx_policejob:GetBillPlayer')
AddEventHandler('esx_policejob:GetBillPlayer', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)
	local name = xTarget.name
	MySQL.Async.fetchAll('SELECT amount, id, label FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xTarget.identifier,
	}, function(data)
		if data[1] ~= nil then
			xPlayer.triggerEvent('esx_policejob:showbill', data, name)
		else
			xPlayer.triggerEvent("pNotify:SendNotification", {
                text = 'ไม่มีบิลค้างชำระ',
                type = "error",
                timeout = 3000,
                layout = "bottomCenter",
                queue = "global"
            })
		end
	end)
end)

RegisterServerEvent('esx_policejob:delbill')
AddEventHandler('esx_policejob:delbill', function(target, id)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)
	MySQL.Async.execute('DELETE FROM billing WHERE (identifier, id) = (@identifier, @id)', {
		['@identifier'] = xTarget.identifier,
		['@id'] = id,
	}, function(del)
		xTarget.triggerEvent("pNotify:SendNotification", {
			text = 'ถูกลบบิลออกแล้ว',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
		xPlayer.triggerEvent("pNotify:SendNotification", {
			text = 'ลบบิลออกแล้ว',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})


	end)

end)

RegisterServerEvent('esx_policejob:getAccount')
AddEventHandler('esx_policejob:getAccount', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT `money_vault` FROM jobs WHERE name = @name', {
		['@name'] = xPlayer.job.name
    }, function(data)
        
        local money = data[1].money_vault
        xPlayer.triggerEvent('esx_policejob:Account', money)
    end)
end)

RegisterServerEvent('esx_policejob:withdraw_money')
AddEventHandler('esx_policejob:withdraw_money', function(count)
    local xPlayer = ESX.GetPlayerFromId(source)
    --ดึงข้อมูลจาก data base
    MySQL.Async.fetchAll('SELECT `money_vault` FROM jobs WHERE name = @name', {
		['@name'] = xPlayer.job.name
    }, function(result)
        
        local datamoney = result[1].money_vault
        
		if tonumber(datamoney) >= tonumber(count) then

			MySQL.Async.fetchAll("UPDATE jobs SET money_vault = @money_vault WHERE name = @name",{
				['@money_vault'] = datamoney - count,
				['@name'] = xPlayer.job.name
			})

			xPlayer.addMoney(count)
		else
			xPlayer.triggerEvent('pNotify:SendNotification', {
				text = "จำนวนเงินในคลังไม่พอที่จะถอน😃",
				type = "error",
				queue = "center",
				timeout = 3000,
				layout = "bottomCenter"
			})
		end
            
    end)
end)

RegisterServerEvent('esx_policejob:deposit_money')
AddEventHandler('esx_policejob:deposit_money', function(count)
	local xPlayer = ESX.GetPlayerFromId(source)
    --ดึงข้อมูลจาก data base
    MySQL.Async.fetchAll('SELECT `money_vault` FROM jobs WHERE name = @name', {
		['@name'] = xPlayer.job.name
    }, function(result)
        local money = result[1].money_vault
        -- --บันทึกลง database
        if xPlayer.getMoney() <= count then
			xPlayer.triggerEvent('pNotify:SendNotification', {
				text = "จำนวนเงินของคุณไม่พอที่จะฝาก😃",
				type = "error",
				queue = "center",
				timeout = 3000,
				layout = "bottomCenter"
			})
			return
		else
            MySQL.Async.fetchAll("UPDATE jobs SET money_vault = @money_vault WHERE name = @name",{
                ['@money_vault'] = money + count,
				['@name'] = xPlayer.job.name
            })
			xPlayer.removeMoney(count)
        end
    end)
end)

RegisterServerEvent('esx_policejob:removemoney')
AddEventHandler('esx_policejob:removemoney', function(type, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	if type == 'money' then
		xPlayer.removeMoney(count)
	elseif type == 'bank' then
		xPlayer.removeAccountMoney('bank', count)
	end
end)

RegisterServerEvent('esx_policejob:GetDepartMent')
AddEventHandler('esx_policejob:GetDepartMent', function()
	local xxx = {}
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	MySQL.Async.fetchAll('SELECT * FROM users WHERE job = @job', {
		['@job'] = xPlayer.job.name
    }, function(result)
		if result[1] ~= nil then
			for k, v in pairs(result) do
				local xTarget = ESX.GetPlayerFromIdentifier(v.identifier)

				if xTarget then
					table.insert(xxx, {online = true, id = xTarget.source, name = xTarget.name, grade = xTarget.job.grade})
				else
					table.insert(xxx, {online = false, id = v.identifier, name = ''..v.firstname..' '..v.lastname..'', grade = v.job_grade})
				end
			end
			--TriggerClientEvent('esx_policejob:SetDepartment', xPlayer.source, json.encode(xxx))
			TriggerClientEvent('esx_policejob:SetDepartment', xPlayer.source, xxx)
		end
	end)
end)

ESX.RegisterServerCallback('esx_policejob:getjob', function(source, cb, job)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = @job_name', {
		['@job_name'] = job
    }, function(result)
		cb(result)
	end)
end)

RegisterServerEvent('esx_policejob:SetJobPlayer_online')
AddEventHandler('esx_policejob:SetJobPlayer_online', function(playerId, job, grade)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(playerId)
	xTarget.setJob(job, grade)
	MySQL.Async.fetchAll("UPDATE users SET job = @job, job_grade = @job_grade WHERE identifier = @identifier",{
		['@job'] = job,
		['@job_grade'] = tonumber(grade),
		['identifier'] = xTarget.identifier
	})
	Wait(100)
	xPlayer.triggerEvent('pNotify:SendNotification', {
		text = ""..xTarget.name.." ได้เป็น "..xTarget.job.label.." ยศ "..xTarget.job.grade_name,
		type = "success",
		queue = "center",
		timeout = 3000,
		layout = "bottomCenter"
	})
end)

RegisterServerEvent('esx_policejob:SetJobPlayer_offline')
AddEventHandler('esx_policejob:SetJobPlayer_offline', function(playerId, job, grade)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromIdentifier(playerId)
	if xTarget then
		xTarget.setJob(job, grade)
	end

	MySQL.Async.fetchAll("UPDATE users SET job = @job, job_grade = @job_grade WHERE identifier = @identifier",{
		['@job'] = job,
		['@job_grade'] = tonumber(grade),
		['identifier'] = playerId
	})

	Wait(100)

	xPlayer.triggerEvent('pNotify:SendNotification', {
		text = "จัดการเรียบร้อย",
		type = "success",
		queue = "center",
		timeout = 3000,
		layout = "bottomCenter"
	})
end)

RegisterServerEvent('esx_policejob:setJobforid')
AddEventHandler('esx_policejob:setJobforid', function(id, job)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(id)
	if xTarget then
		xTarget.setJob(job, 0)
	else
		xPlayer.triggerEvent('pNotify:SendNotification', {
			text = "ไม่มีไอดีนี้",
			type = "error",
			queue = "center",
			timeout = 3000,
			layout = "bottomCenter"
		})
	end

end)

ESX.RegisterUsableItem('handcuffs_key', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('esx_policejob:unhandcuff_item', source)
	xPlayer.removeInventoryItem('handcuffs_key', 1)
end)

RegisterServerEvent('esx_policejob:money_fix')
AddEventHandler('esx_policejob:money_fix', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(Config.FixMoney)
end)

----------------------------------------------------------------------------------------

ESX.RegisterCommand({'cry'}, 'admin', function(xPlayer, args, showError)
	xPlayer.triggerEvent('CarryPeople:command')
end, true, {help = ''})

local carrying = {}
local carried = {}

RegisterServerEvent("CarryPeople:sync")
AddEventHandler("CarryPeople:sync", function(targetSrc)
	local source = source
	local sourcePed = GetPlayerPed(source)
   	local sourceCoords = GetEntityCoords(sourcePed)
	local targetPed = GetPlayerPed(targetSrc)
        local targetCoords = GetEntityCoords(targetPed)
	if #(sourceCoords - targetCoords) <= 3.0 then 
		TriggerClientEvent("CarryPeople:syncTarget", targetSrc, source)
		carrying[source] = targetSrc
		carried[targetSrc] = source
	end
end)

RegisterServerEvent("CarryPeople:stop")
AddEventHandler("CarryPeople:stop", function(targetSrc)
	local source = source

	if carrying[source] then
		TriggerClientEvent("CarryPeople:cl_stop", targetSrc)
		carrying[source] = nil
		carried[targetSrc] = nil
	elseif carried[source] then
		TriggerClientEvent("CarryPeople:cl_stop", carried[source])			
		carrying[carried[source]] = nil
		carried[source] = nil
	end
end)

AddEventHandler('playerDropped', function(reason)
	local source = source
	
	if carrying[source] then
		TriggerClientEvent("CarryPeople:cl_stop", carrying[source])
		carried[carrying[source]] = nil
		carrying[source] = nil
	end

	if carried[source] then
		TriggerClientEvent("CarryPeople:cl_stop", carried[source])
		carrying[carried[source]] = nil
		carried[source] = nil
	end
end)

----------------------------------------------------------------------------------------

RegisterServerEvent("esx_policejob:sendAnnoucePolice")
AddEventHandler("esx_policejob:sendAnnoucePolice", function(TextAnnouce)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    local msg = TextAnnouce
	
	if xPlayer.job.name == 'police' then
		TriggerClientEvent('chat:addMessage', -1, {
			template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(4, 0, 255, 0.5); border-radius: 20px;"><i class="fas fa-bullhorn"></i> POLICE : {1}</div>',
			args = { fal, msg }
		})
	end
end)

