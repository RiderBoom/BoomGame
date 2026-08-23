local RequestId = 0
local serverRequests = {}

local clientCallbacks = {}

---@param eventName string
---@param callback function
---@param ... any
ESX.TriggerServerCallback = function(eventId, callback, ...)
    serverRequests[RequestId] = callback
    TriggerServerEvent("esx:triggerServerCallback", eventId, RequestId, GetInvokingResource() or "unknown", ...)
    RequestId = (RequestId + 1) % 256
end

RegisterNetEvent("esx:serverCallback", function(requestId, invoker, ...)
    local cb = serverRequests[requestId]
    if cb then
        cb(...)
        serverRequests[requestId] = nil -- ลบ callback หลังใช้
    else
        print(("Server Callback with requestId %s called by %s but does not exist."):format(requestId, invoker))
    end
end)

---@param eventName string
---@param callback function
ESX.RegisterClientCallback = function(eventName, callback)
    clientCallbacks[eventName] = callback
end

RegisterNetEvent("esx:triggerClientCallback", function(eventName, requestId, invoker, ...)
    if not clientCallbacks[eventName] then
        return error(("Client Callback not registered, name: ^5%s^7, invoker resource: ^5%s^7"):format(eventName, invoker))
    end

    clientCallbacks[eventName](function(...)
        TriggerServerEvent("esx:clientCallback", requestId, invoker, ...)
    end, ...)
end)
