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


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)


function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

Citizen.CreateThread(function()
    while true do
        local sleepMRPK = 1000
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			if (ESX.PlayerData.job and ESX.PlayerData.job.name == 'police') then sleepMRPK = 5
				for k in pairs(Config.FixZone) do	
					DrawMarker(1, Config.FixZone[k].x, Config.FixZone[k].y, Config.FixZone[k].z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.5, 3.5, 1.0, 51, 97, 224, 100, 0, 0, 0, 0)	
				end
			end
		end
		Citizen.Wait(sleepMRPK)
    end
end)

Citizen.CreateThread(function()
    while true do
        
		local sleepKKK = 1000
		
		if (ESX.PlayerData.job and ESX.PlayerData.job.name == 'police') then
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				for k in pairs(Config.FixZone) do
					local ped = PlayerPedId()
					local pedcoords = GetEntityCoords(ped, false)
					local distance = Vdist(pedcoords.x, pedcoords.y, pedcoords.z, Config.FixZone[k].x, Config.FixZone[k].y, Config.FixZone[k].z-1)
					
					if distance <= 3.5 then sleepKKK = 5

							DisplayHelpText('Press [ E ] to repair vehicle.')
							
							if IsControlJustPressed(0, Keys['E']) then			
								TriggerEvent('police_repair:start')
								Citizen.Wait(Config.ProgressWait * 1000)
							end
					elseif distance < 3.5 then
						ESX.UI.Menu.CloseAll()
					end
					
				end
			end
		end
		Citizen.Wait(sleepKKK)
    end
end)



RegisterNetEvent("police_repair:start")
AddEventHandler("police_repair:start", function()
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)
	local vehicle
	
	if IsPedInAnyVehicle(playerPed, false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
	end
	
	TriggerEvent("mythic_progbar:client:progress", {
        name = "unique_action_name",
        duration = Config.ProgressWait * 1000,
        label = "ระบบกำลังซ่อมรถ...",
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
		}, 
		function(status)
			if not status then
		end
	end)
    Citizen.Wait(Config.ProgressWait * 1000)
	TriggerServerEvent('esx_policejob:money_fix')
	SetVehicleFixed(vehicle)
	SetVehicleDeformationFixed(vehicle)
	SetVehicleUndriveable(vehicle, false)
	TriggerEvent("pNotify:SendNotification", {
		text = "ซ่อมรถเสร็จเรียบร้อยแล้ว !!",
		type = "success",
		timeout = 3000,
		layout = "bottomCenter",
		queue = "global"
	})
end)