Client = {}

function Client.connect(callback)
    local cl = net.createConnection(net.TCP, 0)
    cl:connect(80, "192.168.4.1")
    cl:on("receive", function(connection, receivedData)
        for data in string.gmatch(receivedData, "%S+") do
            callback(connection, data)
        end
    end)
end
