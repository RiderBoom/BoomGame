ESX = exports["es_extended"]:getSharedObject()

------------------------------------------------------------------------
	
	--- CURFEW ---

-------------------------------------------------------------------------
RegisterServerEvent('police:blips1')
AddEventHandler('police:blips1', function(dropCoords)
--	print(dropCoords.x)
	TriggerClientEvent("police:sendBlipscer1", -1, dropCoords.x, dropCoords.y, dropCoords.z)
end)

RegisterServerEvent('police:blips2')
AddEventHandler('police:blips2', function(dropCoords)
--	print(dropCoords.x)
	TriggerClientEvent("police:sendBlipscer2", -1, dropCoords.x, dropCoords.y, dropCoords.z)
end)

RegisterServerEvent('police:blips3')
AddEventHandler('police:blips3', function(dropCoords)
--	print(dropCoords.x)
	TriggerClientEvent("police:sendBlipscer3", -1, dropCoords.x, dropCoords.y, dropCoords.z)
end)


local curfew1 = false
local curfew2 = false
local curfew3 = false


-------------------------------------------------------------------------
RegisterServerEvent('esx_policejob:ensurecurfew1')
AddEventHandler('esx_policejob:ensurecurfew1', function(dropCoords)
	local src = source
	if not curfew1 then
		curfew1 = true
		TriggerClientEvent("police:crateDrop1", src)

		TriggerClientEvent('chat:addMessage', -1, {
			template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(4, 0, 255, 0.5); border-radius: 20px;"><i class="fas fa-bullhorn"></i> ตำรวจ : ประกาศพื้นที่เคอร์ฟิว ในเขตสีแดง ขอให้ผู้ที่ไม่มีส่วนเกี่ยวข้องออกจากพื้นที่ด้วยครับ!!</div>',
			args = { fal, msg }
		})
	else
		curfew1 = false
		TriggerClientEvent("police:endcurfew1", -1)
			
		TriggerClientEvent('chat:addMessage', -1, {
			template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(4, 0, 255, 0.5); border-radius: 20px;"><i class="fas fa-bullhorn"></i> ตำรวจ : ประกาศพื้นที่เคอร์ฟิวได้ถูกยกเลิกแล้ว!!</div>',
			args = { fal, msg }
		})
	end
end)


----------------------------------------------------------------------------
RegisterServerEvent('esx_policejob:ensurecurfew2')
AddEventHandler('esx_policejob:ensurecurfew2', function(dropCoords)
	local src = source
	if not curfew2 then
		curfew2 = true
		TriggerClientEvent("police:crateDrop2", src)
		TriggerClientEvent('chat:addMessage', -1, {
			template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(4, 0, 255, 0.5); border-radius: 20px;"><i class="fas fa-bullhorn"></i> ตำรวจ : ประกาศพื้นที่เคอร์ฟิว ในเขตสีแดง ขอให้ผู้ที่ไม่มีส่วนเกี่ยวข้องออกจากพื้นที่ด้วยครับ!!</div>',
			args = { fal, msg }
		})
	else
		curfew2 = false
		TriggerClientEvent("police:endcurfew2", -1)
		TriggerClientEvent('chat:addMessage', -1, {
			template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(4, 0, 255, 0.5); border-radius: 20px;"><i class="fas fa-bullhorn"></i> ตำรวจ : ประกาศพื้นที่เคอร์ฟิวได้ถูกยกเลิกแล้ว!!</div>',
			args = { fal, msg }
		})
	end
end)

----------------------------------------------------------------------------
RegisterServerEvent('esx_policejob:ensurecurfew3')
AddEventHandler('esx_policejob:ensurecurfew3', function(dropCoords)
	local src = source
	if not curfew3 then
		curfew3 = true
		TriggerClientEvent("police:crateDrop3", src)
		TriggerClientEvent('chat:addMessage', -1, {
			template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(4, 0, 255, 0.5); border-radius: 20px;"><i class="fas fa-bullhorn"></i> ตำรวจ : ประกาศพื้นที่เคอร์ฟิว ในเขตสีแดง ขอให้ผู้ที่ไม่มีส่วนเกี่ยวข้องออกจากพื้นที่ด้วยครับ!!</div>',
			args = { fal, msg }
		})
	else
		curfew3 = false
		TriggerClientEvent("police:endcurfew3", -1)
		TriggerClientEvent('chat:addMessage', -1, {
			template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(4, 0, 255, 0.5); border-radius: 20px;"><i class="fas fa-bullhorn"></i> ตำรวจ : ประกาศพื้นที่เคอร์ฟิวได้ถูกยกเลิกแล้ว!!</div>',
			args = { fal, msg }
		})
	end
end)
