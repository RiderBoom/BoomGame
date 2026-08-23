ESX = exports["es_extended"]:getSharedObject()

config = {
    getName = function(playerId)
        playerId = tonumber(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        return xPlayer.get('fullname') or GetPlayerName(playerId)
    end
}
