ESX = exports["es_extended"]:getSharedObject()

local AccountsIndex  = {}
local Accounts       = {}
local SharedAccounts = {}



if Config.MaxInService ~= -1 then
	TriggerEvent('esx_service:activateService', 'council', Config.MaxInService)
end

TriggerEvent('esx_society:registerSociety', 'council', 'council', 'society_mod', 'society_mod', 'society_mod', {type = 'public'})

ESX.RegisterServerCallback('esx_counciljob:getVehicleFrommod', function (source, cb)
	MySQL.Async.fetchAll('SELECT *, date_format(time, "%Y-%m-%d") AS time FROM owned_vehicles WHERE council = @council', {
		['@council'] =1
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
				council		  = result[i].council,
				mod_by		  = result[i].mod_by,
				time		  = result[i].time
			})
		end

		cb(vehicles)
	end)
end)

RegisterServerEvent('esx_counciljob:updateVehicleFrommod')
AddEventHandler('esx_counciljob:updateVehicleFrommod', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('UPDATE owned_vehicles SET `council` = @council, `mod_by` = @mod_by, `time` = NOW() WHERE plate = @plate', {
		['@council'] = 1,
		['@plate'] = plate,
		['@mod_by'] = xPlayer.name
	}, function(rowsChanged)
		if rowsChanged == 0 then
			print("ERROR Update setVehicleFrommod")
		end
	end)
end)


RegisterServerEvent('esx_counciljob:setVehicleFrommod')
AddEventHandler('esx_counciljob:setVehicleFrommod', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('UPDATE owned_vehicles SET `stored` = @stored, `council` = @council, `mod_by` = @mod_by WHERE plate = @plate', {
		['@stored'] = false,
		['@council'] = 0,
		['@plate'] = plate,
		['@mod_by'] = nil
	}, function(rowsChanged)
		if rowsChanged == 0 then
			print("ERROR Update setVehicleFrommod")
		end
	end)
end)

RegisterServerEvent('esx_counciljob:confiscatePlayerItem')
AddEventHandler('esx_counciljob:confiscatePlayerItem', function(target, itemType, itemName, amount)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	-- if sourceXPlayer.job.name ~= 'council' then
	-- 	print(('esx_counciljob: %s attempted to confiscate!'):format(xPlayer.identifier))
	-- 	return
	-- end
	
	if amount == nil then
		TriggerClientEvent("pNotify:SendNotification", _source, {
			text = 'ปริมาณที่ไม่ถูกต้อง',
			type = "error",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
		return
	end

	if sourceXPlayer.job.name == "council" then
		TriggerEvent('new_discordbot:modsearch', sourceXPlayer.getName(), targetXPlayer.getName(), itemName, amount, itemType)
	else
		TriggerEvent('new_discordbot:playerthife', sourceXPlayer.getName(), targetXPlayer.getName(), itemName, amount, itemType)
	end

	if itemType == 'item_standard' then
		local targetItem = targetXPlayer.getInventoryItem(itemName)
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)

		if targetItem.count > 0 then

			if targetItem.count < amount then

				TriggerClientEvent("pNotify:SendNotification", _source, {
					text = 'จำนวนที่ไม่ถูกต้อง',
					type = "error",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})

			else
				
				if sourceItem.limit ~= -1 and (sourceItem.count + amount) > sourceItem.limit then
					TriggerClientEvent("pNotify:SendNotification", target, {
						text = 'ช่องเก็บของมีพื้นที่ไม่เพียงพอ',
						type = "error",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				else
					targetXPlayer.removeInventoryItem(itemName, amount)
					sourceXPlayer.addInventoryItem(itemName, amount)
					TriggerClientEvent("pNotify:SendNotification", _source, {
						text = 'คุณได้ริบ <strong class="amber-text">'..sourceItem.label..'</strong> จำนวน <strong class="amber-text">'..amount..'</strong> ของคุณ <strong class="blue-text">'..targetXPlayer.name..'</strong> เรียบร้อยแล้ว',
						type = "success",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
					TriggerClientEvent("pNotify:SendNotification", target, {
						text = 'บางคน <strong class="amber-text">'..sourceItem.label..'</strong> จำนวน <strong class="amber-text">'..amount..'</strong> ออกจากกระเป๋าคุณ',
						type = "success",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				end
			end
		else
			TriggerClientEvent("pNotify:SendNotification", _source, {
				text = 'ผู้เล่นไม่มีไอเทม '..targetItem.label..'',
				type = "error",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		end
	elseif itemType == 'item_money' then
		if amount <= 0 then
			TriggerClientEvent("pNotify:SendNotification", _source, {
				text = 'จำนวนที่ไม่ถูกต้อง',
				type = "error",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		else

			local targetMoney = ESX.GetPlayerFromId(targetXPlayer.source).getMoney()
			
			if targetMoney < amount then
				TriggerClientEvent("pNotify:SendNotification", _source, {
					text = 'จำนวนที่ไม่ถูกต้อง',
					type = "error",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
			else

				targetXPlayer.removeMoney(amount)
				sourceXPlayer.addMoney (amount)

				TriggerClientEvent("pNotify:SendNotification", _source, {
					text = 'คุณได้ริบ <strong class="amber-text">เงินสด</strong> จำนวน <strong class="amber-text">'..amount..'</strong> ของคุณ <strong class="blue-text">'..targetXPlayer.name..'</strong> เรียบร้อยแล้ว',
					type = "success",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
				TriggerClientEvent("pNotify:SendNotification", target, {
					text = 'บางคน <strong class="amber-text">เงินสด</strong> จำนวน <strong class="amber-text">'..amount..'</strong> ออกจากกระเป๋าคุณ',
					type = "success",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
			end

		end
	elseif itemType == 'item_account' then
		if amount <= 0 then
			TriggerClientEvent("pNotify:SendNotification", _source, {
				text = 'จำนวนที่ไม่ถูกต้อง'..amount,
				type = "error",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		else

			local targetMoney = targetXPlayer.getAccount(itemName).money

			if targetMoney < amount then
				TriggerClientEvent("pNotify:SendNotification", _source, {
					text = 'จำนวนที่ไม่ถูกต้อง',
					type = "error",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
			else

				targetXPlayer.removeAccountMoney(itemName, amount)
				sourceXPlayer.addAccountMoney(itemName, amount)

				TriggerClientEvent("pNotify:SendNotification", _source, {
					text = 'คุณได้ริบ <strong class="amber-text">'..itemName..'</strong> จำนวน <strong class="amber-text">'..amount..'</strong> ของคุณ <strong class="blue-text">'..targetXPlayer.name..'</strong> เรียบร้อยแล้ว',
					type = "success",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
				TriggerClientEvent("pNotify:SendNotification", target, {
					text = 'บางคน <strong class="amber-text">'..itemName..'</strong> จำนวน <strong class="amber-text">'..amount..'</strong> ออกจากกระเป๋าคุณ',
					type = "success",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})

			end

		end
	elseif itemType == 'item_weapon' then
		if amount == nil then amount = 0 end
		targetXPlayer.removeWeapon(itemName, amount)
		sourceXPlayer.addWeapon(itemName, amount)

		TriggerClientEvent("pNotify:SendNotification", _source, {
			text = 'คุณได้ริบ <strong class="amber-text">'..ESX.GetWeaponLabel(itemName)..'</strong> จำนวนกระสุน <strong class="amber-text">'..amount..'</strong> ของคุณ <strong class="blue-text">'..targetXPlayer.name..'</strong> เรียบร้อยแล้ว',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
		TriggerClientEvent("pNotify:SendNotification", target, {
			text = 'บางคน <strong class="amber-text">'..ESX.GetWeaponLabel(itemName)..'</strong> จำนวนกระสุน <strong class="amber-text">'..amount..'</strong> ออกจากกระเป๋าคุณ',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
	elseif itemType == "item_key" then -- MEETA GiveKey

		MySQL.Async.execute("UPDATE owned_vehicles SET owner = @newplayer WHERE owner = @identifier AND plate = @plate",
		{
			['@newplayer']		= sourceXPlayer.identifier,
			['@identifier']		= targetXPlayer.identifier,
			['@plate']		= itemName
		})
		
		TriggerClientEvent("pNotify:SendNotification", _source, {
			text = 'คุณได้ริบ <strong class="amber-text">กุญแจรถ</strong> ทะเบียน <strong class="yellow-text">'..itemName..'</strong>',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
		TriggerClientEvent("pNotify:SendNotification", target, {
			text = 'บางคน <strong class="amber-text">กุญแจรถ</strong> ทะเบียน <strong class="yellow-text">'..itemName..'</strong> ออกจากกระเป๋าคุณ',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
		
		TriggerClientEvent("esx_inventoryhud:getOwnerVehicle", _source)
		TriggerClientEvent("esx_inventoryhud:getOwnerVehicle", target)

	elseif itemType == "item_keyhouse" then -- MEETA GiveKeyHouse

		MySQL.Async.execute("UPDATE owned_properties SET owner = @newplayer WHERE owner = @identifier AND id = @id",
		{
			['@newplayer']		= sourceXPlayer.identifier,
			['@identifier']		= targetXPlayer.identifier,
			['@id']		= itemName
		})

		TriggerClientEvent("pNotify:SendNotification", _source, {
			text = 'คุณได้ริบ <strong class="amber-text">กุญแจบ้าน</strong>',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
		TriggerClientEvent("pNotify:SendNotification", target, {
			text = 'บางคน <strong class="amber-text">กุญแจบ้าน</strong> ถูกยึดโดย <strong class="blue-text">'.. sourceXPlayer.name ..'</strong> ออกจากกระเป๋าคุณ',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
		
		TriggerClientEvent("esx_inventoryhud:getOwnerHouse", _source)
		TriggerClientEvent("esx_inventoryhud:getOwnerHouse", target)

	end
end)

RegisterServerEvent('esx_counciljob:handcuff')
AddEventHandler('esx_counciljob:handcuff', function(target, playerheading, playerCoords, playerlocation)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'council' then
		--TriggerClientEvent('esx_counciljob:handcuff', target)
		TriggerClientEvent('esx_counciljob:getarrested', target, playerheading, playerCoords, playerlocation)
    	TriggerClientEvent('esx_counciljob:doarrested', source)
	else
		print(('esx_counciljob: %s attempted to handcuff a player (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_counciljob:unhandcuff')
AddEventHandler('esx_counciljob:unhandcuff', function(target, playerheading, playerCoords, playerlocation)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'council' then
		--TriggerClientEvent('esx_counciljob:handcuff', target)
		TriggerClientEvent('esx_counciljob:getuncuffed', target, playerheading, playerCoords, playerlocation)
    	TriggerClientEvent('esx_counciljob:douncuffing', source)
	else
		print(('esx_counciljob: %s attempted to handcuff a player (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_counciljob:drag')
AddEventHandler('esx_counciljob:drag', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'council' then
		TriggerClientEvent('esx_counciljob:drag', target, source)
	else
		print(('esx_counciljob: %s attempted to drag (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_counciljob:putInVehicle')
AddEventHandler('esx_counciljob:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'council' then
		TriggerClientEvent('esx_counciljob:putInVehicle', target)
	else
		print(('esx_counciljob: %s attempted to put in vehicle (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_counciljob:OutVehicle')
AddEventHandler('esx_counciljob:OutVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'council' then
		TriggerClientEvent('esx_counciljob:OutVehicle', target)
	else
		print(('esx_counciljob: %s attempted to drag out from vehicle (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_counciljob:getStockItem')
AddEventHandler('esx_counciljob:getStockItem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mod', function(inventory)

		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then
		
			-- can the player carry the said amount of x item?
			if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
				TriggerClientEvent("pNotify:SendNotification", _source, {
					text = 'จำนวนที่ไม่ถูกต้อง',
					type = "success",
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
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		end
	end)

end)

RegisterServerEvent('esx_counciljob:putStockItems')
AddEventHandler('esx_counciljob:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mod', function(inventory)

		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent("pNotify:SendNotification", source, {
				text = _U('have_withdrawn', count, inventoryItem.label),
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		else
			TriggerClientEvent("pNotify:SendNotification", source, {
				text = 'จำนวนที่ไม่ถูกต้อง',
				type = "success",
				timeout = 3000,
				layout = "bottomCenter",
				queue = "global"
			})
		end

	end)

end)

ESX.RegisterServerCallback('esx_counciljob:getOtherPlayerData', function(source, cb, target)

	if Config.EnableESXIdentity then

		local xPlayer = ESX.GetPlayerFromId(target)

		MySQL.Async.fetchAll('SELECT firstname, lastname, sex, dateofbirth, height FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(result)
			local firstname = result[1] and result[1].firstname or ''
			local lastname  = result[1] and result[1].lastname or ''
			local sex       = result[1] and result[1].sex or ''
			local dob       = result[1] and result[1].dateofbirth or ''
			local height    = result[1] and result[1].height or ''

			local data = {
				name      = GetPlayerName(target),
				job       = xPlayer.job,
				inventory = xPlayer.inventory,
				accounts  = xPlayer.accounts,
				weapons   = xPlayer.loadout,
				firstname = firstname,
				lastname  = lastname,
				sex       = sex,
				dob       = dob,
				height    = height
			}

			TriggerEvent('esx_status:getStatus', target, 'drunk', function(status)
				if status ~= nil then
					data.drunk = math.floor(status.percent)
				end
			end)

			if Config.EnableLicenses then
				TriggerEvent('esx_license:getLicenses', target, function(licenses)
					data.licenses = licenses
					cb(data)
				end)
			else
				cb(data)
			end
		end)

	else

		local xPlayer = ESX.GetPlayerFromId(target)

		local data = {
			name       = GetPlayerName(target),
			job        = xPlayer.job,
			inventory  = xPlayer.inventory,
			accounts   = xPlayer.accounts,
			weapons    = xPlayer.loadout
		}

		TriggerEvent('esx_status:getStatus', target, 'drunk', function(status)
			if status ~= nil then
				data.drunk = math.floor(status.percent)
			end
		end)

		TriggerEvent('esx_license:getLicenses', target, function(licenses)
			data.licenses = licenses
		end)

		cb(data)

	end

end)

ESX.RegisterServerCallback('esx_counciljob:getFineList', function(source, cb, category)
	MySQL.Async.fetchAll('SELECT * FROM fine_types WHERE category = @category', {
		['@category'] = category
	}, function(fines)
		cb(fines)
	end)
end)

ESX.RegisterServerCallback('esx_counciljob:getVehicleInfos', function(source, cb, plate)

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

ESX.RegisterServerCallback('esx_counciljob:getVehicleByName', function(source, cb, name)
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

ESX.RegisterServerCallback('esx_counciljob:getHouseByName', function(source, cb, name)
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

ESX.RegisterServerCallback('esx_counciljob:getVehicleFromPlate', function(source, cb, plate)
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

ESX.RegisterServerCallback('esx_counciljob:getArmoryWeapons', function(source, cb)

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_mod', function(store)
		local weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end

		cb(weapons)
	end)

end)

ESX.RegisterServerCallback('esx_counciljob:addArmoryWeapon', function(source, cb, weaponName, removeWeapon)

	local xPlayer = ESX.GetPlayerFromId(source)

	if removeWeapon then
		xPlayer.removeWeapon(weaponName)
	end

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_mod', function(store)

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

ESX.RegisterServerCallback('esx_counciljob:removeArmoryWeapon', function(source, cb, weaponName)

	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.addWeapon(weaponName, 500)

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_mod', function(store)

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

ESX.RegisterServerCallback('esx_counciljob:buyWeapon', function(source, cb, weaponName, type, componentNum)
	local xPlayer = ESX.GetPlayerFromId(source)
	local authorizedWeapons, selectedWeapon = Config.AuthorizedWeapons[xPlayer.job.grade_name]

	for k,v in ipairs(authorizedWeapons) do
		if v.weapon == weaponName then
			selectedWeapon = v
			break
		end
	end

	if not selectedWeapon then
		print(('esx_counciljob: %s attempted to buy an invalid weapon.'):format(xPlayer.identifier))
		cb(false)
	end

	-- Weapon
	if type == 1 then
		if xPlayer.getMoney() >= selectedWeapon.price then
			xPlayer.removeMoney(selectedWeapon.price)
			xPlayer.addWeapon(weaponName, 100)

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

				cb(true)
			else
				cb(false)
			end
		else
			print(('esx_counciljob: %s attempted to buy an invalid weapon component.'):format(xPlayer.identifier))
			cb(false)
		end
	end
end)


ESX.RegisterServerCallback('esx_counciljob:buyJobVehicle', function(source, cb, vehicleProps, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = getPriceFromHash(vehicleProps.model, xPlayer.job.grade_name, type)

	-- vehicle model not found
	if price == 0 then
		print(('esx_counciljob: %s attempted to exploit the shop! (invalid vehicle model)'):format(xPlayer.identifier))
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

	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('esx_counciljob:storeNearbyVehicle', function(source, cb, nearbyVehicles)
	local xPlayer = ESX.GetPlayerFromId(source)
	local foundPlate, foundNum

	for k,v in ipairs(nearbyVehicles) do
		local result = MySQL.query.await('SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate AND job = @job', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = v.plate,
			['@job'] = xPlayer.job.name
		})

		if result and result[1] then
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
				print(('esx_counciljob: %s has exploited the garage!'):format(xPlayer.identifier))
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

ESX.RegisterServerCallback('esx_counciljob:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mod', function(inventory)
		cb(inventory.items)
	end)
end)

ESX.RegisterServerCallback('esx_counciljob:getPlayerInventory', function(source, cb)
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
		if xPlayer ~= nil and xPlayer.job ~= nil and xPlayer.job.name == 'council' then
			Citizen.Wait(5000)
			TriggerClientEvent('esx_counciljob:updateBlip', -1)
		end
	end	
end)

RegisterServerEvent('esx_counciljob:spawned')
AddEventHandler('esx_counciljob:spawned', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if xPlayer ~= nil and xPlayer.job ~= nil and xPlayer.job.name == 'council' then
		Citizen.Wait(5000)
		TriggerClientEvent('esx_counciljob:updateBlip', -1)
	end
end)

RegisterServerEvent('esx_counciljob:forceBlip')
AddEventHandler('esx_counciljob:forceBlip', function()
	TriggerClientEvent('esx_counciljob:updateBlip', -1)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(5000)
		TriggerClientEvent('esx_counciljob:updateBlip', -1)
	end
end)

RegisterServerEvent('esx_counciljob:message')
AddEventHandler('esx_counciljob:message', function(target, msg)
	TriggerClientEvent("pNotify:SendNotification", target, {
		text = msg,
		type = "success",
		timeout = 3000,
		layout = "bottomCenter",
		queue = "global"
	})
end)


RegisterServerEvent("esx_counciljob:sendAnnoucecouncil")
AddEventHandler("esx_counciljob:sendAnnoucecouncil", function(TextAnnouce)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    local msg = TextAnnouce
	
	if xPlayer.job.name == 'council' or xPlayer.job.name == 'admin' then
		TriggerClientEvent('chat:addMessage', -1, {
			template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(45, 45, 45, 0.8); border-radius: 20px;"><i class="fas fa-landmark"></i> COUNCIL : {1}</div>',
			args = { fal, msg }
		})
	end
end)



RegisterServerEvent('esx_counciljob:GetDepartMent')
AddEventHandler('esx_counciljob:GetDepartMent', function()
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
			TriggerClientEvent('esx_counciljob:SetDepartment', xPlayer.source, xxx)
		end
	end)
end)


RegisterServerEvent('esx_counciljob:SetJobPlayer_online')
AddEventHandler('esx_counciljob:SetJobPlayer_online', function(playerId, job, grade)
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


RegisterServerEvent('esx_counciljob:SetJobPlayer_offline')
AddEventHandler('esx_counciljob:SetJobPlayer_offline', function(playerId, job, grade)
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

RegisterServerEvent('esx_counciljob:setJobforid')
AddEventHandler('esx_counciljob:setJobforid', function(id, job)
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