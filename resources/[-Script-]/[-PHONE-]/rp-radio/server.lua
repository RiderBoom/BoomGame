ESX = exports["es_extended"]:getSharedObject()


-- ชื่อไอเทมวิทยุสื่อสาร 1 สำหรับหน่วยงาน
ESX.RegisterUsableItem('radio', function(source)
    local _source = source
	local xPlayer  = ESX.GetPlayerFromId(_source)

	if xPlayer.job.name == 'police' or
	xPlayer.job.name == 'ambulance' or
	xPlayer.job.name == 'mechanic' or
	xPlayer.job.name == 'council' or
	xPlayer.job.name == 'admin' then
	
		local xItem = xPlayer.getInventoryItem('radio')
		
		if xItem.count >= 1 then
			TriggerClientEvent("Radio.Set", source, true)
			TriggerClientEvent("Radio.Toggle", source)
		end
	else
		TriggerClientEvent("pNotify:SendNotification", source, {
			text = '<center><strong class="red-text">คุณไม่ใช่หน่วยงาน!!</strong><center>',
			type = "error",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
	end
	
end)


-- ชื่อไอเทมวิทยุสื่อสาร 2 สำหรับทุกคน
ESX.RegisterUsableItem('radio_p', function(source)
    local _source = source
	local xPlayer  = ESX.GetPlayerFromId(_source)

	
	local xItem = xPlayer.getInventoryItem('radio_p')
		
	if xItem.count >= 1 then
		TriggerClientEvent("Radio.Set", source, true)
		TriggerClientEvent("Radio.Toggle", source)
	end
	
end)
