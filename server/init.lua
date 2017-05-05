dofile("wifi.lua")
dofile("clock.lua")
dofile("game.lua")
dofile("sensor.lua")
dofile("leds.lua")
dofile("server.lua")

Clock.start()

Led.init()




Server.start(function(connection, encodedData)

    local port, ip = connection:getpeer()
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



--
--readyToSend = false
--readyToPlay = false
--local FlashOn = false
--local Groen = 255
--local Rood = 0
--local Blauw = 0
--
--
--function tablelength(T)
--    local count = 0
--    for _ in pairs(T) do count = count + 1 end
--    return count
--end
--
--previous = nil
--function sendToRandomConnection()
--    local i = 1
--    local random = math.random(0, tablelength(connections))
--    if previous == random then
--        print("repeated random", previous, random)
--        sendToRandomConnection()
--    else
--        previous = random
--        if random == 0 then
--
--            Sensor.waitForInteraction(function()
--                FlashOn = false
--                readyToSend = true
--            end)
--
--            print("self")
--        else
--            for mac, conn in pairs(connections) do
--                if i == random then
--                    sendToMac(mac, { action = "test" })
--                end
--                i = i + 1
--            end
--        end
--        readyToSend = false
--    end
--end
--
--
--
--
--
--
--
--local avgLight = 0 --  Analog LDR value
--
--local loopstate = 1
--tmr.alarm(3, 50, 1, function()
--    if (FlashOn) then
--        loopstate = loopstate + 1
--        if (loopstate == 7) then
--            loopstate = 1
--        end
--        buffer = ws2812.newBuffer(6, 3)
--        buffer:set(1, string.char(Groen, Rood, Blauw))
--        buffer:set(2, string.char(Groen, Rood, Blauw))
--        buffer:set(3, string.char(Groen, Rood, Blauw))
--        buffer:set(4, string.char(Groen, Rood, Blauw))
--        buffer:set(5, string.char(Groen, Rood, Blauw))
--        buffer:set(6, string.char(Groen, Rood, Blauw))
--        buffer:set(loopstate, string.char(50, 0, 0))
--        ws2812.write(buffer)
--    else
--        buffer = ws2812.newBuffer(6, 3)
--        buffer:set(1, string.char(0, 0, 0))
--        buffer:set(2, string.char(0, 0, 0))
--        buffer:set(3, string.char(0, 0, 0))
--        buffer:set(4, string.char(0, 0, 0))
--        buffer:set(5, string.char(0, 0, 0))
--        buffer:set(6, string.char(0, 0, 0))
--        ws2812.write(buffer)
--    end
--end)
--
---- id -- Interval -- ???
--tmr.alarm(4, 50, 1, function()
--    if (readyToSend and readyToPlay) then
--        sendToRandomConnection()
--    end
--end)
--
--
--tmr.alarm(5, 500, 1, function()
--    avgLight = adc.read(0)
--end)
--
--
