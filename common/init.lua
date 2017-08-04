node.setcpufreq(node.CPU160MHZ)

local compileAndRemoveIfNeeded = function(f)
    if file.open(f) then
        file.close()
        print('Compiling:', f)
        node.compile(f)
        file.remove(f)
        collectgarbage()
    end
end

local serverFiles = {
    'clock.lua',
    'config.lua',
    'game.lua',
    'leds.lua',
    'sensor.lua',
    'server.lua',
    'wifi.lua'
}
for _, f in ipairs(serverFiles) do compileAndRemoveIfNeeded(f) end

compileAndRemoveIfNeeded = nil
serverFiles = nil

collectgarbage()

---------------------

function startup()
    dofile('start.lua')
end

tmr.alarm(0,1000,0,startup)
