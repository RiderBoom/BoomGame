ESX = exports["es_extended"]:getSharedObject()

RegisterCommand('checkzone', function(src, args)
    local _source = src
    TriggerClientEvent('checkzonezc', _source)
end,true)
