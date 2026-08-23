ESX = exports["es_extended"]:getSharedObject()

local playersHealing = {}
local playerAED = {}


RegisterServerEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		if Config.ReviveReward > 1 then
			xPlayer.addMoney(Config.ReviveReward)
		end
		TriggerClientEvent('esx_ambulancejob:revive', target)

		local xTarget = ESX.GetPlayerFromId(target)
		

		local sendToDiscord = ''	.. xPlayer.name .. ' ชุบชีวิต ' .. xTarget.name .. ''
		TriggerEvent('azael_dc-serverlogs:insertData', 'DocRevive', sendToDiscord, source, '^5')
	else
		print(('esx_ambulancejob: %s attempted to revive!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent(GetCurrentResourceName()..':drag')
AddEventHandler(GetCurrentResourceName()..':drag', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)	
	local xtarget = ESX.GetPlayerFromId(target)
	xtarget.triggerEvent(GetCurrentResourceName()..':dragPlayer', source)
	xPlayer.triggerEvent(GetCurrentResourceName()..':animation')	
end)

RegisterServerEvent(GetCurrentResourceName()..':clearbodyAreaSV')
AddEventHandler(GetCurrentResourceName()..':clearbodyAreaSV', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)	
	local xtarget = ESX.GetPlayerFromId(target)
	
	xtarget.triggerEvent(GetCurrentResourceName()..':clearbodyAreaCL', source)
end)

RegisterServerEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(target, type)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('esx_ambulancejob:heal', target, type)

		local xPlayer = ESX.GetPlayerFromId(target)

		local sendToDiscord = ''	.. xPlayer.name .. ' ทำการรักษา ' .. xPlayer.name .. ''
		TriggerEvent('azael_dc-serverlogs:insertData', 'DocHeal', sendToDiscord, xPlayer.source, '^5')

		Citizen.Wait(100)

		local sendToDiscord = ''	.. xPlayer.name .. ' ได้รับการรักษา จาก ' .. xPlayer.name .. ''
		TriggerEvent('azael_dc-serverlogs:insertData', 'DocHeal', sendToDiscord, xPlayer.source, '^2')
	else
		print(('esx_ambulancejob: %s attempted to heal!'):format(xPlayer.identifier))
	end
end)




RegisterServerEvent('esx_ambulancejob:putInVehicle')
AddEventHandler('esx_ambulancejob:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('esx_ambulancejob:putInVehicle', target)
	else
		print(('esx_ambulancejob: %s attempted to put in vehicle!'):format(xPlayer.identifier))
	end
end)

TriggerEvent('esx_phone:registerNumber', 'ambulance', _U('alert_ambulance'), true, true)
TriggerEvent('esx_society:registerSociety', 'ambulance', 'Ambulance', 'society_ambulance', 'society_ambulance', 'society_ambulance', {type = 'public'})


ESX.RegisterServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.RemoveCashAfterRPDeath then
		if xPlayer.getInventoryItem(Config.ProtectItems).count < 1 then
			local xMoney, xDirtyMoney = xPlayer.getMoney(), xPlayer.getAccount('black_money').money

			if xPlayer.getMoney() > 0 then
				xPlayer.removeMoney(xPlayer.getMoney())
			end

			if xPlayer.getAccount('black_money').money > 0 then
				xPlayer.setAccountMoney('black_money', 0)
			end
		else
			xPlayer.removeInventoryItem(Config.ProtectItems, 1)
		end
	end

	if Config.RemoveItemsAfterRPDeath then
		if xPlayer.getInventoryItem(Config.ProtectItems).count < 1 then
			local uniqueItemsName = findUniqueStrings(Config.ItemsNotRemoveWhenDeath, itemSQL)
			for k, v in ipairs(uniqueItemsName) do
				if xPlayer.getInventoryItem(v).count > 0 then
					xPlayer.setInventoryItem(v, 0)
				end
			end
		else
			xPlayer.removeInventoryItem(Config.ProtectItems, 1)
		end
	end

	
	local playerLoadout = {}
	if Config.RemoveWeaponsAfterRPDeath then
		for i=1, #xPlayer.loadout, 1 do
			local xItem = xPlayer.getInventoryItem(Config.ProtectItems)
			if xItem.count < 1 then
				ExchangeWeapon(xPlayer.loadout[i].name, xPlayer)
			else
				xPlayer.removeInventoryItem(xItem.name, 1)
				TriggerClientEvent("pNotify:SendNotification", source, {
					text = "คุณได้ใช้บัตรป้องกันอาวุธหาย!!",
					type = "success",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
			end
		end
	else -- save weapons & restore em' since spawnmanager removes them
		for i=1, #xPlayer.loadout, 1 do
			table.insert(playerLoadout, xPlayer.loadout[i])
		end

		-- give back wepaons after a couple of seconds
		Citizen.CreateThread(function()
			Citizen.Wait(5000)
			for i=1, #playerLoadout, 1 do
				if playerLoadout[i].label ~= nil then
					xPlayer.addWeapon(playerLoadout[i].name, playerLoadout[i].ammo)
				end
			end
		end)
	end
	
	
	cb()
end)


ExchangeWeapon = function(weapon_name, xPlayer)
	for k,v in pairs(Config.WeaponDropLevel) do
		if xPlayer.getWeapon(weapon_name) then
			if v.lv0 == weapon_name then
				if xPlayer.getWeapon(v.lv0) then
					xPlayer.removeWeapon(weapon_name)
				end
			end

			if v.lv1 == weapon_name then
				if xPlayer.getWeapon(v.lv1) then
					xPlayer.removeWeapon(weapon_name)
					xPlayer.addWeapon(v.lv0, 1)
				end
			end

			if v.lv2 == weapon_name then
				if xPlayer.getWeapon(v.lv2) then
					xPlayer.removeWeapon(weapon_name)
					xPlayer.addWeapon(v.lv1, 1)
				end
			end
			
			if v.lv3 == weapon_name then
				if xPlayer.getWeapon(v.lv3) then
					xPlayer.removeWeapon(weapon_name)
					xPlayer.addWeapon(v.lv2, 1)
				end
			end
			
			if v.lv4 == weapon_name then
				if xPlayer.getWeapon(v.lv4) then
					xPlayer.removeWeapon(weapon_name)
					xPlayer.addWeapon(v.lv3, 1)
				end
			end
			
			if v.lv5 == weapon_name then
				if xPlayer.getWeapon(v.lv5) then
					xPlayer.removeWeapon(weapon_name)
					xPlayer.addWeapon(v.lv4, 1)
				end
			end
			
		end
	end
end



if Config.EarlyRespawnFine then
	ESX.RegisterServerCallback('esx_ambulancejob:checkBalance', function(source, cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		local bankBalance = xPlayer.getAccount('bank').money

		cb(bankBalance >= Config.EarlyRespawnFineAmount)
	end)

	RegisterServerEvent('esx_ambulancejob:payFine')
	AddEventHandler('esx_ambulancejob:payFine', function()
		local xPlayer = ESX.GetPlayerFromId(source)
		local fineAmount = Config.EarlyRespawnFineAmount

		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('respawn_bleedout_fine_msg', ESX.Math.GroupDigits(fineAmount)))
		xPlayer.removeAccountMoney('bank', fineAmount)
	end)
end

ESX.RegisterServerCallback('esx_ambulancejob:getItemAmount', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local quantity = xPlayer.getInventoryItem(item).count

	cb(quantity)
end)

ESX.RegisterServerCallback('esx_ambulancejob:buyJobVehicle', function(source, cb, vehicleProps, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = getPriceFromHash(vehicleProps.model, xPlayer.job.grade_name, type)

	-- vehicle model not found
	if price == 0 then
		print(('esx_ambulancejob: %s attempted to exploit the shop! (invalid vehicle model)'):format(xPlayer.identifier))
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

	
		local sendToDiscord = ''	.. xPlayer.name .. ' ซื้อรถ ' .. vehicleProps.model .. ' ทะเบียน ' .. vehicleProps.plate .. ' ราคา $' .. ESX.Math.GroupDigits(price) .. ''
		TriggerEvent('azael_dc-serverlogs:insertData', 'DocBuyCar', sendToDiscord, xPlayer.source, '^2')
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('esx_ambulancejob:storeNearbyVehicle', function(source, cb, nearbyVehicles)
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
				print(('esx_ambulancejob: %s has exploited the garage!'):format(xPlayer.identifier))
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

		for k,v in ipairs(vehicles) do
			if GetHashKey(v.model) == hashKey then
				return v.price
			end
		end
	end

	return 0
end

RegisterServerEvent('esx_ambulancejob:removeItem')
AddEventHandler('esx_ambulancejob:removeItem', function(item)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem(item, 1)

	if item == 'bandage' then
		TriggerClientEvent('esx:showNotification', _source, _U('used_bandage'))
	elseif item == 'medikit' then
		TriggerClientEvent('esx:showNotification', _source, _U('used_medikit'))
	end

	local sendToDiscord = '' .. xPlayer.name .. ' ใช้ ' .. ESX.GetItemLabel(item) .. ' จำนวน 1'
	TriggerEvent('azael_dc-serverlogs:insertData', 'DocRemoveItem', sendToDiscord, xPlayer.source, '^2')
end)

RegisterServerEvent('esx_ambulancejob:giveItem')
AddEventHandler('esx_ambulancejob:giveItem', function(itemName)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name ~= 'ambulance' then
		print(('esx_ambulancejob: %s attempted to spawn in an item!'):format(xPlayer.identifier))
		return
	elseif (itemName ~= 'medikit' and itemName ~= 'bandage') then
		print(('esx_ambulancejob: %s attempted to spawn in an item!'):format(xPlayer.identifier))
		return
	end

	local xItem = xPlayer.getInventoryItem(itemName)
	local count = 1

	if xPlayer.canCarryItem(xItem.name, count) then
		xPlayer.addInventoryItem(itemName, count)

		local sendToDiscord = '' .. xPlayer.name .. ' เบิก ' .. xItem.label .. ' จำนวน ' .. ESX.Math.GroupDigits(count) .. ''
		TriggerEvent('azael_dc-serverlogs:insertData', 'DocGiveItem', sendToDiscord, xPlayer.source, '^2')
	else
		TriggerClientEvent('esx:showNotification', source, _U('max_item'))
	end
end)


ESX.RegisterUsableItem('medikit', function(source)
 	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.job.name == 'ambulance' then
		if not playersHealing[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			xPlayer.removeInventoryItem('medikit', 1)
		
			playersHealing[source] = true
			TriggerClientEvent('esx_ambulancejob:useItem', source, 'medikit')

			Citizen.Wait(10000)
			playersHealing[source] = nil
		end
	else
		TriggerClientEvent("pNotify:SendNotification", _source, {
			text = 'ไม่สามารถใช้ได้ คุณไม่ใช่แพทย์',
			type = "error",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
	end
end)



RegisterServerEvent('esx_ambulancejob:getDead')
AddEventHandler('esx_ambulancejob:getDead', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	
	MySQL.Async.fetchScalar('SELECT is_dead FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(isDead)
		if isDead then
			xPlayer.triggerEvent('esx_ambulancejob:SetDead')
		end
	end)
end)

RegisterServerEvent('esx_ambulancejob:setDeathStatus')
AddEventHandler('esx_ambulancejob:setDeathStatus', function(isDead)
	local identifier = GetPlayerIdentifiers(source)[1]
	local xPlayer = ESX.GetPlayerFromId(source)

	if type(isDead) ~= 'boolean' then
		print(('esx_ambulancejob: %s attempted to parse something else than a boolean to setDeathStatus!'):format(identifier))
		return
	end

	MySQL.Sync.execute('UPDATE users SET is_dead = @isDead WHERE identifier = @identifier', {
		['@identifier'] = identifier,
		['@isDead'] = isDead
	})
end)



RegisterServerEvent('Bosssetjob:ambulance')
AddEventHandler('Bosssetjob:ambulance', function(target, data)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xtarget = ESX.GetPlayerFromId(target)
	
	
	xtarget.setJob('ambulance', data) 
	TriggerClientEvent("pNotify:SendNotification", target, {
		text = '<span class="red-text">คุณได้ยศเป็นหมอระดับ' ..data..'</span> ',
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
end)

RegisterServerEvent('Bosssetjob:unemployed')
AddEventHandler('Bosssetjob:unemployed', function(target, data)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xtarget = ESX.GetPlayerFromId(target)
	
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
end)

ESX.RegisterServerCallback('esx_ambulancejob:getOtherPlayerData', function(source, cb, target)

	if Config.EnableESXIdentity then

		local xPlayer = ESX.GetPlayerFromId(target)

		local result = MySQL.Sync.fetchAll('SELECT firstname, lastname, sex, dateofbirth, height FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		})

		local firstname = result[1].firstname
		local lastname  = result[1].lastname
		local sex       = result[1].sex
		local dob       = result[1].dateofbirth
		local height    = result[1].height

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

		if Config.EnableLicenses then
			TriggerEvent('esx_license:getLicenses', target, function(licenses)
				data.licenses = licenses
				cb(data)
			end)
		else
			cb(data)
		end

	else

		local xPlayer = ESX.GetPlayerFromId(target)

		local data = {
			name       = GetPlayerName(target),
			job        = xPlayer.job,
			inventory  = xPlayer.inventory,
			accounts   = xPlayer.accounts,
			weapons    = xPlayer.loadout
		}


		TriggerEvent('esx_license:getLicenses', target, function(licenses)
			data.licenses = licenses
		end)

		cb(data)

	end

end)



RegisterServerEvent(GetCurrentResourceName()..':carryPlayerSV')
AddEventHandler(GetCurrentResourceName()..':carryPlayerSV', function(taget, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(taget)
	xPlayer.triggerEvent(GetCurrentResourceName()..':Animcarry', type, xTarget.name, xTarget.source)
	xTarget.triggerEvent(GetCurrentResourceName()..':Attach_Carry', type, xPlayer.source)
end)


RegisterServerEvent('esx_ambulancejob:removemoney')
AddEventHandler('esx_ambulancejob:removemoney', function(type, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	if type == 'money' then
		xPlayer.removeMoney(count)
	elseif type == 'bank' then
		xPlayer.removeAccountMoney('bank', count)
	end
end)



RegisterServerEvent('esx_ambulancejob:reviveAED')
AddEventHandler('esx_ambulancejob:reviveAED', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)
	
	TriggerClientEvent('esx_ambulancejob:revive', target)
	
	local sendToDiscord = '' .. xPlayer.name .. ' ใช้ AED จำนวน 1' .. ' ชุบผู้เล่น ' .. xTarget.name 
	TriggerEvent('azael_dc-serverlogs:insertData', 'useAED', sendToDiscord, source, '^2')
end)

RegisterServerEvent('esx_ambulancejob:RemoveItem')
AddEventHandler('esx_ambulancejob:RemoveItem', function(ItemRemove)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(ItemRemove, 1)
end)


RegisterServerEvent('esx_ambulancejob:TimeOutDie')
AddEventHandler('esx_ambulancejob:TimeOutDie', function()

	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerClientEvent('chat:addMessage', -1, {
        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(249, 77, 140, 1); border-radius: 20px;"><font size="3.7">ประกาศ : มีผู้เล่นตายจนหมดเวลา เข้าตู้กระจกเวลา 1 ชั่วโมง!!</font></div>',
		args = { fal, msg }
	})
	
	local sendToDiscord = '' .. xPlayer.name .. ' ตายจนหมดเวลา เข้าตู้กระจกเวลา 1 ชั่วโมง!!'
	TriggerEvent('azael_dc-serverlogs:insertData', 'TimeOutDie', sendToDiscord, xPlayer.source, '^4')

end)


RegisterServerEvent('meeta_ambulance:put_cloth')
AddEventHandler('meeta_ambulance:put_cloth', function(target)
	TriggerClientEvent('meeta_ambulance:put_cloth', target)
end)

RegisterServerEvent('meeta_ambulance:unput_cloth')
AddEventHandler('meeta_ambulance:unput_cloth', function(target)
	TriggerClientEvent('meeta_ambulance:unput_cloth', target)
end)


RegisterServerEvent('esx_ambulance:GetDepartMent')
AddEventHandler('esx_ambulance:GetDepartMent', function()
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
			
			TriggerClientEvent('esx_ambulance:SetDepartment', xPlayer.source, xxx)
		end
	end)
end)

RegisterServerEvent('esx_ambulance:setJobforid')
AddEventHandler('esx_ambulance:setJobforid', function(id, job)
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


RegisterServerEvent('esx_ambulance:SetJobPlayer_online')
AddEventHandler('esx_ambulance:SetJobPlayer_online', function(playerId, job, grade)
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

RegisterServerEvent('esx_ambulance:SetJobPlayer_offline')
AddEventHandler('esx_ambulance:SetJobPlayer_offline', function(playerId, job, grade)
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

ESX.RegisterServerCallback('esx_ambulance:getjob', function(source, cb, job)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = @job_name', {
		['@job_name'] = job
    }, function(result)
		cb(result)
	end)
end)


RegisterServerEvent("esx_ambulancejob:sendAnnouceMedical")
AddEventHandler("esx_ambulancejob:sendAnnouceMedical", function(TextAnnouce)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    local msg = TextAnnouce
	
	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('chat:addMessage', -1, {
			template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255, 0, 89, 0.5); border-radius: 20px;"><i class="fas fa-heartbeat"></i> HOSPITAL : {1}</div>',
			args = { fal, msg }
    })
	end
end)


function findUniqueStrings(array1, array2)
	local uniqueStrings = {}

	local set = {}
	for _, str in ipairs(array1) do
		set[str] = true
	end

	for _, str in ipairs(array2) do
		if not set[str] then
		table.insert(uniqueStrings, str)
		end
	end

	return uniqueStrings
end



local itemSQL = {}
MySQL.ready(function()
	AllItemsList = MySQL.Sync.fetchAll("SELECT * FROM `items`", {})
	for k,v in pairs(AllItemsList) do
		table.insert(itemSQL, v.name)
	end
end)



--============== Command Ambulance ==============--


ESX.RegisterCommand({'healall'}, 'admin', function(xPlayer, args, showError)
	TriggerClientEvent('esx_ambulancejob:heal', -1)
	
end, true, {help = 'เพิ่มเลือดให้ทั้งเซิฟ'})

ESX.RegisterCommand({'foodall'}, 'admin', function(xPlayer, args, showError)
	TriggerClientEvent('esx_ambulancejob:healfood', -1)
	
end, true, {help = 'เพิ่มอาหารทั้งเซิฟ'})

ESX.RegisterCommand('heal', 'admin', function(xPlayer, args, showError)
    args.playerId.triggerEvent('esx_ambulancejob:heal')
end, true, {help = 'เพิ่มเลือด', validate = true, arguments = {
    {name = 'playerId', help = 'ใส่ ID', type = 'player'},
}})

ESX.RegisterCommand('food', 'admin', function(xPlayer, args, showError)
    args.playerId.triggerEvent('esx_ambulancejob:healfood')
	
end, true, {help = 'เพิ่มอาหาร', validate = true, arguments = {
    {name = 'playerId', help = 'ใส่ ID', type = 'player'},
}})

ESX.RegisterCommand({'reviveall'}, 'admin', function(xPlayer, args, showError)
	TriggerClientEvent('esx_ambulancejob:reviveall', -1)
	
end, true, {help = 'ชุบให้ทั้งเซิฟ'})


ESX.RegisterCommand('revive', 'admin', function(xPlayer, args, showError)
		args.playerId.triggerEvent('esx_ambulancejob:revive')
end, true, {help = 'ชุบ', validate = true, arguments = {
	{name = 'playerId', help = 'id', type = 'player'}
}})



RegisterCommand("alive", function(source, args, rawCommand) 
    if source ~= 0 then
		local xPlayer = ESX.GetPlayerFromId(source)
		local item = xPlayer.getInventoryItem('medikit')
		local ambulance = xPlayer.job.name == 'ambulance'
		if item.count > 0 then
			if ambulance == true then
				TriggerClientEvent('esx_ambulancejob:revive', source)
				xPlayer.removeInventoryItem('medikit', 1)

				local sendToDiscord = '' .. xPlayer.name .. ' อาชีพ ' .. xPlayer.job.name .. ' ได้ทำการชุบชีวิตตัวเอง '
				TriggerEvent('azael_dc-serverlogs:insertData', 'DocRevive', sendToDiscord, xPlayer.source, '^9')
			else
				TriggerClientEvent("pNotify:SendNotification", source, {
					text = 'คุณไม่ใช่หมอ จึงชุบตัวเองไม่ได้',
					type = "error",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
			end
		else
			TriggerClientEvent("pNotify:SendNotification", source, {
			text = 'คุณไม่ไม่มี '.. item.label ..'',
			type = "error",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
		end
    end
end, false)



ESX.RegisterUsableItem('bandage', function(source)
	local xPlayer  = ESX.GetPlayerFromId(source)
	if not playersHealing[source] then
		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeInventoryItem('bandage', 1)
	
		playersHealing[source] = true
		TriggerClientEvent('esx_ambulancejob:useItem', source, 'bandage')

		Citizen.Wait(Config.BandageTime * 1000)
		playersHealing[source] = nil
	end
end)



ESX.RegisterUsableItem('AED', function(source)
	local xPlayer  = ESX.GetPlayerFromId(source)
	if not playerAED[source] then
		local xPlayer  = ESX.GetPlayerFromId(source)
		
		playerAED[source] = true
		TriggerClientEvent('meeta_ambulance:cpr', source)
		
		Citizen.Wait(10000)
		playerAED[source] = nil
	end
end)