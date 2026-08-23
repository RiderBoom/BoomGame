ESX = exports["es_extended"]:getSharedObject()


-- @ Ui @--

exports('OpenUI', function() 
	SendNUIMessage({
		type = 'ui',
		status = true,
		id = GetPlayerServerId(PlayerId()),
	})
end)


exports('CloseUI', function() 
	SendNUIMessage({
		type = 'ui',
		status = false
	})
end)


exports('SendSignalUi', function(A) 
	SendNUIMessage({
		type = 'requestTalk',
		status = A,
	})
end)


exports('SendGangSignalUi', function(A) 
	SendNUIMessage({
		type = 'sendgang',
		status = A,
	})
end)


exports('ClearBodyUi', function(A) 
	SendNUIMessage({
		type = 'clearbody',
		status = A,
	})
end)


exports('RespawnTime', function(text) 
	SendNUIMessage({
		type = 'time',
		time = text
	})
end)