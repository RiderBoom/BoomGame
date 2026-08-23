ESX = exports["es_extended"]:getSharedObject()


RegisterServerEvent('esx_skin:save')
AddEventHandler('esx_skin:save', function(skin)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('UPDATE users SET `skin` = @skin WHERE identifier = @identifier',
	{
		['@skin']       = json.encode(skin),
		['@identifier'] = xPlayer.identifier
	})
end)

RegisterServerEvent('esx_skin:responseSaveSkin')
AddEventHandler('esx_skin:responseSaveSkin', function(skin)

	TriggerEvent('es:getPlayerFromId', source, function(user)
		TriggerEvent('es:canGroupTarget', user.getGroup(), "admin", function(available)
			if available then
				local file = io.open('resources/[esx]/esx_skin/skins.txt', "a")

				file:write(json.encode(skin) .. "\n\n")
				file:flush()
				file:close()
			else
				print(('esx_skin: %s attempted saving skin to file'):format(user.getIdentifier()))
			end
		end)
	end)

end)

ESX.RegisterServerCallback('esx_skin:getPlayerSkin', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT skin FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(users)
		local user = users[1]
		local skin = nil

		local jobSkin = {
			skin_male   = xPlayer.job.skin_male,
			skin_female = xPlayer.job.skin_female
		}

		if user.skin ~= nil then
			skin = json.decode(user.skin)
		end

		cb(skin, jobSkin)
	end)
end)

ESX.RegisterCommand('skin', 'admin', function(xPlayer, args, showError)
	xPlayer.triggerEvent('esx_skin:openSaveableMenu')
end, false, {help = _U('skin')})


ESX.RegisterCommand('giveskin', 'admin', function(xPlayer, args, showError)
    args.playerId.triggerEvent('esx_skin:openSaveableMenu')
end, true, {help = 'ให้ผู้เล่นแต่งตัวใหม่', validate = true, arguments = {
    {name = 'playerId', help = 'ให้ผู้เล่นแต่งตัวใหม่', type = 'player'},
}})

ESX.RegisterUsableItem('reskin_card', function(source)
	local xPlayer  = ESX.GetPlayerFromId(source)
	xPlayer.triggerEvent('esx_skin:openSaveableMenu')
	xPlayer.removeInventoryItem('reskin_card', 1)
end)

