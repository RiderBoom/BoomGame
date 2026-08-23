ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx_4kings:interact')
AddEventHandler('esx_4kings:interact', function(factionName, locType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local faction = Config.Factions[factionName]
    if not faction then return end

    if xPlayer.job.name ~= factionName and xPlayer.job.name ~= faction.offJob then
        TriggerClientEvent('esx:showNotification', src, 'คุณไม่ใช่สมาชิกของสถาบันนี้')
        return
    end

    if locType == 'Duty' then
        if xPlayer.job.name == factionName then
            xPlayer.setJob(faction.offJob, xPlayer.job.grade)
            TriggerClientEvent('esx:showNotification', src, 'คุณได้ออกเวรแล้ว (' .. faction.label .. ')')
        else
            xPlayer.setJob(factionName, xPlayer.job.grade)
            TriggerClientEvent('esx:showNotification', src, 'คุณได้เข้าเวรแล้ว (' .. faction.label .. ')')
        end
    elseif locType == 'Armory' then
        TriggerClientEvent('esx:showNotification', src, 'เปิดคลังอุปกรณ์สถาบัน ' .. faction.label)
    elseif locType == 'Boss' then
        if xPlayer.job.grade_name == 'boss' then
            TriggerClientEvent('esx:showNotification', src, 'เปิดเมนูหัวหน้าสถาบัน ' .. faction.label)
        else
            TriggerClientEvent('esx:showNotification', src, 'คุณไม่มีสิทธิ์ใช้งานเมนูหัวหน้า')
        end
    end
end)
