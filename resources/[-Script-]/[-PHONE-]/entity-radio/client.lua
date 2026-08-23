ESX = exports["es_extended"]:getSharedObject()

local PlayerJob = nil

RegisterNetEvent('rp_radio:setPlayerJob:client')
AddEventHandler('rp_radio:setPlayerJob:client', function(job)
	PlayerJob = job
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerJob = job.name
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
		if PlayerJob == "police" or PlayerJob == "ambulance" or PlayerJob == "mechanic" or PlayerJob == "mod" or PlayerJob == "admin" then
			-- print(true)
            exports["rp-radio"]:GivePlayerAccessToFrequencies(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
		else
            exports["rp-radio"]:RemovePlayerAccessToFrequencies(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
			-- print(false)
        end
    end
    GenerateFrequencyList()
end)


local thisScript = GetCurrentResourceName()
local hash = {
    req = tostring(GetHashKey(thisScript .. ':req')),
    res = tostring(GetHashKey(thisScript .. ':res')),
    getname = tostring(GetHashKey('getname'))
}
local currentReq

function sendNui(action, data)
    data.action = action
    SendNUIMessage(data)
end

function sendReq(name, cb, ...)
    while currentReq do
        Wait(0)
    end
    if type(cb) ~= 'function' then return print('^1 cb wrong type') end
    currentReq = cb
    TriggerServerEvent(hash.req, name, ...)
end

RegisterNetEvent(hash.res, function(...)
    if not currentReq then return end
    currentReq(...)
    currentReq = nil
end)

RegisterNetEvent('pma-voice:syncRadioData', function(rawData)
    sendReq(hash.getname, function(playersData)
        local players = {}
        for id, name in pairs(playersData) do
            players[tostring(id)] = {
                isTaking = false,
                name = name
            }
        end
        sendNui('init', {
            myId = GetPlayerServerId(PlayerId()),
            players = players
        })
    end, rawData)
end)

RegisterNetEvent('pma-voice:addPlayerToRadio', function(playerId)
    sendReq(hash.getname, function(name)
        sendNui('add', {
            src = tostring(playerId),
            player = {
                name = name,
                isTaking = false
            }
        })
    end, playerId)
end)

RegisterNetEvent('pma-voice:removePlayerFromRadio', function(playerId)
    sendNui('remove', {
        src = tostring(playerId),
    })
end)

RegisterNetEvent('pma-voice:setTalkingOnRadio', function(playerId, enabled)
    sendNui('talk', {
        src = tostring(playerId),
        isTaking = enabled
    })
end)

RegisterCommand('_entity_radio:enable', function()
    sendNui('debug')
end)