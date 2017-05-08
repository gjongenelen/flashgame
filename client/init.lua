dofile("wifi.lua")
dofile("clock.lua")
dofile("game.lua")
dofile("sensor.lua")
dofile("leds.lua")
dofile("client.lua")

Clock.start()

Led.init()

Wifi.connectClient(function(connection, message)

    print("data", message)

    local data = cjson.decode(message)                 -- Decodeer JSON
    --  print json data -- for k,v in pairs(data) do print(k,v) end

    if (data['action'] == "config") then              -- Wanneer configuratie data wordt meegestuurd, lees deze dan uit
        Game.config = data['config']
    end
    if (data['action'] == "startBlinking") then       -- Wanneer FLashLED aan moet , lees dit dan uit
        Game.alarmLocal(function()
            local ok, json = pcall(cjson.encode, {action="stoppedBlinking"})
            if ok then
                pcall(function()
                    connection:send(json .. " ")
                end)
            end
        end)
    end
    if (data['action'] == "ping") then       -- Wanneer FLashLED aan moet , lees dit dan uit
        local ok, json = pcall(cjson.encode, {action="pong"})
        if ok then
            pcall(function()
                connection:send(json .. " ")
            end)
        end
    end

end)

