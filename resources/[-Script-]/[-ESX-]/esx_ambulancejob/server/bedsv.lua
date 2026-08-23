if Config.BedSystem then
	ESX = exports["es_extended"]:getSharedObject()


	RegisterServerEvent('esx_ambulancejob:CheckMoneyBed')
	AddEventHandler('esx_ambulancejob:CheckMoneyBed', function()
		local xPlayer = ESX.GetPlayerFromId(source)
		local money = xPlayer.getMoney()
		if money < Config.PayforbedNoEms then
			xPlayer.triggerEvent('pNotify:SendNotification', {
				text = "คุณมีเงินไม่พอ ต้องใช้เงิน "..Config.PayforbedNoEms.." $ ในการนอนเตียง",
				type = "error",
				queue = "center",
				timeout = 5000,
				layout = "bottomCenter"
			})
		else
			xPlayer.removeMoney(Config.PayforbedNoEms)
			xPlayer.triggerEvent('esx_ambulancejob:Bed1')
		end
	end)

	RegisterServerEvent('esx_ambulancejob:setOnBed')
	AddEventHandler('esx_ambulancejob:setOnBed', function(target, coord)
		local xPlayer = ESX.GetPlayerFromId(target)
		xPlayer.triggerEvent('esx_ambulancejob:Bed1')
		xPlayer.triggerEvent('esx_ambulancejob:setcoordoffBed', coord)
	end)
end