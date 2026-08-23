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


local earlySpawnTimer
local cam = nil
local FirstSpawn = false
local LastPosition = {}
local angleY = 0.0
local angleZ = 0.0
IsDead = false
r = GetCurrentResourceName()

RegisterFontFile('ft')
fontId = RegisterFontId('FC-Lamoon-Regular-ver-1.00')




RegisterNetEvent('esx_ambulancejob:SetDead')
AddEventHandler('esx_ambulancejob:SetDead', function()
	local player = PlayerPedId()
	SetEntityHealth(player, 0)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)



AddEventHandler('playerSpawned', function()
	IsDead = false
	CheckAddTime = false
	exports["esx_ui_dead"]:CloseUI()
	if FirstSpawn then
		exports.spawnmanager:setAutoSpawn(false) -- disable respawn
		FirstSpawn = false
	end
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
	FreezeEntityPosition(PlayerPedId(), false)
end)



Citizen.CreateThread(function()
    while true do
        Citizen.Wait(6)
        if (cam and isDead) then
            ProcessCamControls()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        
        if (not isDead and NetworkIsPlayerActive(PlayerId()) and IsPedFatallyInjured(PlayerPedId())) then
            isDead = true
            
            StartDeathCam()
        elseif (isDead and NetworkIsPlayerActive(PlayerId()) and not IsPedFatallyInjured(PlayerPedId())) then
            isDead = false
            
            EndDeathCam()
        end
    end
end)

-- Disable most inputs when dead
Citizen.CreateThread(function()
	
	while true do
		if IsDead then
			Citizen.Wait(0)
			DisableAllControlActions(0)

			EnableControlAction(0, 1, true)
			EnableControlAction(0, 2, true)
			EnableControlAction(0, 55, true) -- Spacebar
			EnableControlAction(0, Keys['G'], true)
			EnableControlAction(0, Keys['PAGEUP'], true)
			
			
			DisableControlAction(0, Keys['F1'], true)
			DisableControlAction(0, Keys['F2'], true)
			DisableControlAction(0, Keys['N'], true)
			--EnableControlAction(0, Keys['Z'], true)
            --EnableControlAction(0, Keys['F6'], true)
			--EnableControlAction(0, Keys['X'], true)
			EnableControlAction(0, Keys['DELETE'], true)
			EnableControlAction(0, Keys['HOME'], true)
			EnableControlAction(0, Keys['ESC'], true)
			EnableControlAction(0, Keys['H'], true)
			EnableControlAction(0, Keys['K'], true)
		else
			Citizen.Wait(500)
		end
	end
end)


function OnPlayerDeath()
	IsDead = true
	ESX.UI.Menu.CloseAll()
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', true)
	
	exports["esx_ui_dead"]:OpenUI()

	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	SetEntityCoords(playerPed, playerCoords.x, playerCoords.y, playerCoords.z - 0.98)
	FreezeEntityPosition(PlayerPedId(), true)
	
	if Config.AutoRespawn then
		if exports["stk_check"]:CheckJob('ambulance', 1) then
			StartDeathTimer()
			StartDistressSignal()		
			JumpBody()
			
		else
			StartAutoRespawnTimer()
			JumpBody()
		end

	else
		StartDeathTimer()
		StartDistressSignal()
		JumpBody()
	end
end

function JumpBody()
	Citizen.CreateThread(function()
		local timer = Config.EarlyRespawnTimer
		while timer > 0 and IsDead do
			Citizen.Wait(2)
			timer = timer - 30

			SetTextFont(fontId)
			SetTextProportional(1)
			SetTextScale(0.5, 0.5)
			SetTextColour(185, 185, 185, 255)
			SetTextDropShadow(0, 0, 0, 0, 255)
			SetTextEdge(1, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()
			BeginTextCommandDisplayText('STRING')
			EndTextCommandDisplayText(0.405, 0.765)
			
			exports["esx_ui_dead"]:ClearBodyUi(true)
			if IsControlPressed(0, Keys['H']) then
				if IsDead then
					ClearPedTasksImmediately(GetPlayerPed(-1))
					exports["esx_ui_dead"]:ClearBodyUi(false)
				end

				Citizen.Wait(10 * 1000)
			end
		end
	end)
end

RegisterNetEvent('esx_ambulancejob:useItem')
AddEventHandler('esx_ambulancejob:useItem', function(itemName)
	ESX.UI.Menu.CloseAll()

	if itemName == 'medikit' then
		local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
		local playerPed = PlayerPedId()

		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

			TriggerEvent("mythic_progbar:client:progress", {
				name = "unique_action_name",
				duration = Config.MedikitTime * 1000,
				label = "กำลังใช้ยารักษา...",
				useWhileDead = false,
				canCancel = false,
				controlDisables = {
					disableMovement = false,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
				}
			},   
				function(status)
					if not status then
					end
			end)
			Citizen.Wait(Config.MedikitTime * 1000)
			while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
				Citizen.Wait(0)
				DisableAllControlActions(0)
			end
	
			local hp = GetEntityHealth(playerPed)
			if hp < 200 then
				SetEntityHealth(GetPlayerPed(-1), hp + Config.MedikitHealth)
			end
		end)
	elseif itemName == 'bandage' then
		local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
		local playerPed = PlayerPedId()

		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
			
			Citizen.Wait(Config.BandageTime * 1000)
			ClearPedTasks(PlayerPedId())
			while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
				Citizen.Wait(0)
				DisableAllControlActions(0)
				EnableControlAction(0, 1, true)
				EnableControlAction(0, 2, true)
			end
			local hp = GetEntityHealth(playerPed)
			if hp < 200 then
				SetEntityHealth(GetPlayerPed(-1), hp + Config.BandageHealth )
			end
		end)
	end
end)



RegisterNetEvent('meeta_ambulance:cpr')
AddEventHandler('meeta_ambulance:cpr', function()
	AedRevivePlayer()
	Wait(Config.WaitTimeAED * 1000)
	ClearPedTasks(PlayerPedId())
end)


function AedRevivePlayer()
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	
	if closestPlayer == -1 or closestDistance > 1.3 then
		TriggerEvent("pNotify:SendNotification", {
		text = "ไม่มีผู้เล่นอยู่ใกล้ๆ",
		type = "error",
		timeout = 3000,
		layout = "bottomcenter",
		queue = "global"
		})
	else
		IsBusy = true
		local closestPlayerPed = GetPlayerPed(closestPlayer)
		
		if IsPedDeadOrDying(closestPlayerPed, 1) then
			local playerPed = PlayerPedId()
								
			local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
				for i=1, 9, 1 do
					Citizen.Wait(350)		
					ESX.Streaming.RequestAnimDict(lib, function()
						TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
					end)
				end
				
			TriggerEvent("mythic_progbar:client:progress", {		 
			name = "unique_action_name",
			duration = Config.WaitTimeAED * 1000,
			label = "REVIVE IN PROCESS",
			useWhileDead = false,
			canCancel = true,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = false,
				disableMouse = false,
				disableCombat = false,
			},		
			}, function(status)
				if not status then
					-- Do Something If Event Wasn't Cancelled
				end
			end)	
			Citizen.Wait(Config.WaitTimeAED * 1000)
			if not IsEntityDead(PlayerPedId()) then
				TriggerServerEvent('esx_ambulancejob:RemoveItem', 'AED')
				TriggerServerEvent('esx_ambulancejob:reviveAED', GetPlayerServerId(closestPlayer))
			end
		else
			TriggerEvent("pNotify:SendNotification", {
				text = 'ผู้เล่นไม่ได้หมดสติ',
				type = "error",
				timeout = 2000,
				layout = "centerLeft"
			})
        end
    end
end



function StartDistressSignal()
	Citizen.CreateThread(function()
		local timer = Config.EarlyRespawnTimer

		while timer > 0 and IsDead do
			Citizen.Wait(7)
			timer = timer - 30

			SetTextFont(fontId)
			SetTextProportional(1)
			SetTextScale(0.45, 0.45)
			SetTextColour(185, 185, 185, 255)
			SetTextDropShadow(0, 0, 0, 0, 255)
			SetTextEdge(1, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()
			BeginTextCommandDisplayText('STRING')
			EndTextCommandDisplayText(0.175, 0.805)
			
			exports["esx_ui_dead"]:SendSignalUi(true)
			exports["esx_ui_dead"]:SendGangSignalUi(true)

			if IsControlPressed(0, Keys['G']) and IsDead and timer > 0 then
				SendDistressSignal('doctor')
				exports["esx_ui_dead"]:SendSignalUi(false)

				Citizen.Wait(3 * 60000)
			end
			
			if IsControlPressed(0, Keys['K']) and IsDead and timer > 0 then
				SendDistressSignal('gang')
				exports["esx_ui_dead"]:SendGangSignalUi(false)

				Citizen.Wait(3 * 60000)
			end
		end
	end)
end




function SendDistressSignal(xSend)
	local playerPed = PlayerPedId()
	PedPosition		= GetEntityCoords(playerPed)
	local PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z }

	if xSend == 'doctor' then
		local send = 'ช่วยด้วย!! ชื่อ ' ..GetPlayerName(PlayerId()).. 'ต้องการความช่วยเหลือ'
		local sendToDiscord = '' .. GetPlayerName(PlayerId()) .. ' กดเคสเรียกหมอที่ '..PedPosition..''

		TriggerEvent('Zc_SendAlert', 'ambulance', 'หมอ', 'มีคนสลบ')
		TriggerServerEvent('esx_addons_gcphone:startCall', 'ambulance', send, PlayerCoords, {
			PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z },
		})
		
	elseif xSend == 'gang' then
		local sendToDiscord = '' .. GetPlayerName(PlayerId()) .. ' กดเคสเรียกแก๊งที่ '..PedPosition..''
		getJob = ESX.PlayerData.job.name
		TriggerEvent('Zc_SendAlert', getJob , 'เพื่อนหมดสติ', 'เพื่อนหมดสติ')
		
	end
end



function DrawGenericTextThisFrame()
	SetTextFont(fontId)
	SetTextProportional(0)
	SetTextScale(0.0, 0.5)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)
end

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

function StartAutoRespawnTimer()
	
	if CheckItem(Config.ItemReducetime) then
		autoSpawnTimer = ESX.Round(Config.AutoRespawnTimer_VIP / 1000)
	else
		autoSpawnTimer = ESX.Round(Config.AutoRespawnTimer / 1000)
	end

	exports["esx_ui_dead"]:ClearBodyUi(true)
	exports["esx_ui_dead"]:SendSignalUi(false)

	Citizen.CreateThread(function()
		while autoSpawnTimer > 0 and IsDead do
			Citizen.Wait(1000)
			
			if autoSpawnTimer > 0 then
				autoSpawnTimer = autoSpawnTimer - 1
			end
		end
	end)

	Citizen.CreateThread(function()
		local text, timeHeld
		local hold = 0


		while autoSpawnTimer > 0 and IsDead do
			Citizen.Wait(0)
			text = _U('respawn_available_in', secondsToClock(autoSpawnTimer))
			-- DrawGenericTextThisFrame()
			-- SetTextEntry("STRING")
			-- AddTextComponentString(text)
			-- DrawText(0.5, 0.8)
			exports["esx_ui_dead"]:RespawnTime(text)
		end


		while autoSpawnTimer < 1 and IsDead do
			Wait(0)
			local text2 = '[ G ] ค้าง เพื่อฟื้นตัวเอง ' .. Config.RemoveMoneyNoDoctor .. '$'
			
			DrawGenericTextThisFrame()
			SetTextEntry("STRING")
			AddTextComponentString(text2)
			DrawText(0.5, 0.8)
			if IsControlPressed(0, Keys['G']) then
				hold = hold + 1
				if hold == 50 then
					if Checkmoney(Config.RemoveMoneyNoDoctor) then
						TriggerServerEvent('esx_ambulancejob:removemoney', 'money', Config.RemoveMoneyNoDoctor)
						TriggerEvent('esx_ambulancejob:revive')
					else
						TriggerServerEvent('esx_ambulancejob:removemoney', 'bank', Config.RemoveMoneyNoDoctor)
						TriggerEvent('esx_ambulancejob:revive')
					end
					hold = 0
					break
				end
			end
		end
		
	end)
end



function StartDeathTimer()
	local canPayFine = false

	if Config.EarlyRespawnFine then
		if Checkmoney(Config.EarlyRespawnFineAmount) then 
			canPayFine = true
		end
	end

	if CheckItem(Config.ItemReducetime) then
		earlySpawnTimer = ESX.Math.Round(Config.EarlyRespawnTimer_VIP / 1000)
	else
		earlySpawnTimer = ESX.Math.Round(Config.EarlyRespawnTimer / 1000)
	end
	
	
	local bleedoutTimer = ESX.Math.Round(Config.BleedoutTimer / 1000)
	

	Citizen.CreateThread(function()
		-- early respawn timer
		while earlySpawnTimer > 0 and IsDead do
			Citizen.Wait(1000)

			if earlySpawnTimer > 0 then
				earlySpawnTimer = earlySpawnTimer - 1
			end
		end

		-- bleedout timer
		while bleedoutTimer > 0 and IsDead do
			Citizen.Wait(1000)

			if bleedoutTimer > 0 then
				bleedoutTimer = bleedoutTimer - 1
			end
		end
	end)

	Citizen.CreateThread(function()
		local text, timeHeld

		-- early respawn timer
		while earlySpawnTimer > 0 and IsDead do
			
			Citizen.Wait(0)
			text = _U('respawn_available_in', secondsToClock(earlySpawnTimer))

			-- DrawGenericTextThisFrame()
			-- SetTextEntry("STRING")
			-- AddTextComponentString(text)
			-- DrawText(0.5, 0.8)
			exports["esx_ui_dead"]:RespawnTime(text)
		end

		-- bleedout timer
		while bleedoutTimer > 0 and IsDead do
			Citizen.Wait(0)
			text = _U('respawn_bleedout_in', secondsToClock(bleedoutTimer))

			if not Config.EarlyRespawnFine then

				if IsControlPressed(0, Keys['H']) and timeHeld > 60 then
					RemoveItemsAfterRPDeath()
					break
				end
			elseif Config.EarlyRespawnFine and canPayFine then
				text = text .. _U('respawn_bleedout_fine', ESX.Math.GroupDigits(Config.EarlyRespawnFineAmount))

				if IsControlPressed(0, Keys['H']) and timeHeld > 60 then
					TriggerServerEvent('esx_ambulancejob:payFine')
					RemoveItemsAfterRPDeath()
					break
				end
			end

			if IsControlPressed(0, Keys['H']) then
				timeHeld = timeHeld + 1
			else
				timeHeld = 0
			end

			DrawGenericTextThisFrame()

			SetTextEntry("STRING")
			AddTextComponentString(text)
			DrawText(0.5, 0.8)
			-- RespawnTime(text)
		end
			
		if bleedoutTimer < 1 and IsDead then
			RemoveItemsAfterRPDeath()
		end
	end)
end

function RemoveItemsAfterRPDeath()
	exports["esx_ui_dead"]:CloseUI()

	TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
	TriggerServerEvent("esx_ambulancejob:TimeOutDie")
	

	Citizen.CreateThread(function()
		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end

		Citizen.CreateThread(function()
			DoScreenFadeOut(800)

			while not IsScreenFadedOut() do
				Citizen.Wait(10)
			end

			ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function()
				local formattedCoords = {
					x = Config.RespawnPoint.coords.x,
					y = Config.RespawnPoint.coords.y,
					z = Config.RespawnPoint.coords.z
				}

				ESX.SetPlayerData('lastPosition', formattedCoords)
				ESX.SetPlayerData('loadout', {})

				TriggerServerEvent('esx:updateLastPosition', formattedCoords)
				RespawnPedToHospital(PlayerPedId(), formattedCoords, Config.RespawnPoint.heading)

				StopScreenEffect('DeathFailOut')
				DoScreenFadeIn(800)
			end)
		end)
		
		SetEntityCoords(PlayerPedId(), Config.RespawnPoint.coords.x, Config.RespawnPoint.coords.y, Config.RespawnPoint.coords.z)
		SetEntityHeading(PlayerPedId(), Config.RespawnPoint.heading)
		TriggerEvent("esx_ambulancejob:revive")
	end)
end

function RespawnPedToHospital(ped, coords, heading)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
	ClearPedBloodDamage(ped)
	local playerPed = GetPlayerPed(-1)
	local x,y,z = table.unpack(GetEntityCoords(playerPed))
	local object = GetClosestObjectOfType(x, y, z, 15.0, GetHashKey('prop_water_corpse_01'), false, false, false)
	SetEntityVisible(playerPed, true, 0)
	StopScreenEffect('DeathFailOut')
	StopScreenEffect('MenuMGIn')
	if object ~= 0 then
		DeleteObject(object)
	end
	ESX.UI.Menu.CloseAll()
end


RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	local specialContact = {
		name       = 'Ambulance',
		number     = 'ambulance',
		base64Icon = 'data:image/png;base64,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'
	}

	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)


AddEventHandler('esx:onPlayerDeath', function(data)
	OnPlayerDeath()
	TriggerEvent('esx_inventoryhud:cl')
	TriggerEvent("esx_inventoryhud:closeHud")
	ESX.UI.Menu.CloseAll()
end)



RegisterNetEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
	

	Citizen.CreateThread(function()
		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(50)
		end

		local formattedCoords = {
			x = coords.x,
			y = coords.y,
			z = coords.z,
		}
		

		ESX.SetPlayerData('lastPosition', formattedCoords)
		TriggerServerEvent('esx:updateLastPosition', formattedCoords)

		RespawnPed(playerPed, formattedCoords, 0.0)

		StopScreenEffect('DeathFailOut')
		DoScreenFadeIn(800)
		ClearTimecycleModifier()
		ResetScenarioTypesEnabled()
		ResetPedMovementClipset(playerPed, 0)
		SetPedIsDrunk(playerPed, false)
		SetPedMotionBlur(playerPed, false)
		ClearPedSecondaryTask(playerPed)
		ShakeGameplayCam("DRUNK_SHAKE", 0.0)
		SetPedMoveRateOverride(PlayerPedId(), 1.0)
		FreezeEntityPosition(playerPed, false)
		DetachEntity(PlayerPedId())
		IsDead = false
		
	end)
end)


function RespawnPed(ped, coords, heading)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
	ClearPedBloodDamage(ped)
	SetEntityHealth(ped, Config.SetHelathRevive + 100)
	ESX.UI.Menu.CloseAll()
end



-- Load unloaded IPLs
if Config.LoadIpl then
	Citizen.CreateThread(function()
		RequestIpl('Coroner_Int_on') -- Morgue
	end)
end


RegisterCommand("die", function()
	TriggerEvent("mythic_progbar:client:progress", {
		name = "unique_action_name",
		duration = 3000,
		label = "กำลังฆ่าตัวตาย...",
		useWhileDead = true,
		canCancel = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = "mp_suicide",
			anim = "pill",
		},
		prop = {
			--model = "prop_paper_bag_small",
		}
	}, function(status)
		if not status then
			-- Do Something If Event Wasn't Cancelled
		end
	end)
	Wait(3000)
	SetEntityHealth(GetPlayerPed(-1), 0)
end)

RegisterNetEvent('esx_ambulancejob:reviveall')
AddEventHandler('esx_ambulancejob:reviveall', function()
	local player = PlayerPedId()
	if IsEntityDead(player) then
		TriggerEvent('esx_ambulancejob:revive')
	end
	ESX.ShowNotification('Revive All By Admin')
end)


RegisterNetEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function()
	if GetEntityHealth(GetPlayerPed(-1)) <= 200 then
		SetEntityHealth(GetPlayerPed(-1), 200)
	end
end)


RegisterNetEvent('esx_ambulancejob:healfood')
AddEventHandler('esx_ambulancejob:healfood', function()
	if GetEntityHealth(GetPlayerPed(-1)) <= 200 then
		SetEntityHealth(GetPlayerPed(-1), 200)
	end
	
	TriggerEvent('esx_status:set', 'hunger', 1000000)
	TriggerEvent('esx_status:set', 'thirst', 1000000)
	TriggerEvent('esx_status:set', 'stress', 0)
end)



function StartDeathCam()
    ClearFocus()

    local playerPed = PlayerPedId()
    
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, GetGameplayCamFov())

    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, false)
end

-- destroy camera
function EndDeathCam()
    ClearFocus()

    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cam, false)
    
    cam = nil
end


function ProcessCamControls()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    DisableFirstPersonCamThisFrame()

    local newPos = ProcessNewPosition()

    SetFocusArea(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
    
    SetCamCoord(cam, newPos.x, newPos.y, newPos.z)
    
    PointCamAtCoord(cam, playerCoords.x, playerCoords.y, playerCoords.z + 0.5)
end


function ProcessNewPosition()
    local mouseX = 0.0
    local mouseY = 0.0
    
    if (IsInputDisabled(0)) then
        mouseX = GetDisabledControlNormal(1, 1) * 8.0
        mouseY = GetDisabledControlNormal(1, 2) * 8.0
        
    else
        mouseX = GetDisabledControlNormal(1, 1) * 1.5
        mouseY = GetDisabledControlNormal(1, 2) * 1.5
    end

    angleZ = angleZ - mouseX
    angleY = angleY + mouseY

    if (angleY > 89.0) then angleY = 89.0 elseif (angleY < -89.0) then angleY = -89.0 end
    
    local pCoords = GetEntityCoords(PlayerPedId())
    
    local behindCam = {
        x = pCoords.x + ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * (2 + 0.5),
        y = pCoords.y + ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * (2 + 0.5),
        z = pCoords.z + ((Sin(angleY))) * (2 + 0.5)
    }
    local rayHandle = StartShapeTestRay(pCoords.x, pCoords.y, pCoords.z + 0.5, behindCam.x, behindCam.y, behindCam.z, -1, PlayerPedId(), 0)
    local a, hitBool, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    
    local maxRadius = 2
    if (hitBool and Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords) < 2 + 0.5) then
        maxRadius = Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords)
    end
    
    local offset = {
        x = ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * maxRadius,
        y = ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * maxRadius,
        z = ((Sin(angleY))) * maxRadius
    }
    
    local pos = {
        x = pCoords.x + offset.x,
        y = pCoords.y + offset.y,
        z = pCoords.z + offset.z
    }
    
    return pos
end

if Config.AutoMovePlayerOutWater then
	local MoveOutWater = false
	local Ground
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(3500)
			local p = PlayerPedId()
			local c = GetEntityCoords(p)
			
			if not MoveOutWater then
				if not IsEntityInWater(p) then
					Ground = c
				end

				if IsEntityInWater(p) and IsEntityDead(p) then
					SetEntityCoords(p, Ground.x, Ground.y, Ground.z)
					ClearPedTasksImmediately(p)
					MoveOutWater = true
				end
			end
		end
	end)
end


function Checkmoney(amount)
    local account = ESX.GetPlayerData().accounts
    for k,v in pairs(account) do
        if v.name == 'money' then
            if v.money >= amount then
                return true
            end
        end
    end
    return false
end
