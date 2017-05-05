wifi.sta.disconnect()
wifi.setmode(wifi.STATION) 
wifi.sta.config("FlashGame","12345678")
wifi.sta.connect() 
print("Looking for a connection")

ws2812.init()   -- GRB
buffer = ws2812.newBuffer(4, 3)
       
local FlashOn = false
local Groen = 0
local Rood = 0
local Blauw = 0

local avgLight = 0    --  Analog LDR value          

function handleMessage(conn, receivedData) 
    print("data", receivedData)
   
    data = cjson.decode(receivedData)                 -- Decodeer JSON
                                                            --  print json data -- for k,v in pairs(data) do print(k,v) end
    if (data['action'] == "config") then              -- Wanneer configuratie data wordt meegestuurd, lees deze dan uit
        Groen = data['g'];
        Rood = data['r'];
        Blauw = data['b'];
    end
    if (data['action'] == "startBlinking") then       -- Wanneer FLashLED aan moet , lees dit dan uit
        FlashOn = true
        avgLight = adc.read(0)
    end
    if (data['action'] == "test") then       -- Wanneer FLashLED aan moet , lees dit dan uit
        ok, json = pcall(cjson.encode, {action="testBack"})
        if ok then
            pcall(function() 
                conn:send(json .. " ")
            end)
        end
        FlashOn = true
        avgLight = adc.read(0)
    end
    if (data['action'] == "ping") then       -- Wanneer FLashLED aan moet , lees dit dan uit
        ok, json = pcall(cjson.encode, {action="pong"})
        if ok then
            pcall(function() 
                conn:send(json .. " ")
            end)
        end
    end
end

tmr.alarm(0, 1000, 1, function()                            -- Verbinding opzetten 
    if(wifi.sta.getip()~=nil) then                        -- Wanneer er een IP is toegewezen
        tmr.stop(0)                                       -- Stop timer voor connectie                     
        print("Client IP Address:", wifi.sta.getip())
        cl=net.createConnection(net.TCP, 0)               -- Verbindt met server IP 
        cl:connect(80,"192.168.4.1")
        cl:on("receive", function(conn, receivedData)     -- Ontvang data via conn functie met variabele receivedData (Json format)
            print(receivedData)
            for x in string.gmatch(receivedData, "%S+") do
                handleMessage(conn, x)
            end
        end)
        
    else          
        buffer:set(1, string.char(100, 100, 0))             -- Zet lampjes aan in gele kleur tijdens verbinding zoeken
        buffer:set(2, string.char(100, 100, 0))
        buffer:set(3, string.char(100, 100, 0))
        buffer:set(4, string.char(100, 100, 0))
        buffer:set(5, string.char(100, 100, 0))
        buffer:set(6, string.char(100, 100, 0))
        ws2812.write(buffer)
        print("Connecting...")
    end
end)

-- id -- Interval -- ???
tmr.alarm(1, 1, 1, function ()
    if (FlashOn) then
        if (math.abs(adc.read(0) - avgLight)>50) then
            FlashOn = false
            ok, json = pcall(cjson.encode, {action="stoppedBlinking"})
            if ok then
                pcall(function() 
                    cl:send(json .. " ")
                end)
            end
        end
    end
end)

local loopstate = 1
tmr.alarm(2, 50, 1, function ()
    if (FlashOn) then   
        loopstate = loopstate + 1
        if (loopstate == 7) then
            loopstate = 1
        end
        buffer = ws2812.newBuffer(6, 3)
        buffer:set(1, string.char(Groen, Rood, Blauw))
        buffer:set(2, string.char(Groen, Rood, Blauw))
        buffer:set(3, string.char(Groen, Rood, Blauw))
        buffer:set(4, string.char(Groen, Rood, Blauw))
        buffer:set(5, string.char(Groen, Rood, Blauw))
        buffer:set(6, string.char(Groen, Rood, Blauw))
        buffer:set(loopstate, string.char(100, 0, 0))
        ws2812.write(buffer)
    else
        buffer = ws2812.newBuffer(6, 3)
        buffer:set(1, string.char(0, 0, 0))
        buffer:set(2, string.char(0, 0, 0))
        buffer:set(3, string.char(0, 0, 0))
        buffer:set(4, string.char(0, 0, 0))
        buffer:set(5, string.char(0, 0, 0))
        buffer:set(6, string.char(0, 0, 0))
        ws2812.write(buffer)
    end
end)

tmr.alarm(3, 500, 1, function ()
    avgLight = adc.read(0)
end)
