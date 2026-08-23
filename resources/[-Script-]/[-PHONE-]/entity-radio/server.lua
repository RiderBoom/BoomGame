
local route = {}
local playersNames = {}
local thisScript = GetCurrentResourceName()
local hash = {
    req = tostring(GetHashKey(thisScript .. ':req')),
    res = tostring(GetHashKey(thisScript .. ':res')),
    getname = tostring(GetHashKey('getname'))
}


RegisterNetEvent('esx:onPlayerSpawn')
AddEventHandler('esx:onPlayerSpawn', function()
    local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('rp_radio:setPlayerJob:client', source, xPlayer.job.name)
end)


function registerServerlCallback(name, cb)
    route[name] = cb
end

RegisterNetEvent(hash.req, function(name, ...)
    local playerId = source
    route[name](playerId, ...)
end)

registerServerlCallback(hash.getname, function(playerId, data)
    if type(data) == 'table' then
        local players = {}
        for id, _ in pairs(data) do
            if not playersNames[id] then
                playersNames[id] = config.getName(id)
            end
            players[id] = playersNames[id]
        end
        TriggerClientEvent(hash.res, playerId, players)
        return
    end
    if not playersNames[data] then
        playersNames[data] = config.getName(data)
    end
    TriggerClientEvent(hash.res, playerId, playersNames[data])
end)