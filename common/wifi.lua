
Wifi = { ssid = "FlashGame", password = "12345678" }

function Wifi.startServer()
    wifi.setmode(wifi.STATIONAP)
    wifi.setphymode(wifi.PHYMODE_G)
    wifi.ap.config({ ssid = Wifi.ssid, pwd = Wifi.password, max = 4, channel = 2 });
    print("Server IP Address:", wifi.ap.getip())
end

function Wifi.connectClient()
    wifi.sta.disconnect()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(Wifi.ssid, Wifi.password)
    wifi.sta.connect()
    print("Looking for a connection")

    tmr.alarm(2, 1000, 1, function()                            -- Verbinding opzetten
        if(wifi.sta.getip()~=nil) then                        -- Wanneer er een IP is toegewezen
            tmr.stop(2)                                       -- Stop timer voor connectie
            print("Client IP Address:", wifi.sta.getip())
        else
            Led.alarm({
                a = { g = 0, r = 0, b = 0 },
                b = { g = 0, r = 0, b = 0 },
                c = { g = 0, r = 0, b = 0 },
                d = { g = 0, r = 0, b = 0 },
                e = { g = 0, r = 0, b = 0 },
                f = { g = 0, r = 0, b = 0 },
                z = { g = 100, r = 100, b = 0 },
            }, 200)
            print("Connecting...")
        end
    end)
end




function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end