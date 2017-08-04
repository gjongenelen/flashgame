
Sensor = { interval = 20, threshold = 20, avgLight = 0}


function Sensor.waitForInteraction(callback)
    tmr.alarm(4, Sensor.interval, 1, function()
        Sensor.avgLight = adc.read(0)
        if ( Sensor.avgLight > Sensor.threshold) then
            callback()
            tmr.stop(4)
        end
    end)
end
