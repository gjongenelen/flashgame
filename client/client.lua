Client = {}

function Client.connect(callback)

    local cl = net.createConnection(net.TCP, 0)
    cl:connect(80, "192.168.4.1")
    cl:on("receive", function(connection, receivedData)
        for data in string.gmatch(receivedData, "%S+") do
            callback(connection, data)
        end
    end)

    tmr.alarm(1, 8000, 1, function()
        local _, json = pcall(cjson.encode, {action="pong"})
        pcall(function()
            cl:send(json .. " ")
        end)
    end)

end
