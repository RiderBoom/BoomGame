color = {}
color[1] = { r = 147, g = 211, b = 89, a = 200}
color[2] = { r = 108, g = 203, b = 234, a = 200 }
color[3] = {r = 234, g = 108, b = 144, a = 200 }
alpha = 300
delay = 0
delayTime = 1500
seccess = nil
AddEventHandler('pma-voice:setTalkingMode', function(mode)
    seccess = true
    Citizen.Wait(0)
    VoiceDistance(mode)
end)
function VoiceDistance(mode)
    local distance = Cfg.voiceModes[mode][1]
    local r,g,b,a = color[mode].r, color[mode].g, color[mode].b, alpha
    seccess = false
    delay = delayTime
    while not seccess do
        DrawMarker(1, GetEntityCoords(PlayerPedId())+vector3(0,0,0), 0.0,0.0,0.0, 0.0,0.0,0.0, distance,distance,0.125, r,g,b,math.floor((delay*a)/delayTime), false,true,2,nil,nil,false)
        DrawMarker(1, GetEntityCoords(PlayerPedId())+vector3(0,0,0.025), 0.0,0.0,0.0, 0.0,0.0,0.0, distance,distance,-0.125, r,g,b,math.floor((delay*a)/delayTime), false,true,2,nil,nil,false)
        Citizen.Wait(0)
        delay = delay-9
        if delay <= 0 then
          seccess = true
        end
    end
end
