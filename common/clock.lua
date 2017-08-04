Clock = { seconds = 0, mseconds = 0, timers = {}, callbacks = {} }

function Clock.start()
    tmr.alarm(0, 100, 1, function()
        if Clock.mseconds == 9 then
            Clock.seconds = Clock.seconds + 1
            Clock.mseconds = 0
        else
            Clock.mseconds = Clock.mseconds + 1
        end

        for k, v in pairs(Clock.timers) do
            if v == 0 then
                pcall(Clock.callbacks[k])
                Clock.timers[k] = nil
                Clock.callbacks[k] = nil
            else
                Clock.timers[k] = v - 1
            end
        end
    end)
end

function Clock.setTimeout(callback, timeout)
    local id = tablelength(Clock.timers)
    Clock.timers[id] = timeout
    Clock.callbacks[id] = callback
    id = nil
end
