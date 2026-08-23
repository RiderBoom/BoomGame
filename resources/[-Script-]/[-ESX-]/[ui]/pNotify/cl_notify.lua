--[[
Complete List of Options:
        type
        layout
        theme
        text
        timeout
        progressBar
        closeWith
        animation = {
            open
            close
        }
        sounds = {
            volume
            conditions
            sources
        }
        docTitle = {
            conditions
        }
        modal
        id
        force
        queue
        killer
        container
        buttons

More details below or visit the creators website http://ned.im/noty/options.html

Layouts:
    top
    topLeft
    topCenter
    topRight
    center
    centerLeft
    centerRight
    bottom
    bottomLeft
    bottomCenter
    bottomRight

Types:
    alert
    success
    error
    warning
    info

Themes: -- You can create more themes inside html/themes.css, use the gta theme as a template.
    gta
    mint
    relax
    metroui

Animations:
    open:
        noty_effects_open
        gta_effects_open
        gta_effects_open_left
        gta_effects_fade_in
    close:
        noty_effects_close
        gta_effects_close
        gta_effects_close_left
        gta_effects_fade_out

closeWith: -- array, You will probably never use this.
    click
    button

sounds:
    volume: 0.0 - 1.0
    conditions: -- array
        docVisible
        docHidden
    sources: -- array of sound files

modal:
    true
    false

force:
    true
    false

queue: -- default is global, you can make it what ever you want though.
    global

killer: -- will close all visible notifications and show only this one
    true
    false

visit the creators website http://ned.im/noty/options.html for more information
--]]

function SetQueueMax(queue, max)
    local tmp = {
        queue = tostring(queue),
        max = tonumber(max)
    }

    SendNUIMessage({maxNotifications = tmp})
end

function SendNotification(options)
    options.animation = options.animation or {}
    options.sounds = options.sounds or {}
    options.docTitle = options.docTitle or {}

    local options = {
        type = options.type or "alert",
        layout = options.layout or "bottomCenter",
        theme = "mint",
        text = "<center>"..options.text.."</center>" or "Empty Notification",
        timeout = options.timeout or 5000,
        progressBar = options.progressBar ~= false and true or false,
        closeWith = options.closeWith or {},
        animation = {
            open = options.animation.open or "gta_effects_open",
            close = options.animation.close or "gta_effects_close"
        },
        sounds = {
            volume = options.sounds.volume or 1,
            conditions = options.sounds.conditions or {},
            sources = options.sounds.sources or {}
        },
        docTitle = {
            conditions = options.docTitle.conditions or {}
        },
        modal = options.modal or false,
        id = options.id or false,
        force = options.force or false,
        queue = options.queue or "global",
        killer = options.killer or false,
        container = options.container or false,
        buttons = options.button or false
    }
	if options.type == "error" then
		PlaySound(-1,"CHECKPOINT_MISSED","HUD_MINI_GAME_SOUNDSET",0,0,1)
	elseif options.type == "success" then
		PlaySound(-1,"Click_Fail","WEB_NAVIGATION_SOUNDS_PHONE",0,0,1)
	elseif options.type == "alert" then
		PlaySound(-1,"Click_Fail","WEB_NAVIGATION_SOUNDS_PHONE",0,0,1)
	elseif options.type == "warning" then
		PlaySound(-1,"Out_Of_Bounds_Timer","DLC_HEISTS_GENERAL_FRONTEND_SOUNDS",0,0,1)
	end
    SendNUIMessage({options = options})
end

RegisterNetEvent("pNotify:SendNotification")
AddEventHandler("pNotify:SendNotification", function(options)
    SendNotification(options)
end)

RegisterNetEvent("pNotify:SetQueueMax")
AddEventHandler("pNotify:SetQueueMax", function(queue, max)
    SetQueueMax(queue, max)
end)


-- RegisterCommand("n1", function()
    -- TriggerEvent("pNotify:SendNotification", {
        -- text = '<strong class="red-text">ทดสอบแจ้งเตือน</span>',
        -- type = "success",
        -- timeout = 3000,
        -- layout = "bottomCenter",
        -- queue = "global"
    -- })
-- end)

-- RegisterCommand("n2", function()
    -- TriggerEvent("pNotify:SendNotification", {
        -- text = '<strong class="red-text">ทดสอบแจ้งเตือน</span>',
        -- type = "error",
        -- timeout = 3000,
        -- layout = "bottomCenter",
        -- queue = "global"
    -- })
-- end)

-- RegisterCommand("n3", function()
    -- TriggerEvent("pNotify:SendNotification", {
        -- text = '<strong class="red-text">ทดสอบแจ้งเตือน</span>',
        -- type = "alert",
        -- timeout = 3000,
        -- layout = "bottomCenter",
        -- queue = "global"
    -- })
-- end)

-- RegisterCommand("n4", function()
    -- TriggerEvent("pNotify:SendNotification", {
        -- text = '<strong class="red-text">ทดสอบแจ้งเตือน</span>',
        -- type = "warning",
        -- timeout = 3000,
        -- layout = "bottomCenter",
        -- queue = "global"
    -- })
-- end)