ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('checkzonezc')
AddEventHandler('checkzonezc', function()
    local zcEnter = false
    local newcoord = false
    local large = 0
    local up = 0
    checkzone = not checkzone
    Citizen.CreateThread(function()
        while checkzone do
            local coords = GetEntityCoords(PlayerPedId())
            if IsControlJustPressed(0, 191) then -- Right
                if not zcEnter then
                    zcEnter = true
                    newcoord = GetEntityCoords(PlayerPedId())
                else
                    zcEnter = false
                end
            end
            if zcEnter then
                zccoords = newcoord
                Status = '~w~Status~r~:Lock'
            else
                zccoords = coords

                Status = '~w~Status~g~:Follow'
            end
            local formattedX = string.format("%.2f", zccoords.x)
            local formattedY = string.format("%.2f", zccoords.y)
            local formattedZ = string.format("%.2f", zccoords.z)
            local Textcoord = "~g~X:~w~ " .. formattedX .. "~g~ Y:~w~ " ..
                                  formattedY .. " ~g~Z:~w~ " .. formattedZ

            local Distance = 'Distance :' .. 1.0 + large
            local Manual =
                '~w~กด~y~ ลูกศร: ~w~เพื่อปรับขนาด'
            local Manual2 =
                '~w~กด~y~ ENTER: ~w~เพื่อล๊อกพิกัด'
            DrawText2D(0.95, 1.05, 1.0, 1.0, 1.0, Textcoord)
            DrawText2D(0.90, 1.12, 0.5, 1.0, 1.0, Distance)
            DrawText2D(1.00, 1.12, 0.5, 1.0, 1.0, Status)
            DrawText2D(0.90, 1.10, 0.4, 1.0, 1.0, Manual)
            DrawText2D(1.00, 1.10, 0.4, 1.0, 1.0, Manual2)

            DrawMarker(1, zccoords.x, zccoords.y, zccoords.z - 1, 0, 0, 0, 0, 0,
                       0, 1.0 + large * 2, 1.0 + large * 2, 1.0 + up, 255, 0, 0,
                       100, 0, 0, 0, 0)

            Wait(0)
        end
    end)
    Citizen.CreateThread(function()
        while checkzone do
            if IsControlPressed(0, 172) then -- Up
                large = large + 0.5
            elseif IsControlPressed(0, 173) then -- Down
                large = large - 0.5
                if large < 0 then large = 0 end
            elseif IsControlPressed(0, 174) then -- Left
                up = up + 1
            elseif IsControlPressed(0, 175) then -- Right
                up = up - 1
                if up < 0 then up = 0 end
            end
            Wait(100)
        end
    end)
end)

DrawText2D = function(x, y, scale, width, height, text)
    local fontId = RegisterFontId "font4thai"
    SetTextFont(fontId)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width / 2.3, y - height / 1 + 0.005)
end
