ESX = exports["es_extended"]:getSharedObject()
admin = {}
local display, frozen, isSpectating, noclip, speed  = false, false, false, false, 1
local temppos = nil
_playerRank = nil
_jobs = nil
_results = nil
playerID = 0
Updateblip = false
players = {}

Citizen.CreateThread(function()
	ESX.TriggerServerCallback("admin:getPlayers", function(data)
		players = data
    end)
end)


RegisterNUICallback("exit", function(data)
    SetDisplay(false)
end)

RegisterNUICallback("ban", function(data)
    TriggerServerEvent("admin:Ban", data.playerid, tonumber(data.inputData), "You have been put on a timeout")
end)

RegisterNUICallback("permaban", function(data)
    TriggerServerEvent("admin:Ban", data.playerid, 0, data.inputData)
end)

RegisterNUICallback("unban", function(data)
    TriggerServerEvent("admin:Unban", data.confirmoutput)
    admin.GetPlayers()
end)

RegisterNUICallback("addCash", function(data)
    local amnt = tonumber(data.inputData)
    TriggerServerEvent("admin:AddCash", data.playerid, amnt)
end)

RegisterNUICallback("addBank", function(data)
    local amnt = tonumber(data.inputData)
    TriggerServerEvent("admin:AddBank", data.playerid, amnt)
end)

RegisterNUICallback("inventory", function(data)
	exports.nc_inventory:SearchInventory((data.playerid),'admin')
	SetDisplay(false)
end)

RegisterNUICallback("giveitem", function(data)
    local amnt = tonumber(data.amount)
    print("id: "..data.playerid.." name: "..data.name.." amount: "..data.amount)
    TriggerServerEvent("admin:AddItem", data.playerid, data.name, amnt)
end)

RegisterNUICallback("error", function(data)
    chat(data.error, {255,0,0})
    SetDisplay(false)
end)

RegisterNUICallback("admin:tpm", function(data)
    admin.TeleportToWaypoint()
end)

RegisterNUICallback("bring", function(data)
    TriggerServerEvent("admin:warp", data.playerid, "bring")
end)

RegisterNUICallback("godall",function(data)
	TriggerServerEvent("admin:Godall")
end)

RegisterNUICallback("bringall",function(data)
    TriggerServerEvent("admin:bringall")
end)

RegisterNUICallback("goto", function(data)
    TriggerServerEvent("admin:warp", data.playerid, "goto")
end)

RegisterNUICallback("kick", function(data)
    TriggerServerEvent("admin:Kick", data.playerid, data.inputData)
end)

RegisterNUICallback("spectate", function(data)
	playerID = data.playerid
	admin.Spectate(playerID, true)
	isSpectating = true
	SetDisplay(false)
end)

RegisterNUICallback("freeze", function(data)
	TriggerServerEvent("admin:Freeze", data.playerid)
end)

RegisterNUICallback("skin",function(data)
    TriggerEvent('esx_skin:openSaveableMenu', source)
	SetDisplay(false)
end)

RegisterNUICallback("setskin",function(data)
    TriggerEvent('esx_skin:openSaveableMenu', target)
	SetDisplay(false)
end)

RegisterNUICallback("kill", function(data)
	TriggerServerEvent("admin:Slay", data.playerid)
end)

RegisterNUICallback("promote", function(data)
	TriggerServerEvent("admin:Promote", data.playerid, data.level)
end)

RegisterNUICallback("weapon", function(data)
	TriggerServerEvent("admin:GiveWeapon", data.playerid, data.weapon)
end)

RegisterNUICallback("noclip", function(data)
	admin.Noclip()
	SetDisplay(false)
end)

RegisterNUICallback("setvehicle", function(data)
	local playerPed = GetPlayerPed(-1)
	if IsPedInAnyVehicle(playerPed, false) then
		TriggerEvent('admin:setvehicle')
	else
		ESX.ShowNotification("You're not in a vehicle! There is no vehicle .")
	end
	SetDisplay(false)
end)

RegisterNUICallback("fixcar", function(data)
	local playerPed = GetPlayerPed(-1)
	if IsPedInAnyVehicle(playerPed, false) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		SetVehicleEngineHealth(vehicle, 1000)
		SetVehicleEngineOn( vehicle, true, true)
		SetVehicleFixed(vehicle)
		SetVehicleDirtLevel(vehicle, 0)
		ESX.ShowNotification("Your vehicle has been fixed.")
	end
	SetDisplay(false)
end)

RegisterNUICallback("god", function(data)
	TriggerServerEvent("admin:God", data.playerid)
end)

RegisterNUICallback("spawnvehicle", function(data)
	admin.SpawnVehicle(data.model)
	SetDisplay(false)
end)

RegisterNUICallback("announce", function(data)
	TriggerServerEvent("admin:Announcement", data.inputData)
end)

RegisterNUICallback("heal", function(data)
    TriggerServerEvent("admin:heal", data.playerid)
	SetDisplay(false)
end)

RegisterNUICallback("revive", function(data)
	TriggerServerEvent("admin:revive", data.playerid)
	SetDisplay(false)
end)

RegisterNUICallback("reviveallplayer", function(data)
	TriggerServerEvent("admin:revives")
	SetDisplay(false)
end)

RegisterNUICallback("healall", function(data)
    TriggerServerEvent("admin:healall")
	SetDisplay(false)
end)

RegisterNUICallback("slayall", function(data)
    TriggerServerEvent("admin:Slays")
end)

RegisterNUICallback("speed", function(data)
	local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player)
	SetVehicleEnginePowerMultiplier(vehicle, data.inputData)
	SetVehicleEngineTorqueMultiplier(vehicle, data.inputData)
	SetEntityMaxSpeed(vehicle, 990.0)
	SetDisplay(false)
end)

RegisterNUICallback("hijak", function(data)
	TriggerEvent("admin:hijak")
	SetDisplay(false)
end)

RegisterNUICallback("setJob", function(data)
	TriggerServerEvent("admin:setJob", data.playerid, data.job, data.rank)
	SetDisplay(false)
end)

RegisterNUICallback("setTime", function(data)
	TriggerServerEvent("admin:Time", data.inputData)
end)

RegisterNUICallback("freezeTime", function(data)
	TriggerServerEvent("admin:freezeTime")
end)

RegisterNUICallback("changeWeather", function(data)
	TriggerServerEvent("admin:Weather", data.weather)
end)

RegisterNUICallback("freezeWeather", function(data)
	TriggerServerEvent("admin:freezeWeather")
end)

RegisterNUICallback("blackout", function(data)
	TriggerServerEvent("admin:Blackout")
end)

RegisterNUICallback("customcar", function(data)
	local playerPed = GetPlayerPed(-1)
	if IsPedInAnyVehicle(playerPed, false) then
		exports['esx_lscustom']:openByMenuAdmin()
	else
		ESX.ShowNotification("You're not in a vehicle! There is no vehicle .")
	end
	SetDisplay(false)
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end

admin.TeleportToWaypoint = function()
	local  playerRank = _playerRank
    if Config.Perms[_playerRank] and Config.Perms[_playerRank].CanTpWp then
        local WaypointHandle = GetFirstBlipInfoId(8)
        if DoesBlipExist(WaypointHandle) then
            local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
            for height = 1, 1000 do
                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
                local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)
                if foundGround then
                    SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
                    break
                end
                Citizen.Wait(5)
            end
            ESX.ShowNotification("Teleported.")
        else
            ESX.ShowNotification("Please Place Your Waypoint.")
        end
    end
end


-- admin.GetPlayers = function()
    -- ESX.TriggerServerCallback("admin:getPlayers", function(players) 
		-- table.sort(players, function(a,b) return a.playerid < b.playerid end)
        -- SendNUIMessage({type = "data", data = players})
    -- end)
	-- if _bans == nil then
		-- ESX.TriggerServerCallback("admin:getBanList", function(bans) 
			-- _bans = bans
		    -- SendNUIMessage({type = "bans", banlist = bans})
		-- end)
	-- else
		-- SendNUIMessage({type = "bans", banlist = _bans})
	-- end
-- end

RegisterNetEvent('admin:UpdatePlayer', function(playerId, data)
	players[tonumber(playerId)] = data
end)

admin.GetPlayers = function()
	local data = {}
	for k,v in pairs(players) do
		table.insert(data, {
			playerid = tonumber(k),
			name = v.name,
			identifier = v.identifier,
			group = v.group,
			rpname = v.rpname,
			cash = v.cash or 0, 
			bank = v.bank or 0,
		})
	end
	table.sort(data, function(a,b) return a.playerid < b.playerid end)
	SendNUIMessage({type = "data", data = data})
	if _bans == nil then
		ESX.TriggerServerCallback("admin:getBanList", function(bans) 
			_bans = bans
		    SendNUIMessage({type = "bans", banlist = bans})
		end)
	else
		SendNUIMessage({type = "bans", banlist = _bans})
	end
end



admin.GetItemList = function()
	local weapons = ESX.GetWeaponList()
	if _jobs == nil then
		ESX.TriggerServerCallback("admin:getJobs", function(jobs) 
			_jobs = jobs
		    ESX.TriggerServerCallback("admin:getItemList", function(results) 
				_results = results
		        SendNUIMessage({type = "items", itemslist = results, weaponlist = weapons, vehiclelist = Config.Vehicles, joblist = jobs })

		    end)
		end)
	else
		SendNUIMessage({type = "items", itemslist = _results, weaponlist = weapons, vehiclelist = Config.Vehicles, joblist = _jobs })
	end
end

local nearBlips = {}
local longBlips = {}

RegisterNetEvent('admin:removeUser')
AddEventHandler('admin:removeUser', function(plyId)
	print('OUT:'..plyId)
    if nearBlips[plyId] then
        RemoveBlip(nearBlips[plyId].blip)
        nearBlips[plyId] = nil
    end
    if longBlips[plyId] then
        RemoveBlip(longBlips[plyId].blip)
        longBlips[plyId] = nil
    end
end)

RegisterNetEvent("admin:tpm")
AddEventHandler("admin:tpm", function ()
	admin.TeleportToWaypoint()
end)

RegisterNetEvent('admin:showblip')
AddEventHandler('admin:showblip', function(myId, data)
	for k, v in pairs(data) do
        local cId = GetPlayerFromServerId(v.playerId)
        if true then
            if myId ~= v.playerId then
                if cId ~= -1 then
                    if nearBlips[v.playerId] == nil then
                        if longBlips[v.playerId] then
                            RemoveBlip(longBlips[v.playerId].blip)
                            longBlips[v.playerId] = nil
                        end
                        nearBlips[v.playerId] = {}
                        nearBlips[v.playerId].blip = AddBlipForEntity(GetPlayerPed(cId))
                        setupBlip(nearBlips[v.playerId].blip, v)
                    end  
                else
                    if longBlips[v.playerId] == nil then
                        if nearBlips[v.playerId] then
                            RemoveBlip(nearBlips[v.playerId].blip)
                            nearBlips[v.playerId] = nil
                        end
                        longBlips[v.playerId] = {}
                        longBlips[v.playerId].blip = AddBlipForCoord(v.coords)
                        setupBlip(longBlips[v.playerId].blip, v)
                    else
                        if longBlips[v.playerId] then
                            RemoveBlip(longBlips[v.playerId].blip)
                        end
                        longBlips[v.playerId].blip = AddBlipForCoord(v.coords)
                        setupBlip(longBlips[v.playerId].blip, v)
                    end
                end
            end
        end
    end
end)

function setupBlip(blip, data)
	SetBlipSprite(blip, 1)
	SetBlipDisplay(blip, 2)
	SetBlipScale(blip,  1.0)
	SetBlipColour(blip, 0)
    SetBlipFlashes(blip, false)
    SetBlipCategory(blip, 7)
	BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.rpname)
	EndTextCommandSetBlipName(blip)
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    removeAllBlips()
end)

function removeAllBlips()
    for k, v in pairs(nearBlips) do
        RemoveBlip(v.blip)
    end
    for k, v in pairs(longBlips) do
        RemoveBlip(v.blip)
    end
    nearBlips = {}
    longBlips = {}
end

function restoreBlip(blip) 
    SetBlipSprite(blip, 6)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.7)
    SetBlipColour(blip, 0)
    SetBlipShowCone(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(GetPlayerName(PlayerId()))
    EndTextCommandSetBlipName(blip)
    SetBlipCategory(blip, 1)
end

RegisterNetEvent('admin:Freeze')
AddEventHandler('admin:Freeze', function(targetPed)
	local player = PlayerId()
	local ped = PlayerPedId()
	frozen = not frozen
	if not frozen then
		if not IsEntityVisible(ped) then
			SetEntityVisible(ped, true)
		end
		if not IsPedInAnyVehicle(ped) then
			SetEntityCollision(ped, true)
		end
		FreezeEntityPosition(ped, false)
		SetPlayerInvincible(player, false)
	else
		SetEntityCollision(ped, false)
		FreezeEntityPosition(ped, true)
		SetPlayerInvincible(player, true)
		if not IsPedFatallyInjured(ped) then
			ClearPedTasksImmediately(ped)
		end
	end
end)

RegisterNetEvent('admin_:teleport')
AddEventHandler('admin_:teleport', function(temppos)
	SetEntityCoords(PlayerPedId(), temppos.x, temppos.y, temppos.z)
end)

RegisterNetEvent("healallx")
AddEventHandler("healallx",function()
    SetEntityHealth(GetPlayerPed(-1),200)
end)

RegisterNetEvent("slayallx")
AddEventHandler("slayallx",function()
    SetEntityHealth(PlayerPedId(),0)
end)

RegisterNetEvent('admin:Slay')
AddEventHandler('admin:Slay', function(targetPed)
	SetEntityHealth(PlayerPedId(), 0)
end)

local hasGodmode = false
RegisterNetEvent('admin:God')
AddEventHandler('admin:God', function(targetPed)
	if not hasGodmode then
		hasGodmode = not hasGodmode
		SetEntityInvincible(PlayerPedId(), true)
		ESX.ShowNotification("God Mode : Enable")
	else
		SetEntityInvincible(PlayerPedId(), false)
		ESX.ShowNotification("God Mode : Disable")
	end
end)

RegisterNetEvent("admin:request")
AddEventHandler("admin:request", function(method)
	local PlayerPed = PlayerPedId()
	if method == "heal" then
		SetEntityHealth(PlayerPed, 200)
		TriggerEvent("esx_status:set", "hunger", 1000000)
		TriggerEvent("esx_status:set", "thirst", 1000000)
		TriggerEvent("esx_status:set", "stress", 0)
	elseif method == "revive" then
		if IsPedDeadOrDying(PlayerPed, 1) then
			TriggerEvent("esx_ambulancejob:revive")
			TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
			Wait(1500)
			SetEntityHealth(PlayerPed, 120)
			TriggerEvent("esx_status:set", "hunger", 200000)
			TriggerEvent("esx_status:set", "thirst", 200000)
			TriggerEvent("esx_status:set", "stress", 500000)
		end
	end
end)

RegisterNetEvent("admin:kickall")
AddEventHandler("admin:kickall", function()
	TriggerServerEvent("admin:kickall")
end)

RegisterNetEvent('admin:fixcar')
AddEventHandler('admin:fixcar', function() 
    local playerPed = GetPlayerPed(-1)
    local coords = GetEntityCoords(playerPed)
    if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
        local vehicle = nil
        if IsPedInAnyVehicle(playerPed, false) then
        	vehicle = GetVehiclePedIsIn(playerPed, false)
        else
        	vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
        end
        if DoesEntityExist(vehicle) then
            Citizen.CreateThread(function()
            	SetVehicleFixed(vehicle)
            	SetVehicleDeformationFixed(vehicle)
            	SetVehicleUndriveable(vehicle, false)
            	SetVehicleEngineOn(vehicle,  true,  true)			  
           		ESX.ShowNotification(('Vehicle Fixed'))
        	end)
        end
    end
end)

RegisterNetEvent('admin:hijak')
AddEventHandler('admin:hijak', function()       
    local playerPed = GetPlayerPed(-1)
    local coords    = GetEntityCoords(playerPed)
    if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
        local vehicle = nil
        if IsPedInAnyVehicle(playerPed, false) then
            vehicle = GetVehiclePedIsIn(playerPed, false)
        else
            vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
        end
        if DoesEntityExist(vehicle) then
            Citizen.CreateThread(function()
              	SetVehicleDoorsLocked(vehicle, 1)
              	SetVehicleDoorsLockedForAllPlayers(vehicle, false)
              	ESX.ShowNotification(('Vehicle Unlocked'))
            end)
        end
    end
end)

RegisterNetEvent('admin:teleport')
AddEventHandler('admin:teleport', function(temppos)
	SetEntityCoords(PlayerPedId(), temppos.x, temppos.y, temppos.z)
end)

admin.SpawnVehicle = function(model)
	local  playerRank = _playerRank
    if Config.Perms[_playerRank] and Config.Perms[_playerRank].CanSpawnVehicle then
		local coords = GetEntityCoords(PlayerPedId())
		local closestVehicle = ESX.Game.GetClosestVehicle(coords)
		ESX.Game.DeleteVehicle(closestVehicle)
		ESX.Game.SpawnVehicle(model, vector3(coords.x + 2.0, coords.y, coords.z), 0.0, function(vehicle) --get vehicle info
			if DoesEntityExist(vehicle) then
				TaskWarpPedIntoVehicle(PlayerPedId(),  vehicle, -1)
				ESX.ShowNotification("Spawned "..model)			
			end		
		end)
    end
end

admin.Spectate = function(target, bool)
	local  playerRank = _playerRank
    if Config.Perms[_playerRank] and Config.Perms[_playerRank].CanSpectate then
		if bool then
			temppos = GetEntityCoords(PlayerPedId(), false)
			ESX.TriggerServerCallback("admin:spectate", function(callback)
				SetEntityInvincible(PlayerPedId(), true)
				SetEntityVisible(PlayerPedId(), false, false)
				FreezeEntityPosition(PlayerPedId(), true)
				Wait(1000)
				local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
				local name = GetPlayerName(GetPlayerFromServerId(target))
				if targetPed ~= PlayerPedId() then
					
					if (not IsScreenFadedOut() and not IsScreenFadingOut()) then
						DoScreenFadeOut(1000)
						while (not IsScreenFadedOut()) do
							Wait(0)
						end
						local targetx,targety,targetz = table.unpack(GetEntityCoords(targetPed, false))
						RequestCollisionAtCoord(targetx,targety,targetz)
						NetworkSetInSpectatorMode(true, targetPed)
						ESX.ShowNotification("Spectating "..name)
						if(IsScreenFadedOut()) then
							DoScreenFadeIn(1000)
						end
					end
					
				else
					ESX.ShowNotification("You can not spectate yourself.")
				end
			end,target)
			Citizen.CreateThread(function()
				while isSpectating do
					Citizen.Wait(0)
					if IsControlJustPressed(0, 322)  then
						admin.Spectate(playerID, false)
						isSpectating = false
						playerID = nil
					end
				end
			end)
		else
			local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
			local name = GetPlayerName(GetPlayerFromServerId(target))
			if(not IsScreenFadedOut() and not IsScreenFadingOut()) then
				DoScreenFadeOut(1000)
				while (not IsScreenFadedOut()) do
					Wait(0)
				end
				local targetx,targety,targetz = table.unpack(GetEntityCoords(targetPed, false))
				RequestCollisionAtCoord(targetx,targety,targetz)
				NetworkSetInSpectatorMode(false, targetPed)
				ESX.ShowNotification("Stopped spectating "..name)
				if(IsScreenFadedOut()) then
					DoScreenFadeIn(1000)
				end
			end
			if temppos ~= nil then
				SetEntityCoords(PlayerPedId(),temppos)
				SetEntityInvincible(PlayerPedId(), false)
				SetEntityVisible(PlayerPedId(), true, true)
				FreezeEntityPosition(PlayerPedId(), false)
			end
		end
	else
        TriggerEvent('chat:addMessage', {args = {"admin ", " You do not have permission for this."}})
    end
end

admin.Noclip = function()
    if Config.Perms[_playerRank] and Config.Perms[_playerRank].CanNoClip then
		noclip = not noclip
	    local msg = "disabled"
		if noclip then
			msg = "enabled"
		end
		TriggerEvent('chat:addMessage', {args = {"admin ", " Noclip has been " .. msg}})
		ESX.ShowNotification(" Noclip has been " .. msg)
		local heading = 0
		Citizen.CreateThread(function()
			local playerped = PlayerPedId()
			local entity = playerped
			local noclip_pos = GetEntityCoords(PlayerPedId(), false)
			if IsPedInAnyVehicle(playerped) then
				entity =  GetVehiclePedIsUsing(playerped)
			end
			SetEntityCollision(entity, not noclip, not noclip)
        	FreezeEntityPosition(entity, noclip)
        	SetVehicleRadioEnabled(entity, not noclip)
			if noclip then
				SetEntityAlpha(entity, 51, false)
			else
				local reval, z_ = GetGroundZFor_3dCoord(noclip_pos.x, noclip_pos.y, noclip_pos.z)
				SetEntityCoords(entity,noclip_pos.x, noclip_pos.y,z_+1)
				SetEntityVisible(PlayerPedId(), true, true)
        		SetLocalPlayerVisibleLocally(false)
				SetEveryoneIgnorePlayer(PlayerPedId(), false)
        		SetPoliceIgnorePlayer(PlayerPedId(), false)
			end
			local follow = true
			while noclip do
				Citizen.Wait(0)
				SetEntityVisible(PlayerPedId(), false, false)
        		SetLocalPlayerVisibleLocally(true)
				SetEveryoneIgnorePlayer(PlayerPedId(), true)
        		SetPoliceIgnorePlayer(PlayerPedId(), true)
				if follow then
					heading = getCamDirection()
				else
					if(IsControlPressed(1, 34))then
						heading = heading + 1.5
						if(heading > 360)then
							heading = 0
						end
						SetEntityHeading(entity, heading)
					end
					if(IsControlPressed(1, 9))then
						heading = heading - 1.5
						if(heading < 0)then
							heading = 360
						end
						SetEntityHeading(entity, heading)
					end
				end
				if(IsControlJustReleased(0, 74))then
					follow = not follow
					Wait(300)
				end
				if(IsControlPressed(1, 8))then
					noclip_pos = GetOffsetFromEntityInWorldCoords(entity, 0.0, -1.0*Config.Noclip[speed].speed, 0.0)
				end
				if(IsControlPressed(1, 32))then
					noclip_pos = GetOffsetFromEntityInWorldCoords(entity, 0.0, 1.0*Config.Noclip[speed].speed, 0.0)
				end
				if(IsControlPressed(1, 52))then
					noclip_pos = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.0, 1.0*Config.Noclip[speed].speed)
				end
				if(IsControlPressed(1, 48))then
					noclip_pos = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.0, -1.0*Config.Noclip[speed].speed)
				end
				SetEntityVelocity(entity, 0.0, 0.0, 0.0)
            	SetEntityRotation(entity, 0.0, 0.0, 0.0, 0, false)
            	SetEntityHeading(entity, heading)
            	SetEntityCoordsNoOffset(entity, noclip_pos.x, noclip_pos.y, noclip_pos.z, noclip, noclip, noclip)
			end
			ResetEntityAlpha(entity)
		end)
	else
        TriggerEvent('chat:addMessage', {args = {"admin ", " You do not have permission for this."}})
    end
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

RegisterNUICallback("Updateblip", function()
	Updateblip = not Updateblip
    TriggerServerEvent("admin:addUpdateblip", Updateblip)
	if not Updateblip then
		removeAllBlips()
	end
	SetDisplay(false)
end)

RegisterNUICallback("name_on", function()
	head_ = not head_
	if head_ then
		Citizen.CreateThread(function()
			open_name()
		end)
	end
	SetDisplay(false)
end)

function open_name()
	while head_ do
		local sleep = 1000
		local ped = PlayerPedId()
		local x1, y1, z1 = table.unpack( GetEntityCoords( ped, true ) )
		for i,Player in ipairs(GetActivePlayers()) do
			if Player ~= ped  then
				local Ped = GetPlayerPed(Player)
				local x2, y2, z2 = table.unpack( GetEntityCoords( Ped, true ) )
				local distance = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))
				if distance < Config.SettingDisplayOnlyAdmin['Distance'] then
					sleep = 0
					local localFPS = 1 / GetFrameTime()
					local playerHead = GetPedBoneCoords(Ped, 12844, 0, 0, 0) + vector3(0, 0, 0.7) + (GetEntityVelocity(Ped) / localFPS)
					local text = GetPlayerServerId(Player).." |  " .. GetPlayerName(Player)
					if Config.SettingDisplayOnlyAdmin['DrawText'] then
						DrawText3D(playerHead.x, playerHead.y, playerHead.z, text, Config.SettingDisplayOnlyAdmin['Scale'])
					end
					if Config.SettingDisplayOnlyAdmin['Health'] then
						local Health = GetEntityHealth(Ped)
						local r_, g_, b_ = 0,0,0
						local percent = ''
						if Health < 100 then
							Health = 0
							r_, g_, b_ = 0,0,0
							percent = '~b~'..Health..'%'
						else
							Health = (Health - 100)
							if Health < 30 then
								r_, g_, b_ = 255,0,0
								percent = '~r~'..Health..'%'
							elseif Health < 60 then
								percent ='~y~'..Health..'%'
								r_, g_, b_ = 255,255,0
							else
								percent ='~g~'..Health..'%'
								r_, g_, b_ = 0,128,0
							end
						end
						DrawText3D(playerHead.x, playerHead.y, playerHead.z+0.2, percent, Config.SettingDisplayOnlyAdmin['Scale'])
						DrawMarker(3, playerHead.x, playerHead.y, playerHead.z+0.2, 0.0, 0.0, 0.0, 180.0, 0.0, 90.0, 0.1, 0.1, 0.1, r_, g_, b_, 200, false, true, 2, true, false, false, false)
					end
				end
			end
		end
		Citizen.Wait(sleep)
	end
end

RegisterNUICallback('freezeall',function(data)
    TriggerServerEvent("xigy:freezex")
end)

function DrawText3D(x,y,z, text,mul)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov *mul
    if onScreen then
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

function getCamDirection()
	local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(GetPlayerPed(-1))
	return heading
end

RegisterKeyMapping("admin", " Admin Menu", "keyboard", Config.SettingSystem.KeyOpen)

RegisterCommand("admin", function(source,args)
	if _playerRank == nil then
		ESX.TriggerServerCallback("esx_marker:fetchUserRank", function(playerRank)
			_playerRank = playerRank
    	    if Config.Perms[_playerRank] then
				RegisterKeyMapping("Noclip", " Admin NoClip", "keyboard", Config.SettingSystem.KeyNoClip)
    	    	local coords = round(GetEntityCoords(PlayerPedId()), 2)
    	    	SendNUIMessage({type = "coords", coordData = coords})
    			admin.GetPlayers()
    			admin.GetItemList()
    			SetDisplay(true)
    		end
    	end)
	else
		if Config.Perms[_playerRank] then
			local coords = round(GetEntityCoords(PlayerPedId()), 2)
			SendNUIMessage({type = "coords", coordData = coords})
			admin.GetPlayers()
			admin.GetItemList()
			SetDisplay(true)
		end
	end
end)

RegisterCommand("Noclip", function(source,args)
	admin.Noclip()
	Citizen.CreateThread(function()
		while noclip do
			Citizen.Wait(0)
			if IsControlJustPressed(0, 322)  then
				admin.Noclip()
			end
			if IsControlJustPressed(0, 21) then
				speed = speed + 1
				if #Config.Noclip < speed then
					speed = 1
				end
			end
		end
	end)
end)

RegisterCommand('die', function()
	SetEntityHealth(GetPlayerPed(-1), 0)
end)