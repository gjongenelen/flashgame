
Sensor = { interval = 50, threshold = 30, avgLight = 0}


tmr.alarm(3, 500, 1, function ()
    Sensor.avgLight = adc.read(0)
end)

function Sensor.waitForInteraction(callback)
    tmr.alarm(4, Sensor.interval, 1, function()
        if (math.abs(adc.read(0) - Sensor.avgLight) > Sensor.threshold) then
            callback()
            tmr.stop(4)
        end
    end)
end
