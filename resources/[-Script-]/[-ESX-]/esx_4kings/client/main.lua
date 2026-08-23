ESX = exports['es_extended']:getSharedObject()

local PlayerData = {}

Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

local function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end

Citizen.CreateThread(function()
    while true do
        local sleep = 1500
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if PlayerData.job then
            for factionName, data in pairs(Config.Factions) do
                if PlayerData.job.name == factionName or PlayerData.job.name == data.offJob then
                    for locType, coords in pairs(data.Locations) do
                        local dist = #(playerCoords - coords)
                        if dist < Config.DrawDistance then
                            sleep = 0
                            DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 0.5, 0, 150, 255, 100, false, true, 2, false, nil, nil, false)
                            if dist < 1.5 then
                                local text = "[E] " .. locType
                                if locType == 'Duty' then
                                    text = "[E] สลับสถานะเข้า/ออกเวร (" .. data.label .. ")"
                                elseif locType == 'Armory' then
                                    text = "[E] คลังอุปกรณ์ (" .. data.label .. ")"
                                elseif locType == 'Boss' then
                                    text = "[E] เมนูหัวหน้าสถาบัน (" .. data.label .. ")"
                                end
                                DrawText3D(coords, text)

                                if IsControlJustReleased(0, 38) then -- Key E
                                    TriggerServerEvent('esx_4kings:interact', factionName, locType)
                                end
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)
