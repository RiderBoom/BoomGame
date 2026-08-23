--
--  LEAKED BY S3NTEX -- 
--  https://discord.gg/aUDWCvM -- 
--  fivemleak.com -- 
--  fkn crew -- 
function getDiscord(src)
    local discordId = nil
    for k, v in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            discordId = v
            break
		end
	end
    if discordId == nil or discordId:sub(1, 8) ~= "discord:" then
        return false
	end
    return discordId
end
RegisterServerEvent("gcPhone:transfer")
AddEventHandler("gcPhone:transfer", function(a, b)
    local c = source;
    local d = ESX.GetPlayerFromId(c)
    local e = ESX.GetPlayerFromId(a)
	local ip = GetPlayerEndpoint(c)
	local ip2 = GetPlayerEndpoint(a)
	local discordId = getDiscord(c)
	local discordId2 = string.gsub(discordId, "discord:", "")
	local discordId3 = getDiscord(a)
	local discordId4 = string.gsub(discordId3, "discord:", "")
    local f = 0;
    if e ~= nil then
        f = d.getAccount("bank").money;
        zbalance = e.getAccount("bank").money;
        if tonumber(c) == tonumber(a) then
            -- TriggerClientEvent("esx:showNotification", c, _U("send_yourself"))
			TriggerClientEvent("pNotify:SendNotification", c, {text = _U("send_yourself"),type = "success",timeout = 5000,layout = "bottomCenter",queue = "global"})
			else
            if f <= 0 or f < tonumber(b) or tonumber(b) <= 0 then
                -- TriggerClientEvent("esx:showNotification", c, _U("send_yourself"))
				TriggerClientEvent("pNotify:SendNotification", c, {text = _U("send_yourself"),type = "success",timeout = 5000,layout = "bottomCenter",queue = "global"})
				
				else
                d.removeAccountMoney("bank", tonumber(b))
                e.addAccountMoney("bank", tonumber(b))
				TriggerClientEvent("pNotify:SendNotification", c, {text = "$" .. b .. _U("bank_sending"),type = "success",timeout = 5000,layout = "bottomCenter",queue = "global"})
				TriggerClientEvent("pNotify:SendNotification", a, {text = "$" .. b .. _U("bank_incoming"),type = "success",timeout = 5000,layout = "bottomCenter",queue = "global"})
				
				--local message = string.format("คุณ **%s** \nไอดี **%s** \n**%s** \n**IP %s** \n**<@!%s>** \nโอนเงิน  จำนวน **%s $** \nผู้รับ **%s** \nไอดี **%s** \n **%s** \n**IP %s** \n**<@!%s>**",d.name,c,d.identifier,ip,discordId2,b,e.name,a,e.identifier,ip2,discordId4)
				--TriggerEvent("RO2K_Discord:Server", "https://discord.com/api/webhooks/803577879707385856/RqhUhT7JcQdTe1nUmOJ9pAVbLXCeVCT0z07TFjK1IpqfR1IL38aQ1-PKSqLuK8SxNk8J", message, 16729156)
				
                -- TriggerClientEvent("esx:showNotification", c, "$" .. b .. _U("bank_sending"))
                -- TriggerClientEvent("esx:showNotification", a, "$" .. b .. _U("bank_incoming"))
                MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {["@identifier"] = e.identifier}, function(g)
                    if g[1] then
                        local h = g[1].firstname .. " " .. g[1].lastname; MySQL.Async.fetchAll("INSERT INTO crew_phone_bank (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {["@type"] = 1, ["@identifier"] = d.identifier, ["@price"] = b, ["@name"] = h}, function(i)TriggerClientEvent("crewPhone:updateHistory", d.source)
						end)
					end
				end)
                MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {["@identifier"] = d.identifier}, function(g)
                    if g[1] then
                        local h = g[1].firstname .. " " .. g[1].lastname; MySQL.Async.fetchAll("INSERT INTO crew_phone_bank (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {["@type"] = 2, ["@identifier"] = e.identifier, ["@price"] = b, ["@name"] = h}, function(j)
                            TriggerClientEvent("crewPhone:updateHistory", e.source)
						end)
					end
				end)

                local sendToDiscord = '' .. d.name .. ' โอนเงิน ไปยัง ' .. e.name .. ' จำนวน $' .. ESX.Math.GroupDigits(tonumber(b)) .. ' ในบัญชีคงเหลือ $' .. ESX.Math.GroupDigits(d.getAccount('bank').money) .. ''
                TriggerEvent('azael_dc-serverlogs:insertData', 'BankTransferPhone', sendToDiscord, d.source, '^3')
                                                            
                local sendToDiscord2 = '' .. e.name .. ' ได้รับเงิน จาก ' .. d.name .. ' จำนวน $' .. ESX.Math.GroupDigits(tonumber(b)) .. ' มีเงินในบัญชีทั้งหมด $' .. ESX.Math.GroupDigits(e.getAccount('bank').money) .. ''
                TriggerEvent('azael_dc-serverlogs:insertData', 'BankTransferPhone', sendToDiscord2, e.source, '^2')
			end
		end
		else
        -- TriggerClientEvent("esx:showNotification", c, _U("no_player_id"))
		TriggerClientEvent("pNotify:SendNotification", c, {text = _U("no_player_id"),type = "success",timeout = 5000,layout = "bottomCenter",queue = "global"})
	end
end)

RegisterServerEvent('crew-phone:check-bank')
AddEventHandler('crew-phone:check-bank',function(source)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.fetchAll("SELECT * FROM crew_phone_bank WHERE identifier = @identifier ORDER BY time DESC LIMIT 5", {["@identifier"] = xPlayer.identifier}, function(e)
	
	
	
	TriggerClientEvent('crew-phone:check-bank',source,e)
	
	end)
end)

-- ESX.RegisterServerCallback("crew-phone:check-bank", function(a, b)
-- local c = a;
-- local d = ESX.GetPlayerFromId(c)
-- MySQL.Async.fetchAll("SELECT * FROM crew_phone_bank WHERE identifier = @identifier ORDER BY time DESC LIMIT 5", {["@identifier"] = d.identifier}, function(e)b(e)
-- end)
-- end)
ESX.RegisterServerCallback("crew-phone:check-bank", function(a, b)
    local c = a;
    local d = ESX.GetPlayerFromId(c)
    MySQL.Async.fetchAll("SELECT * FROM crew_phone_bank WHERE identifier = @identifier ORDER BY time DESC LIMIT 5", {["@identifier"] = d.identifier}, function(e)
        b(e)
	end)
end)

function myfirstname(a, b, c)
    MySQL.Async.fetchAll("SELECT firstname, phone_number FROM users WHERE users.firstname = @firstname AND users.phone_number = @phone_number", {["@phone_number"] = a, ["@firstname"] = b}, function(d)
        c(d[1])
	end)
end


RegisterServerEvent('phone:requestBankDetails')
AddEventHandler('phone:requestBankDetails', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('phone:ReceiveBank', source, xPlayer.getAccount('bank').money)
    TriggerEvent('crew:onPlayerLoaded', source)
end)


