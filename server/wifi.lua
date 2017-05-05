
local ssid = "FlashGame"
local password = "12345678"

wifi.setmode(wifi.STATIONAP)

wifi.setphymode(wifi.PHYMODE_G)

wifi.ap.config({ ssid = ssid, pwd = password, max = 4, channel = 2 });

print("Server IP Address:", wifi.ap.getip())

