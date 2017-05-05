local seconds = 0
tmr.alarm(0, 1000, 1, function()
    seconds = seconds + 1   
end)

local connections = {}
local clients = {}

tmr.alarm(1, 1000, 1, function()
    for mac,v in pairs(clients) do 
        if v < seconds - 1 and v >= seconds - 5 then
            sendToMac(mac, {action="ping"})
        end
        if v < seconds - 5 then
            print("Client not responding to pings, deauth: ",mac)
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

function sendToRandomConnection()
    local i = 1
    local random = math.random(1,tablelength(connections))
    if random == 0 then
        print("self")
    else 
        for mac, conn in pairs(connections) do 
            if i == random then
                sendToMac(mac, {action="test"})
            end
            i = i + 1
        end
    end
end

function sendToMac(mac, array)
    ok, json = pcall(cjson.encode, array)
    pcall(function() 
        connections[mac]:send(json .. " ")
        print("o", mac, json)
    end)
end

tmr.alarm(2, 4000, 1, function()
    sendToRandomConnection()
end)

function getMacByIp(ip1)
    table1={}
    table1=wifi.ap.getclient()

    for mac,ip in pairs(table1) do
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
end


ws2812.init()   -- GRB
buffer = ws2812.newBuffer(6, 3)
        buffer:set(1, string.char(255, 0, 0))
        buffer:set(2, string.char(255, 0, 0))
        buffer:set(3, string.char(255, 0, 0))
        buffer:set(4, string.char(255, 0, 0))
        buffer:set(5, string.char(255, 0, 0))
        buffer:set(6, string.char(255, 0, 0))
        ws2812.write(buffer)
        
wifi.setmode(wifi.STATIONAP)
wifi.setphymode(wifi.PHYMODE_G)
wifi.ap.config({ssid="FlashGame",pwd="12345678", max=4, channel=2});
print("Server IP Address:",wifi.ap.getip())

sv = net.createServer(net.TCP) 
sv:listen(80, function(conn)
    port, ip = conn:getpeer()
    clients[getMacByIp(ip)] = seconds
    connections[getMacByIp(ip)] = conn

    conn:on("connection", function(sck, c)
        port, ip = conn:getpeer()
        print("New client", getMacByIp(ip))
    end)
    
    conn:on("receive", function(conn, receivedData)
        for x in string.gmatch(receivedData, "%S+") do
            handleMessage(conn, x)
        end
    end)
    
end)
