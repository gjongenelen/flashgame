local seconds = 0

local connections = {}
local clients = {}

readyToSend = false
readyToPlay = false
local FlashOn = false
local Groen = 255
local Rood = 0
local Blauw = 0
tmr.alarm(0, 1000, 1, function()
    if (seconds == 5) then
        readyToPlay = true
        readyToSend = true
    end
    seconds = seconds + 1
    

    for mac, v in pairs(clients) do
        if v < seconds - 5 and v >= seconds - 10 then
            sendToMac(mac, { action = "ping" })
        end
        if v < seconds - 10 then
            print("Client not responding to pings, deauth: ", mac)
            wifi.ap.deauth(mac)
            clients[mac] = nil
            connections[mac] = nil
        end
    end
end)

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

previous = nil
function sendToRandomConnection()
    local i = 1
    local random = math.random(0, tablelength(connections))
    if previous == random then 
       print("repeated random", previous, random)
       sendToRandomConnection()
    else 
        previous = random
        if random == 0 then
            FlashOn = true
            print("self")
        else
            for mac, conn in pairs(connections) do
                if i == random then
                    sendToMac(mac, { action = "test" })
                end
                i = i + 1
            end
        end
        readyToSend = false
    end
end

        
function sendToMac(mac, array)
    ok, json = pcall(cjson.encode, array)
    pcall(function()
        connections[mac]:send(json .. " ")
        print("o", mac, json)
    end)
end


function getMacByIp(ip1)
    table1 = {}
    table1 = wifi.ap.getclient()

    for mac, ip in pairs(table1) do
        if ip1 == ip then
            return mac
        end
    end
end

function handleMessage(conn, receivedData)
    port, ip = conn:getpeer()
    print("i", getMacByIp(ip), receivedData)
    data = cjson.decode(receivedData)
    if (data['action'] == "pong") then
        port, ip = conn:getpeer()
        clients[getMacByIp(ip)] = seconds
    end
    if (data['action'] == "stoppedBlinking") then
        readyToSend = true
    end


end


ws2812.init() -- GRB
buffer = ws2812.newBuffer(6, 3)
buffer:set(1, string.char(255, 0, 0))
buffer:set(2, string.char(255, 0, 0))
buffer:set(3, string.char(255, 0, 0))
buffer:set(4, string.char(255, 0, 0))
buffer:set(5, string.char(255, 0, 0))
buffer:set(6, string.char(255, 0, 0))
ws2812.write(buffer)


local avgLight = 0 --  Analog LDR value

local loopstate = 1
tmr.alarm(3, 50, 1, function ()
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
        buffer:set(loopstate, string.char(50, 0, 0))
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

-- id -- Interval -- ???
tmr.alarm(4, 50, 1, function ()
    if (FlashOn) then
        if (math.abs(adc.read(0) - avgLight)>30) then
            FlashOn = false
            readyToSend = true
        end
    end
    if (readyToSend and readyToPlay) then 
        sendToRandomConnection()
    end
end)


tmr.alarm(5, 500, 1, function ()
    avgLight = adc.read(0)
end)

wifi.setmode(wifi.STATIONAP)
wifi.setphymode(wifi.PHYMODE_G)
wifi.ap.config({ ssid = "FlashGame", pwd = "12345678", max = 4, channel = 2 });
print("Server IP Address:", wifi.ap.getip())

sv = net.createServer(net.TCP)
sv:listen(80, function(conn)
    port, ip = conn:getpeer()
    clients[getMacByIp(ip)] = seconds
    connections[getMacByIp(ip)] = conn

    conn:on("connection", function(sck, c)
        port, ip = conn:getpeer()
        print("New client", getMacByIp(ip))
        sendToMac(getMacByIp(ip), { action = "config", r=Rood,b=Blauw,g=Groen })
    end)

    conn:on("receive", function(conn, receivedData)
        for x in string.gmatch(receivedData, "%S+") do
            handleMessage(conn, x)
        end
    end)
end)
