local serverCallbacks = {}

local clientRequests = {}
local RequestId = 0

---@param eventName string
---@param callback function
ESX.RegisterServerCallback = function(eventName, callback)
    serverCallbacks[eventName] = callback
end

RegisterNetEvent("esx:triggerServerCallback", function(eventName, requestId, invoker, ...)
    local src = source
    if not serverCallbacks[eventName] then
        print(("Server Callback not registered, name: %s, invoker: %s"):format(eventName, invoker))
        return
    end

    -- เรียก callback function
    serverCallbacks[eventName](src, function(...)
        -- ส่งกลับ Client หลังเรียก callback แล้ว
        TriggerClientEvent("esx:serverCallback", src, requestId, invoker, ...)
    end, ...)
end)

---@param player number playerId
---@param eventName string
---@param callback function
---@param ... any
ESX.TriggerClientCallback = function(player, eventName, callback, ...)
    clientRequests[RequestId] = callback

    TriggerClientEvent("esx:triggerClientCallback", player, eventName, RequestId, GetInvokingResource() or "unknown", ...)

    RequestId = RequestId + 1
end

RegisterNetEvent("esx:clientCallback", function(requestId, invoker, ...)
    if not clientRequests[requestId] then
        return error(("Client Callback with requestId ^5%s^7 Was Called by ^5%s^7 but does not exist."):format(requestId, invoker))
    end

    clientRequests[requestId](...)
    clientRequests[requestId] = nil
end)
