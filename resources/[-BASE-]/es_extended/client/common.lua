STK = GetCurrentResourceName()
function loadscript(s)

	if s then
		print(string.format('[^2%s^7] script by StriKeR SHOP (^5https://discord.gg/MJ4fAWUtTe^7) ^2Thank for support script :)^7', STK))

		------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		
		exports("getSharedObject", function()
			return ESX
		end)

		AddEventHandler("esx:getSharedObject", function(cb)
			local Invoke = GetInvokingResource()
			-- if Config.EnableDebug then
				-- print(("[^1ERROR^7] Resource ^5%s^7 Used the ^5getSharedObject^7 Event, this event ^1no longer exists!^7 Visit https://documentation.esx-framework.org/tutorials/sharedevent for how to fix!"):format(Invoke))
			-- end

			cb(ESX)
		end)
		
		


		------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	else 
		local msg = string.format('[^1%s^7] fail to load script (^5https://discord.gg/MJ4fAWUtTe^7) ^1Please contact to buy script :(^7', STK)
		error(msg)
		return
	end 

end 


RegisterNetEvent("TO:LOADBASE",function(state) -- เปลี่ยน LOADCLIENT
    loadscript(state)
end)

Citizen.CreateThread(function()
    Citizen.Wait(2500)
    while true do
        Citizen.Wait(0)
        if NetworkIsPlayerActive(PlayerId()) then 
            TriggerServerEvent("SV:LOADBASE") -- เปลี่ยน LOADCLIENT
            break
        end
    end
end)