dofile("wifi.lua")
dofile("clock.lua")
dofile("game.lua")
dofile("sensor.lua")
dofile("leds.lua")
dofile("server.lua")

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

Game.startAfter(5)
