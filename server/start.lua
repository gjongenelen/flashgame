dofile("wifi.lc")
dofile("clock.lc")
dofile("game.lc")
dofile("sensor.lc")
dofile("leds.lc")
dofile("server.lc")
dofile("config.lc")

Config.startListening()
Clock.start()

Led.init()

Wifi.startServer()

Server.start(function(connection, encodedData)

    local _, ip = connection:getpeer()
    print("in:", Server.getMacByIp(ip), encodedData)
    local data = cjson.decode(encodedData)

    if (data['action'] == "pong") then
        Server.clients[Server.getMacByIp(ip)] = Clock.seconds
    end

    if (data['action'] == "stoppedBlinking") then
        Game.nextStep()
    end

end)

