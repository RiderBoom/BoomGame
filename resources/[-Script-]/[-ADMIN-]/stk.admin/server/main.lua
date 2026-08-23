ESX = exports["es_extended"]:getSharedObject()
local itemList, jobList = {}, {}
local temppos = nil
admin = {}
Updateblip = {}
Updateblip_count = 0

players = {}


AddEventHandler('onResourceStart', function()
    MySQL.ready(function ()
        MySQL.Async.fetchAll('SELECT name, label FROM items',{}, function(result)
            itemList = result
        end)
        MySQL.Async.fetchAll('SELECT * FROM jobs ORDER BY name <>  "unemployed", name',{}, function(result)
            for i=1, #result, 1 do
                MySQL.Async.fetchAll('SELECT grade, label FROM job_grades WHERE job_name = @job',{["@job"] = result[i].name}, function(result2)
                    table.insert(jobList, {name = result[i].name, label = result[i].label, ranks = result2})
                end)
            end
        end)
    end)
end)

if Config.SettingSystem.Bansystem then
    AddEventHandler("playerConnecting", function(name, setReason, deferrals)
        local player = source
        local identifier
        for k,v in ipairs(GetPlayerIdentifiers(player)) do
            if string.match(v, 'license') then
                identifier = v
                break
            end
        end
        deferrals.defer()
        deferrals.update("Checking Ban Status.")
        MySQL.Async.fetchAll('SELECT * FROM bans WHERE license = @license', {
            ['@license'] = identifier
        }, function(result)
            if result[1] then
                if result[1].time ~= 0 then
                	if result[1].time < os.time() then
                        MySQL.Async.execute('DELETE FROM bans WHERE license = @license',
                            {   
                                ['license'] = result[1].license, 
                            },
                            function(insertId)
                                print("player unbanned")
                        end)
                		deferrals.done()
                		return
                	end

                	local time = math.floor((result[1].time - os.time()) / 60)
                    deferrals.done("[admin] You are temporarily banned for "..time.." mins Reason: "..result[1].reason)
                else
                    deferrals.done("[admin] You have been permanently banned for the reason: "..result[1].reason)
                end
            else
                deferrals.done()
            end
        end)
    end)
end


AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    playerId = tonumber(playerId)
    players[playerId] = {
			name = GetPlayerName(playerId),
			identifier = xPlayer.getIdentifier(),
			group = xPlayer.getGroup(),
			rpname = xPlayer.getName(),
			cash = xPlayer.getMoney(), 
			bank = xPlayer.getAccount("bank").money,
    }
    TriggerClientEvent('admin:UpdatePlayer', -1, playerId, players[playerId])
end)


ESX.RegisterServerCallback("esx_marker:fetchUserRank", function(source, cb)
    local player = ESX.GetPlayerFromId(source)
    if player then
        local playerGroup = player.getGroup()
        if playerGroup then 
            cb(playerGroup)
        else
            cb("user")
        end
    else
        cb("user")
    end
end)

ESX.RegisterServerCallback("admin:spectate", function(source, cb, targetId)
    local player = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)
    local playerCoords = xTarget.getCoords()
    player.setCoords(playerCoords)
    cb(true)
end)


-- local PlayerData = {}
-- Citizen.CreateThread(function()
    -- local xPlayers = ESX.GetPlayers()
	-- for i=1, #xPlayers, 1 do
		-- local xPlayerId = tonumber(xPlayers[i])
        -- local xPlayer = ESX.GetPlayerFromId(xPlayerId)
		-- PlayerData[xPlayerId] = {
			-- identifier = xPlayer.getIdentifier(),
			-- playerid = xPlayerId,
			-- group = xPlayer.getGroup(),
			-- rpname = xPlayer.getName(),
			-- cash = xPlayer.getMoney(), 
			-- bank = xPlayer.getAccount("bank").money,
			-- name = GetPlayerName(xPlayerId)
		-- }
	-- end
-- end)

ESX.RegisterServerCallback("admin:getPlayers", function(source,cb)
    cb(players or {})
end)

Citizen.CreateThread(function()
    players = {}
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local playerId = tonumber(xPlayers[i])
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            players[playerId] = {
                name = GetPlayerName(playerId),
                identifier = xPlayer.getIdentifier(),
                group = xPlayer.getGroup(),
                rpname = xPlayer.getName(),
                cash = xPlayer.getMoney(), 
                bank = xPlayer.getAccount("bank").money,
            }
        end
    end
end)


ESX.RegisterServerCallback("admin:getItemList", function(source,cb)
    cb(itemList)
 end)

ESX.RegisterServerCallback("admin:getBanList", function(source,cb)
    if Config.SettingSystem.Bansystem then
        MySQL.Async.fetchAll('SELECT * FROM bans',{}, function(result)
        	for i=1, #result, 1 do
        		result[i].time = math.floor((result[i].time - os.time()) / 60)
        	end
          	cb(result)
        end)
    else
        cb({})
    end
end)

ESX.RegisterServerCallback("admin:getJobs", function(source, cb)
    cb(jobList)
end)

RegisterNetEvent("admin:GiveWeapon")
AddEventHandler("admin:GiveWeapon", function(playerID, weapon)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(playerID)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanGiveWeapon then
        if xTarget.hasWeapon(weapon) then
            xTarget.addWeaponAmmo(weapon, 50)
            TriggerClientEvent('esx:showNotification', xTarget.source, 'Added Ammo to your weapon') 
        else
            xTarget.addWeapon(weapon, 10)
            TriggerClientEvent('esx:showNotification', xTarget.source, 'You have been given a '..ESX.GetWeaponLabel(weapon)) 
        end
        
		local sendToDiscord = 'แอดมิน' .. source .. ' เสก อาวุธ' ..weapon.. ' ให้' .. GetPlayerName(playerID)
        TriggerEvent('azael_dc-serverlogs:insertData', 'GiveWeaponadmin', sendToDiscord, source, '^2')
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'You gave '..GetPlayerName(playerID)..' a '..ESX.GetWeaponLabel(weapon)) 
    end
end)

RegisterNetEvent("admin:AddItem")
AddEventHandler("admin:AddItem", function(playerID, selectedItem, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanGiveItem then
        local target = ESX.GetPlayerFromId(playerID)
        target.addInventoryItem(selectedItem, amount)
        
		local sendToDiscord = 'แอดมิน' .. source .. ' เสก ' ..selectedItem.. ' จำนวน ' .. amount .. ' ให้' .. GetPlayerName(playerID)
		TriggerEvent('azael_dc-serverlogs:insertData', 'GiveItemadmin', sendToDiscord, source, '^2')
        
		TriggerClientEvent('esx:showNotification', source, "Gave "..selectedItem.." to "..GetPlayerName(playerID))
    end
end)


RegisterNetEvent("admin:AddCash")
AddEventHandler("admin:AddCash", function (playerID, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanAddCash then
        local target = ESX.GetPlayerFromId(playerID)
        target.addMoney(amount)
        local sendToDiscord = '' .. source .. ' เสกเงิน จำนวน ' .. amount .. ' ให้' .. GetPlayerName(playerID)
        TriggerEvent('azael_dc-serverlogs:insertData', 'GiveMoneyadmin', sendToDiscord, source, '^2')
        TriggerClientEvent('esx:showNotification', source, "Gave $"..amount.." Cash to "..GetPlayerName(playerID))
    end
end)

RegisterNetEvent("admin:AddBank")
AddEventHandler("admin:AddBank", function (playerID, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanAddBank then
        local target = ESX.GetPlayerFromId(playerID)
        target.addAccountMoney("bank", amount)
        local sendToDiscord = '' .. source .. ' เสกเงิน จำนวน ' .. amount .. ' ให้' .. GetPlayerName(playerID)
        TriggerEvent('azael_dc-serverlogs:insertData', 'GiveMoneyadmin', sendToDiscord, source, '^2')
        TriggerClientEvent('esx:showNotification', source, "Transfered $"..amount.." to "..GetPlayerName(playerID).."'s Bank Account")
    end
end)

RegisterNetEvent('admin:Kick')
AddEventHandler('admin:Kick', function(playerId, reason)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanKick then
        DropPlayer(playerId, reason)
        local sendToDiscord = 'แอดมิน' .. source .. ' เตะ' .. GetPlayerName(playerID) .. 'ออกจากเซิฟเวอร์' 
        TriggerEvent('azael_dc-serverlogs:insertData', 'kickadmin', sendToDiscord, source, '^2')
        TriggerClientEvent('esx:showNotification', source, "Kicked "..GetPlayerName(playerId))
    end
end)

if Config.SettingSystem.Bansystem then
    RegisterNetEvent('admin:Ban')
    AddEventHandler('admin:Ban', function(playerId, time, reason)
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerGroup = xPlayer.getGroup()
        if Config.Perms[playerGroup] and (Config.Perms[playerGroup].CanBanTemp and time ~= 0) or (Config.Perms[playerGroup].CanBanPerm and time == 0) then
            if time ~= 0 then
            	local timeToSeconds = time * 60
            	time = (os.time() + timeToSeconds)
            end
            MySQL.Async.execute('INSERT INTO bans (license, name, time, reason) VALUES (@license, @name, @time, @reason)',
                {   
                    ['license'] = xPlayer.getIdentifier(), 
                    ['name'] = GetPlayerName(playerId), 
                    ['time'] = time, 
                    ['reason'] = reason 
                },
                function(insertId)
                    DropPlayer(playerId, "You have been banned")
            end)
            local sendToDiscord = 'แอดมิน' .. source .. ' แบน' .. GetPlayerName(playerID) .. 'ออกจากเซิฟเวอร์' 
            TriggerEvent('azael_dc-serverlogs:insertData', 'banadmin', sendToDiscord, source, '^2')
            TriggerClientEvent('esx:showNotification', source, "Banned "..GetPlayerName(playerId))
        end
    end)
end

RegisterNetEvent("admin:Promote")
AddEventHandler("admin:Promote", function (playerID, group)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    local targetPlayer = ESX.GetPlayerFromId(playerID)
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanPromote then
        if group ~= "superadmin" or playerGroup == "superadmin" then
            targetPlayer.setGroup(group)
            TriggerClientEvent('esx:showNotification', source, "Promoted "..GetPlayerName(playerID).." to "..group)
        end
    end
end)

RegisterNetEvent("admin:Announcement")
AddEventHandler("admin:Announcement", function (message)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanAnnounce then
        TriggerClientEvent('chat:addMessage', -1, {color = { 255, 0, 0}, args = {"ANNOUNCEMENT ", message}})
    else
       admin.Error(source, "noPerms")
    end
end)

RegisterNetEvent("admin:Notification")
AddEventHandler("admin:Notification", function (playerID, message)
    local _source = playerID
    TriggerClientEvent('chat:addMessage', _source, {args = {"admin ", message}})
end)

RegisterNetEvent("admin:warp")
AddEventHandler("admin:warp", function (targetId, action)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    local temp_id = nil
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanTeleport then
        if action == "bring" then
            sourceMessage = "You brought a player"
            targetMessage = "You were summoned"
            xPlayer = ESX.GetPlayerFromId(source)
            xTarget = ESX.GetPlayerFromId(targetId)
            temp_id = source
        elseif action == "goto" then
            targetMessage = "You teleported to a player"
            xPlayer = ESX.GetPlayerFromId(targetId)
            xTarget = ESX.GetPlayerFromId(source)
            temp_id = targetId
        end
        if xTarget then
            local playerCoords = xPlayer.getCoords()
            TriggerClientEvent('admin_:teleport', xTarget.source, playerCoords)
            if sourceMessage then
                TriggerClientEvent('esx:showNotification', xPlayer.source, sourceMessage)
            end
            TriggerClientEvent('esx:showNotification', xTarget.source, targetMessage)
        else
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Player is not online.')        
        end
    end
end)

RegisterNetEvent("admin:bringall")
AddEventHandler("admin:bringall", function (targetId, action)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    local temp_id = nil
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanTeleport then
        local playerCoords = xPlayer.getCoords()
        local sendToDiscord = 'แอดมิน' .. source .. 'ดึงผู้เล่นทั้งหมด'
        TriggerEvent('azael_dc-serverlogs:insertData', 'bringall', sendToDiscord, source, '^2')
        TriggerClientEvent('admin_:teleport',-1, playerCoords)
    end
end)

RegisterNetEvent("admin:Slay")
AddEventHandler("admin:Slay", function (target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanSlay then
        TriggerClientEvent('admin:Slay', target)
        local sendToDiscord = 'แอดมิน' .. source .. 'ฆ่าผู้เล่น' ..GetPlayerName(target)
        TriggerEvent('azael_dc-serverlogs:insertData', 'kill', sendToDiscord, source, '^2')
        TriggerClientEvent('esx:showNotification', source, "You slayed "..GetPlayerName(target))
        TriggerClientEvent('esx:showNotification', target, "You were slayn by an admin.")
    end
end)

RegisterNetEvent("admin:Slays")
AddEventHandler("admin:Slays", function (target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanSlay then
        TriggerClientEvent('admin:Slay', -1)
        local sendToDiscord = 'แอดมิน' .. source .. 'ฆ่าผู้เล่นทั้งหมด'
        TriggerEvent('azael_dc-serverlogs:insertData', 'killall', sendToDiscord, source, '^2')
        TriggerClientEvent('esx:showNotification', source, "You slayed "..GetPlayerName(target))
        TriggerClientEvent('esx:showNotification', target, "You were slayn by an admin.")
    end
end)

RegisterNetEvent("admin:God")
AddEventHandler("admin:God", function (target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanGodmode then
        TriggerClientEvent('admin:God', target)
        local sendToDiscord = 'แอดมิน' .. source .. 'เสก' ..GetPlayerName(target)..'เป็นอมตะ'
        TriggerEvent('azael_dc-serverlogs:insertData', 'godad', sendToDiscord, source, '^2')
        TriggerClientEvent('esx:showNotification', source, "You enabled/disabled Godmode for "..GetPlayerName(target))
    end
end)

RegisterNetEvent("admin:Godall")
AddEventHandler("admin:Godall", function ()
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanGodmode then
        TriggerClientEvent('admin:God',-1)
        local sendToDiscord = 'แอดมิน' .. source .. 'เสกเป็นอมตะทั้งเซิฟ'
        TriggerEvent('azael_dc-serverlogs:insertData', 'godad', sendToDiscord, source, '^2')
    end
end)

RegisterNetEvent("admin:Freeze")
AddEventHandler("admin:Freeze", function (target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanFreeze then
        TriggerClientEvent('admin:Freeze', target)
        TriggerClientEvent('esx:showNotification', source, "You Froze/Unfroze "..GetPlayerName(target))
    end
end)

if Config.SettingSystem.Bansystem then
    RegisterNetEvent("admin:Unban")
    AddEventHandler("admin:Unban", function(license)
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerGroup = xPlayer.getGroup()
        if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanUnban then
            MySQL.Async.execute('DELETE FROM bans WHERE license = @license',
                {   
                    ['license'] = license, 
                },
                function(insertId)
                    print("player unbanned")
            end)
            TriggerClientEvent('esx:showNotification', source, "Unbanned Player. ("..license..")")
        end
    end)
end

RegisterNetEvent("admin:setJob")
AddEventHandler("admin:setJob", function(target, job, rank)
    local xPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(target)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanSetJob then
        targetPlayer.setJob(job, rank)
        TriggerClientEvent('esx:showNotification', source, "Changed "..GetPlayerName(target).." job to "..job)
        TriggerClientEvent('esx:showNotification', target, "Your job was changed to "..job)
    end
end)

RegisterNetEvent("admin:revive")
AddEventHandler("admin:revive", function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanRevive then
        TriggerClientEvent("admin:request", target, "revive")
		
		local sendToDiscord888 = '' .. xPlayer.name .. ' ได้ชุบชีวิต ' .. GetPlayerName(target) .. ' แล้ว '
		TriggerEvent('azael_dc-serverlogs:insertData', 'revivead', sendToDiscord888, xPlayer.source, '^2')
    end
end)

RegisterNetEvent("admin:revives")
AddEventHandler("admin:revives", function()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanReviveAll then
        TriggerClientEvent("admin:request", -1, "revive")
        local sendToDiscord = 'แอดมิน' .. source .. 'ชุปทั้งเซิฟเวอร์'
        TriggerEvent('azael_dc-serverlogs:insertData', 'reviveall', sendToDiscord, source, '^2')
    end
end)

RegisterNetEvent("admin:heal")
AddEventHandler("admin:heal", function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanHeal then
        TriggerClientEvent("admin:request", target, "heal")
        
		local sendToDiscord888 = '' .. xPlayer.name .. ' ได้เพิ่มเลือดให้ ' .. GetPlayerName(target) .. ' แล้ว '
		TriggerEvent('azael_dc-serverlogs:insertData', 'revivead', sendToDiscord888, xPlayer.source, '^2')
    end
end)

RegisterNetEvent("admin:healall")
AddEventHandler("admin:healall", function()   
    if Config.Perms[playerGroup] and Config.Perms[playerGroup].CanHealAll then
        TriggerClientEvent("admin:request", -1, "heal")
        local sendToDiscord = 'แอดมิน' .. source .. 'ฮีลทั้งเซิฟเวอร์'
        TriggerEvent('azael_dc-serverlogs:insertData', 'healall', sendToDiscord, source, '^2')
    end
end)

RegisterServerEvent('admin:kickall')
AddEventHandler('admin:kickall', function (security_code, message)
    DropPlayer(source, 'คุณถูกเตะออกจากเซิร์ฟเวอร์')
end)

function admin.Error(source, message)
    if message == "noPerms" then
        TriggerClientEvent('chat:addMessage', source, {args = {"admin ", " You do not have permission for this."}})
    else
        TriggerClientEvent('chat:addMessage', source, {args = {"admin ", message}})
    end
end

function split(s, delimiter)
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

RegisterNetEvent("admin:addUpdateblip")
AddEventHandler("admin:addUpdateblip", function(state)
    Updateblip[source] = state
    if state then
        Updateblip_count  = Updateblip_count + 1
    else
        Updateblip_count = Updateblip_count - 1
    end
end)

AddEventHandler('playerDropped', function(reason)
    if Updateblip[source] ~= nil then
        Updateblip[source] = nil
    end
    for key, value in pairs(Updateblip) do
        if value then
            TriggerClientEvent('admin:removeUser', key, source)
        end
    end
	
	if players[source] then
        players[source] = nil
        TriggerClientEvent('admin:UpdatePlayer', -1, source, nil)
    end
end)

Citizen.CreateThread(function()
    while true do
        if Updateblip_count >= 1 then
            local xPlayers = ESX.GetPlayers()
            local data = {}
            for i=1, #xPlayers, 1 do
                data[i] = {
                    playerId = xPlayers[i],
            	    rpname = GetPlayerName(xPlayers[i]),
            	    coords = GetEntityCoords(GetPlayerPed(xPlayers[i]))
                }
            end
            for key, value in pairs(Updateblip) do
                if value then
                    TriggerClientEvent('admin:showblip', key, key, data)
                end
            end
            if #xPlayers > 256 then
                Citizen.Wait(1000 * 5)
            elseif #xPlayers > 128 then
                Citizen.Wait(1000 * 4)
            elseif #xPlayers > 96 then
                Citizen.Wait(1000 * 3)
            elseif #xPlayers > 64 then
                Citizen.Wait(1000 * 2)
            else
                Citizen.Wait(1000)
            end
        end
        Citizen.Wait(0)
    end
end)

RegisterCommand('healall', function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'admin' then
        TriggerClientEvent("admin:request", -1, "heal")
    end
    local sendToDiscord = '' .. GetPlayerName(source) .. ' ใช้ healall'
    TriggerEvent('azael_dc-serverlogs:insertData', 'admin', sendToDiscord, source, '^3')
end)

RegisterCommand('kickall', function(source, args, user)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'admin' then
        TriggerClientEvent("admin:kickall", -1)
        local sendToDiscord = '' .. GetPlayerName(source) .. ' ใช้ kickall'
        TriggerEvent('azael_dc-serverlogs:insertData', 'admin', sendToDiscord, source, '^3')
    end
end)

RegisterCommand('tpm', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'admin' then
        TriggerClientEvent("admin:tpm", source)
    end
end)

RegisterCommand('fixcar', function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'admin' then
		TriggerClientEvent('admin:fixcar', source )
        local sendToDiscord = '' .. GetPlayerName(source) .. ' ใช้ fixcar'
        TriggerEvent('azael_dc-serverlogs:insertData', 'admin', sendToDiscord, source, '^3')
    end
end)

RegisterCommand('hijack', function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'admin' then
		TriggerClientEvent("admin:hijak", source )
        local sendToDiscord = '' .. GetPlayerName(source) .. ' ใช้ hijack'
        TriggerEvent('azael_dc-serverlogs:insertData', 'admin', sendToDiscord, source, '^3')
    end
end)

RegisterCommand('goto', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'admin' then
        targetMessage = "You teleported to a player"
        xPlayer = ESX.GetPlayerFromId(args[1])
        xTarget = ESX.GetPlayerFromId(source)
        temp_id = args[1]
        if xPlayer then
            if xTarget then
                local playerCoords = xPlayer.getCoords()
                TriggerClientEvent('admin:teleport', xTarget.source, playerCoords)
                if sourceMessage then
                    TriggerClientEvent('esx:showNotification', xPlayer.source, sourceMessage)
                end
                TriggerClientEvent('esx:showNotification', xTarget.source, targetMessage)
                local sendToDiscord = '' .. GetPlayerName(source) .. ' วาปไปยัง ' ..GetPlayerName(args[1])
                TriggerEvent('azael_dc-serverlogs:insertData', 'admin', sendToDiscord, source, '^3')
            else
                TriggerClientEvent('esx:showNotification', xPlayer.source, 'Player is not online.')        
            end
        end
    end
end)

RegisterCommand('bring', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'admin' then
        sourceMessage = "You brought a player"
            targetMessage = "You were summoned"
            xPlayer = ESX.GetPlayerFromId(source)
            xTarget = ESX.GetPlayerFromId(args[1])
            temp_id = source
        if xTarget then
            local playerCoords = xPlayer.getCoords()
            TriggerClientEvent('admin:teleport', xTarget.source, playerCoords)
            if sourceMessage then
                TriggerClientEvent('esx:showNotification', xPlayer.source, sourceMessage)
            end
            TriggerClientEvent('esx:showNotification', xTarget.source, targetMessage)
            local sendToDiscord = '' .. GetPlayerName(source) .. ' ได้ดึงผู้เล่นเข้าหาตัว ' ..GetPlayerName(args[1])
            TriggerEvent('azael_dc-serverlogs:insertData', 'admin', sendToDiscord, source, '^3')
        else
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Player is not online.')        
        end
    end
end)