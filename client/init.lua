dofile("wifi.lua")
dofile("clock.lua")
dofile("game.lua")
dofile("sensor.lua")
dofile("leds.lua")
dofile("client.lua")

Clock.start()

Led.init()

Wifi.connect(function()
    Client.connect(function(connection, message)
        local data = cjson.decode(message)

        if (data['action'] == "config") then
            Game.config = data['config']
        end
        if (data['action'] == "startBlinking") then
            Game.alarmLocal(function()
                local _, json = pcall(cjson.encode, {action="stoppedBlinking"})
                pcall(function()
                    connection:send(json .. " ")
                end)
            end)
        end
        if (data['action'] == "stopBlinking") then
            Led.off()
        end
        if (data['action'] == "doneAlarm") then
            Led.alarmDone()
        end
        if (data['action'] == "ping") then
            local _, json = pcall(cjson.encode, {action="pong"})
            pcall(function()
                connection:send(json .. " ")
            end)
        end
    end)
end)

