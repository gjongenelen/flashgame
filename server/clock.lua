
Clock = { seconds = 0 }

function Clock.start()
    tmr.alarm(0, 1000, 1, function()
        Clock.seconds = Clock.seconds + 1
    end)
end
