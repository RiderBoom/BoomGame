posX = -0.015
posY = -0.05

width = 0.183
height = 0.24


-- local playerSpawn = true
-- AddEventHandler('playerSpawned', function()
    -- if playerSpawn then
        -- while not NetworkIsPlayerActive(PlayerId()) or not DoesEntityExist(PlayerPedId()) do
            -- Citizen.Wait(100)
        -- end

        -- local ped = PlayerPedId()
        -- local model = GetEntityModel(ped)

        -- RequestModel(model)
        -- while not HasModelLoaded(model) do
            -- Citizen.Wait(100)
        -- end
		

		-- SettingCircleMap()
        -- playerSpawn = false
    -- end
-- end)


Citizen.CreateThread(function()
    while true do
        Wait(2000)
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            SettingCircleMap()
            break
        end
    end
end)





function SettingCircleMap()
	RequestStreamedTextureDict("circlemap", false)
	while not HasStreamedTextureDictLoaded("circlemap") do
		Wait(100)
	end

	AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")
	SetMinimapClipType(1)
	SetMinimapComponentPosition('minimap', 'L', 'B', posX, posY - 0.05, width, height)
	SetMinimapComponentPosition('minimap_mask', 'L', 'B', posX, posY, width, height)
	SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.015, -0.05, 0.256, 0.337)

	local minimap = RequestScaleformMovie("minimap")
	SetRadarBigmapEnabled(true, false)
	Wait(50)
	SetRadarBigmapEnabled(false, false)

	Citizen.CreateThread(function()
		while true do
			Wait(100)
			BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
			ScaleformMovieMethodAddParamInt(3)
			EndScaleformMovieMethod()
		end
	end)
end



AddEventHandler("svrp-gameplay:enteredVehicle", function()
	SendNUIMessage({
		action = "displayUI"
	})
end)


AddEventHandler("svrp-gameplay:exitVehicle", function()
	SendNUIMessage({
		action = "hideUI"
	})
end)


local pauseMenu = false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1200)
		
		if IsPauseMenuActive() and not pauseMenu then
			pauseMenu = true
			SendNUIMessage({
				open = 30,
			}) 
			if IsPedInAnyVehicle(PlayerPedId()) then
				SendNUIMessage({
					action = "hideUI"
				})
			end
		elseif not IsPauseMenuActive() and pauseMenu then
			pauseMenu = false
			if IsPedInAnyVehicle(PlayerPedId()) then
				SendNUIMessage({
					action = "displayUI"
				})
			end
		end
	end
end)


Citizen.CreateThread(function()
    while true do 
        local player = PlayerPedId(-1)
		local sleepWalk = 1000
        
		if IsPedSittingInAnyVehicle(player) and not IsPlayerDead(player) then sleepWalk = 500
            DisplayRadar(true)
            vehicle = GetVehiclePedIsIn(player)
            speed = GetEntitySpeed(vehicle)
        elseif not IsPedSittingInAnyVehicle(player) then sleepWalk = 500
            DisplayRadar(false)
        end

		Citizen.Wait(sleepWalk)
	end
end)