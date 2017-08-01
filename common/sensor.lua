
Sensor = { interval = 50, threshold = 30, avgLight = 0, isPolling = false}


tmr.alarm(3, 200, 1, function ()
    if not Sensor.isPolling then
        Sensor.avgLight = adc.read(0)
    end
    print(Sensor.avgLight .. " - " .. adc.read(0))
end)

function Sensor.waitForInteraction(callback)
    Sensor.isPolling = true
    local count = 0
    tmr.alarm(4, Sensor.interval, 1, function()
        if count > 5 then
            if (math.abs(adc.read(0) - Sensor.avgLight) > Sensor.threshold) then
                Sensor.isPolling = false
                callback()
                tmr.stop(4)
            end
        else
            Sensor.avgLight = adc.read(0)
        end
        count = count + 1
    end)
end
