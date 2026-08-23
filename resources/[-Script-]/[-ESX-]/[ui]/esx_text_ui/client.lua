function sendNUIMessageText(msg)
    if msg then 
        msg = msg:gsub("~r~", "<span style=color:red;>")
        msg = msg:gsub("~b~", "<span style='color:rgb(0, 213, 255);'>")
        msg = msg:gsub("~g~", "<span style='color:rgb(0, 255, 68);'>")
        msg = msg:gsub("~y~", "<span style=color:yellow;>")
        msg = msg:gsub("~p~", "<span style='color:rgb(220, 0, 255);'>")
        msg = msg:gsub("~f~", "<span style=color:grey;>")
        msg = msg:gsub("~m~", "<span style=color:darkgrey;>")
        msg = msg:gsub("~u~", "<span style=color:black;>")
        msg = msg:gsub("~o~", "<span style=color:gold;>")
        msg = msg:gsub("~s~", "</span>")
        msg = msg:gsub("~w~", "</span>")
        msg = msg:gsub("~b~", "<b>")
        msg = msg:gsub("~n~", "<br>")
        msg = msg:gsub("\n", "<br>")
        msg = msg:gsub("~input~", "<span class = 'INPUT_PICKUP'>")
        msg = msg:gsub("~INPUT_PICKUP~", "<span class = 'INPUT_PICKUP'>E</span>")
        msg = msg:gsub("~INPUT_CONTEXT~", "<span class = 'INPUT_PICKUP'>E</span>")
        msg = msg:gsub("~INPUT_DETONATE~", "<span class = 'INPUT_PICKUP'>G</span>")
        msg = msg:gsub("~INPUT_VEH_EXIT~", "<span class = 'INPUT_PICKUP'>F</span>")
        msg = msg:gsub("~INPUT_RELOAD~", "<span class = 'INPUT_PICKUP'>R</span>")
        msg = msg:gsub("~INPUT_VEH_FLY_ROLL_LEFT_ONLY~", "<span class = 'INPUT_PICKUP'>4</span>")
        msg = msg:gsub("~INPUT_VEH_FLY_ROLL_RIGHT_ONLY~", "<span class = 'INPUT_PICKUP'>6</span>")
        msg = "<span style=color:currentColor>" .. msg .. "</span>"
    end

    SendNUIMessage({ 
        message = msg;
    })
end

exports("Help", sendNUIMessageText)
