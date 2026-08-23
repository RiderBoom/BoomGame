local isInVehicle, isEnteringVehicle, inPauseMenu = false, false, false, false
local playerPed = PlayerPedId()
local current = {}

local function GetPedVehicleSeat(ped, vehicle)
    for i = -1, 16 do
        if GetPedInVehicleSeat(vehicle, i) == ped then
            return i
        end
    end
    return -1
end

local function GetData(vehicle)
    if not DoesEntityExist(vehicle) then
        return
    end
    local model = GetEntityModel(vehicle)
    local displayName = GetDisplayNameFromVehicleModel(model)
    local netId = vehicle
    if NetworkGetEntityIsNetworked(vehicle) then
        netId = VehToNet(vehicle)
    end
    return displayName, netId
end

local function ToggleVehicleStatus(inVehicle, seat)
    ESX.SetPlayerData("vehicle", inVehicle)
    ESX.SetPlayerData("seat", seat)
end


CreateThread(function()
    while not ESX.PlayerLoaded do Wait(500) end

    playerPed = PlayerPedId()
    ESX.SetPlayerData("ped", playerPed)

    if Config.DisableHealthRegeneration then
        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
    end

    while true do
        local ped = PlayerPedId()
        local sleep = 1000

        ESX.SetPlayerData("coords", GetEntityCoords(ped))

        if ped ~= playerPed then
            playerPed = ped
            ESX.SetPlayerData("ped", ped)
            TriggerEvent("esx:playerPedChanged", ped)
            TriggerServerEvent("esx:playerPedChanged", PedToNet(ped))
        end

        if IsPauseMenuActive() then
            if not inPauseMenu then
                inPauseMenu = true
                TriggerEvent("esx:pauseMenuActive", true)
            end
        elseif inPauseMenu then
            inPauseMenu = false
            TriggerEvent("esx:pauseMenuActive", false)
        end

        if not isInVehicle and not IsPlayerDead(PlayerId()) then
            local tryingVeh = GetVehiclePedIsTryingToEnter(ped)

            if DoesEntityExist(tryingVeh) and not isEnteringVehicle then
                local plate = GetVehicleNumberPlateText(tryingVeh)
                local seat = GetSeatPedIsTryingToEnter(ped)
                local _, netId = GetData(tryingVeh)

                isEnteringVehicle = true
                TriggerEvent("esx:enteringVehicle", tryingVeh, plate, seat, netId)
                TriggerServerEvent("esx:enteringVehicle", plate, seat, netId)
                ToggleVehicleStatus(tryingVeh, seat)
                sleep = 200 
            elseif not DoesEntityExist(tryingVeh) and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
                isEnteringVehicle = false
                TriggerEvent("esx:enteringVehicleAborted")
                TriggerServerEvent("esx:enteringVehicleAborted")
                ToggleVehicleStatus(false, false)
            elseif IsPedInAnyVehicle(ped, false) then
                isEnteringVehicle = false
                isInVehicle = true

                current.vehicle = GetVehiclePedIsUsing(ped)
                current.seat = GetPedVehicleSeat(ped, current.vehicle)
                current.plate = GetVehicleNumberPlateText(current.vehicle)
                current.displayName, current.netId = GetData(current.vehicle)

                TriggerEvent("esx:enteredVehicle", current.vehicle, current.plate, current.seat, current.displayName, current.netId)
                TriggerServerEvent("esx:enteredVehicle", current.plate, current.seat, current.displayName, current.netId)
                ToggleVehicleStatus(current.vehicle, current.seat)
                sleep = 200
            end
        elseif isInVehicle then
            -- ออกจากรถหรือตาย
            if (current.vehicle ~= GetVehiclePedIsUsing(ped)) or IsPlayerDead(PlayerId()) then
                TriggerEvent("esx:exitedVehicle", current.vehicle, current.plate, current.seat, current.displayName, current.netId)
                TriggerServerEvent("esx:exitedVehicle", current.plate, current.seat, current.displayName, current.netId)
                isInVehicle = false
                current = {}
                ToggleVehicleStatus(false, false)
            else
                sleep = 500 
            end
        end

        Wait(sleep)
    end
end)




if Config.EnableDebug then
    AddEventHandler("esx:playerPedChanged", function(netId)
        print("esx:playerPedChanged", netId)
    end)

    AddEventHandler("esx:enteringVehicle", function(vehicle, plate, seat, netId)
        print("esx:enteringVehicle", "vehicle", vehicle, "plate", plate, "seat", seat, "netId", netId)
    end)

    AddEventHandler("esx:enteringVehicleAborted", function()
        print("esx:enteringVehicleAborted")
    end)

    AddEventHandler("esx:enteredVehicle", function(vehicle, plate, seat, displayName, netId)
        print("esx:enteredVehicle", "vehicle", vehicle, "plate", plate, "seat", seat, "displayName", displayName, "netId", netId)
    end)

    AddEventHandler("esx:exitedVehicle", function(vehicle, plate, seat, displayName, netId)
        print("esx:exitedVehicle", "vehicle", vehicle, "plate", plate, "seat", seat, "displayName", displayName, "netId", netId)
    end)
end
