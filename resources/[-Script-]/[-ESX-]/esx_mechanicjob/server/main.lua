ESX = exports["es_extended"]:getSharedObject()
PlayersHarvesting  = {}
PlayersHarvesting2 = {}
PlayersHarvesting3 = {}
PlayersCrafting    = {}
PlayersCrafting2   = {}
PlayersCrafting3   = {}


if Config.MaxInService ~= -1 then
	TriggerEvent('esx_service:activateService', 'mechanic', Config.MaxInService)
end

TriggerEvent('esx_phone:registerNumber', 'mechanic', _U('mechanic_customer'), true, true)
TriggerEvent('esx_society:registerSociety', 'mechanic', 'mechanic', 'society_mechanic', 'society_mechanic', 'society_mechanic', {type = 'private'})

local function Harvest(source)
	SetTimeout(4000, function()

		if PlayersHarvesting[source] == true then
			local xPlayer = ESX.GetPlayerFromId(source)
			local GazBottleQuantity = xPlayer.getInventoryItem('gazbottle').count

			if GazBottleQuantity >= 5 then
				TriggerClientEvent('esx:showNotification', source, _U('you_do_not_room'))
			else
				xPlayer.addInventoryItem('gazbottle', 1)
				Harvest(source)

				local sendToDiscord = ''	.. xPlayer.name .. ' เบิก ' .. ESX.GetItemLabel('gazbottle') .. ' จำนวน 1'
				TriggerEvent('azael_discordlogs:sendToDiscord', 'MechanicHarvestItem', sendToDiscord, xPlayer.source, '^2')
			end
		end

	end)
end

RegisterServerEvent('esx_mechanicjob:startHarvest')
AddEventHandler('esx_mechanicjob:startHarvest', function()
	local _source = source
	PlayersHarvesting[_source] = true
	TriggerClientEvent('esx:showNotification', _source, _U('recovery_gas_can'))
	Harvest(source)
end)

RegisterServerEvent('esx_mechanicjob:stopHarvest')
AddEventHandler('esx_mechanicjob:stopHarvest', function()
	local _source = source
	PlayersHarvesting[_source] = false
end)

local function Harvest2(source)
	SetTimeout(4000, function()

		if PlayersHarvesting2[source] == true then
			local xPlayer = ESX.GetPlayerFromId(source)
			local FixToolQuantity = xPlayer.getInventoryItem('fixtool').count

			if FixToolQuantity >= 5 then
				TriggerClientEvent('esx:showNotification', source, _U('you_do_not_room'))
			else
				xPlayer.addInventoryItem('fixtool', 1)
				Harvest2(source)
				local sendToDiscord = ''	.. xPlayer.name .. ' เบิก ' .. ESX.GetItemLabel('fixtool') .. ' จำนวน 1'
				TriggerEvent('azael_discordlogs:sendToDiscord', 'MechanicHarvestItem', sendToDiscord, xPlayer.source, '^2')
			end
		end

	end)
end

RegisterServerEvent('esx_mechanicjob:startHarvest2')
AddEventHandler('esx_mechanicjob:startHarvest2', function()
	local _source = source
	PlayersHarvesting2[_source] = true
	TriggerClientEvent('esx:showNotification', _source, _U('recovery_repair_tools'))
	Harvest2(_source)
end)

RegisterServerEvent('esx_mechanicjob:stopHarvest2')
AddEventHandler('esx_mechanicjob:stopHarvest2', function()
	local _source = source
	PlayersHarvesting2[_source] = false
end)

local function Harvest3(source)
	SetTimeout(4000, function()

		if PlayersHarvesting3[source] == true then
			local xPlayer = ESX.GetPlayerFromId(source)
			local CaroToolQuantity = xPlayer.getInventoryItem('carotool').count
			if CaroToolQuantity >= 5 then
				TriggerClientEvent('esx:showNotification', source, _U('you_do_not_room'))
			else
				xPlayer.addInventoryItem('carotool', 1)
				Harvest3(source)
				local sendToDiscord = ''	.. xPlayer.name .. ' เบิก ' .. ESX.GetItemLabel('carotool') .. ' จำนวน 1'
				TriggerEvent('azael_discordlogs:sendToDiscord', 'MechanicHarvestItem', sendToDiscord, xPlayer.source, '^2')
			end
		end

	end)
end

RegisterServerEvent('esx_mechanicjob:startHarvest3')
AddEventHandler('esx_mechanicjob:startHarvest3', function()
	local _source = source
	PlayersHarvesting3[_source] = true
	TriggerClientEvent('esx:showNotification', _source, _U('recovery_body_tools'))
	Harvest3(_source)
end)

RegisterServerEvent('esx_mechanicjob:stopHarvest3')
AddEventHandler('esx_mechanicjob:stopHarvest3', function()
	local _source = source
	PlayersHarvesting3[_source] = false
end)

local function Craft(source)
	SetTimeout(4000, function()

		if PlayersCrafting[source] == true then
			local xPlayer = ESX.GetPlayerFromId(source)
			local GazBottleQuantity = xPlayer.getInventoryItem('gazbottle').count

			if GazBottleQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_gas_can'))
			else
				xPlayer.removeInventoryItem('gazbottle', 1)
				xPlayer.addInventoryItem('blowpipe', 1)
				Craft(source)
			end
		end

	end)
end

RegisterServerEvent('esx_mechanicjob:startCraft')
AddEventHandler('esx_mechanicjob:startCraft', function()
	local _source = source
	PlayersCrafting[_source] = true
	TriggerClientEvent('esx:showNotification', _source, _U('assembling_blowtorch'))
	Craft(_source)
end)

RegisterServerEvent('esx_mechanicjob:stopCraft')
AddEventHandler('esx_mechanicjob:stopCraft', function()
	local _source = source
	PlayersCrafting[_source] = false
end)

local function Craft2(source)
	SetTimeout(4000, function()

		if PlayersCrafting2[source] == true then
			local xPlayer = ESX.GetPlayerFromId(source)
			local FixToolQuantity = xPlayer.getInventoryItem('fixtool').count

			if FixToolQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_repair_tools'))
			else
				xPlayer.removeInventoryItem('fixtool', 1)
				xPlayer.addInventoryItem('fixkit', 1)
				Craft2(source)
			end
		end

	end)
end

RegisterServerEvent('esx_mechanicjob:startCraft2')
AddEventHandler('esx_mechanicjob:startCraft2', function()
	local _source = source
	PlayersCrafting2[_source] = true
	TriggerClientEvent('esx:showNotification', _source, _U('assembling_repair_kit'))
	Craft2(_source)
end)

RegisterServerEvent('esx_mechanicjob:stopCraft2')
AddEventHandler('esx_mechanicjob:stopCraft2', function()
	local _source = source
	PlayersCrafting2[_source] = false
end)

local function Craft3(source)
	SetTimeout(4000, function()

		if PlayersCrafting3[source] == true then
			local xPlayer = ESX.GetPlayerFromId(source)
			local CaroToolQuantity = xPlayer.getInventoryItem('carotool').count

			if CaroToolQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_body_tools'))
			else
				xPlayer.removeInventoryItem('carotool', 1)
				xPlayer.addInventoryItem('carokit', 1)
				Craft3(source)
			end
		end

	end)
end

RegisterServerEvent('esx_mechanicjob:startCraft3')
AddEventHandler('esx_mechanicjob:startCraft3', function()
	local _source = source
	PlayersCrafting3[_source] = true
	TriggerClientEvent('esx:showNotification', _source, _U('assembling_body_kit'))
	Craft3(_source)
end)

RegisterServerEvent('esx_mechanicjob:stopCraft3')
AddEventHandler('esx_mechanicjob:stopCraft3', function()
	local _source = source
	PlayersCrafting3[_source] = false
end)

RegisterServerEvent('esx_mechanicjob:onNPCJobMissionCompleted')
AddEventHandler('esx_mechanicjob:onNPCJobMissionCompleted', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total   = math.random(Config.NPCJobEarnings.min, Config.NPCJobEarnings.max);

	if xPlayer.job.grade >= 3 then
		total = total * 2
	end

	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
		account.addMoney(total)
	end)

	TriggerClientEvent("esx:showNotification", _source, _U('your_comp_earned').. total)
end)

-- ESX.RegisterUsableItem('blowpipe', function(source)
-- 	local _source = source
-- 	local xPlayer  = ESX.GetPlayerFromId(source)

-- 	xPlayer.removeInventoryItem('blowpipe', 1)

-- 	TriggerClientEvent('esx_mechanicjob:onHijack', _source)
-- 	TriggerClientEvent('esx:showNotification', _source, _U('you_used_blowtorch'))
-- end)

-- ESX.RegisterUsableItem('fixkit', function(source)
-- 	local _source = source
-- 	local xPlayer  = ESX.GetPlayerFromId(source)

-- 	xPlayer.removeInventoryItem('fixkit', 1)

-- 	TriggerClientEvent('esx_mechanicjob:onFixkit', _source)
-- 	TriggerClientEvent('esx:showNotification', _source, _U('you_used_repair_kit'))
-- end)

-- ESX.RegisterUsableItem('carokit', function(source)
-- 	local _source = source
-- 	local xPlayer  = ESX.GetPlayerFromId(source)

-- 	xPlayer.removeInventoryItem('carokit', 1)

-- 	TriggerClientEvent('esx_mechanicjob:onCarokit', _source)
-- 	TriggerClientEvent('esx:showNotification', _source, _U('you_used_body_kit'))
-- end)

RegisterServerEvent('esx_mechanicjob:getStockItem')
AddEventHandler('esx_mechanicjob:getStockItem', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mechanic', function(inventory)
		local item = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and item.count >= count then

			-- can the player carry the said amount of x item?
			if xPlayer.canCarryItem(itemName, count) then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				xPlayer.showNotification(_U('have_withdrawn', count, item.label))
			else
				xPlayer.showNotification(_U('player_cannot_hold'))
			end
		else
			xPlayer.showNotification(_U('invalid_quantity'))
		end
	end)
end)

-- ESX.RegisterServerCallback('esx_mechanicjob:getStockItems', function(source, cb)
-- 	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mechanic', function(inventory)
-- 		cb(inventory.items)
-- 	end)
-- end)

RegisterServerEvent('esx_mechanicjob:putStockItems')
AddEventHandler('esx_mechanicjob:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mechanic', function(inventory)
		local item = inventory.getItem(itemName)
		local playerItemCount = xPlayer.getInventoryItem(itemName).count

		if item.count >= 0 and count <= playerItemCount then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
		else
			xPlayer.showNotification(_U('invalid_quantity'))
		end

		xPlayer.showNotification(_U('have_deposited', count, item.label))
	end)
end)

-- ESX.RegisterServerCallback('esx_mechanicjob:getPlayerInventory', function(source, cb)
-- 	local xPlayer    = ESX.GetPlayerFromId(source)
-- 	local items      = xPlayer.inventory

-- 	cb({items = items})
-- end)

RegisterServerEvent('esx_mechanicjob:triggerBomb')
AddEventHandler('esx_mechanicjob:triggerBomb', function(ped, coords, veh)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem(Config.UseItem, 1)
	TriggerClientEvent('esx_mechanicjob:placeBomb', _source, ped, coords, veh)
end)

RegisterServerEvent('Bosssetjobmechanic:mechanic')
AddEventHandler('Bosssetjobmechanic:mechanic', function(target, data)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xtarget = ESX.GetPlayerFromId(target)
	
	if xPlayer.job.grade > 4 then
		xtarget.setJob('mechanic', data) 
		TriggerClientEvent("pNotify:SendNotification", target, {
			text = '<span class="red-text">คุณได้ยศเป็นช่างระดับ' ..data..'</span> ',
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

RegisterServerEvent('Bosssetjobmechanic:unemployed')
AddEventHandler('Bosssetjobmechanic:unemployed', function(target, data)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xtarget = ESX.GetPlayerFromId(target)
	
	if xPlayer.job.grade > 4 then
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

-- ESX.RegisterUsableItem('fixkit', function(source)
-- 	local _source = source
-- 	local xPlayer  = ESX.GetPlayerFromId(source)

-- 	xPlayer.removeInventoryItem('fixkit', 1)

-- 	TriggerClientEvent('esx_mechanicjob:onFixkit', _source)
-- 	TriggerClientEvent('esx:showNotification',source,('You use fixkit'))
-- end)

-- ESX.RegisterUsableItem('repairkit', function(source)
-- 	local xPlayer  = ESX.GetPlayerFromId(source)
-- 	TriggerClientEvent('esx_mechanicjob:Getcount', source)
-- end)

RegisterServerEvent('esx_mechanicjob:removeitem')
AddEventHandler('esx_mechanicjob:removeitem', function(itemName, count)
	local xPlayer 	= ESX.GetPlayerFromId(source)
	local xItem 	= xPlayer.getInventoryItem(itemName)
	if count <= 0 then return end
	xPlayer.removeInventoryItem(xItem.name, count)
end)


RegisterServerEvent("esx_mechanicjob:sendAnnouce")
AddEventHandler("esx_mechanicjob:sendAnnouce", function(TextAnnouce)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    local msg = TextAnnouce
	
	if xPlayer.job.name == 'mechanic' then
		TriggerClientEvent('chat:addMessage', -1, {
			template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255, 162, 40, 0.5); border-radius: 20px;"><i class="fas fa-wrench"></i> MECHANIC : {1}</div>',
			args = { fal, msg }
		})
	end
end)


RegisterServerEvent('esx_mechanicjob:GetDepartMent')
AddEventHandler('esx_mechanicjob:GetDepartMent', function()
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
			TriggerClientEvent('esx_mechanicjob:SetDepartment', xPlayer.source, xxx)
		end
	end)
end)

RegisterServerEvent('esx_mechanicjob:setJobforid')
AddEventHandler('esx_mechanicjob:setJobforid', function(id, job)
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

RegisterServerEvent('esx_mechanicjob:SetJobPlayer_online')
AddEventHandler('esx_mechanicjob:SetJobPlayer_online', function(playerId, job, grade)
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

ESX.RegisterServerCallback('esx_mechanicjob:getjob', function(source, cb, job)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = @job_name', {
		['@job_name'] = job
    }, function(result)
		cb(result)
	end)
end)

RegisterServerEvent('esx_mechanicjob:SetJobPlayer_offline')
AddEventHandler('esx_mechanicjob:SetJobPlayer_offline', function(playerId, job, grade)
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


ESX.RegisterServerCallback('esx_mechanicjob:buyJobVehicle', function(source, cb, vehicleProps, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = getPriceFromHash(vehicleProps.model, xPlayer.job.grade_name, type)

	-- vehicle model not found
	if price == 0 then
		print(('esx_mechanicjob: %s attempted to exploit the shop! (invalid vehicle model)'):format(xPlayer.identifier))
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
		TriggerEvent('azael_dc-serverlogs:insertData', 'McBuyCar', sendToDiscord, xPlayer.source, '^2')
	else
		cb(false)
	end
end)


function getPriceFromHash(hashKey, jobGrade, type)
	local vehicles = Config.AuthorizedVehicles[jobGrade]
	if not vehicles then
		vehicles = Config.AuthorizedVehicles["Shared"]
	end
	
	for k,v in ipairs(vehicles) do
		if GetHashKey(v.model) == hashKey then
			return v.price
		end
	end

	return 0
end

ESX.RegisterServerCallback('esx_mechanicjob:getOtherPlayerData', function(source, cb, target)

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


ESX.RegisterServerCallback('esx_mechanicjob:getVehicleFrommod', function (source, cb)
	MySQL.Async.fetchAll('SELECT *, date_format(time, "%Y-%m-%d") AS time FROM owned_vehicles WHERE mod = @mod', {
		['@mod'] =1
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
				mod		  = result[i].mod,
				mod_by		  = result[i].mod_by,
				time		  = result[i].time
			})
		end

		cb(vehicles)
	end)
end)


RegisterServerEvent('esx_mechanicjob:setVehicleFrommod')
AddEventHandler('esx_mechanicjob:setVehicleFrommod', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('UPDATE owned_vehicles SET `stored` = @stored, `mod` = @mod, `mod_by` = @mod_by WHERE plate = @plate', {
		['@stored'] = false,
		['@mod'] = 0,
		['@plate'] = plate,
		['@mod_by'] = nil
	}, function(rowsChanged)
		if rowsChanged == 0 then
			print("ERROR Update setVehicleFrommod")
		end
	end)
end)


ESX.RegisterServerCallback('esx_mechanicjob:storeNearbyVehicle', function(source, cb, nearbyVehicles)
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
				print(('esx_modjob: %s has exploited the garage!'):format(xPlayer.identifier))
				cb(false)
			else
				cb(true, foundNum)
			end
		end)
	end

end)