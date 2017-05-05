
Game = { config = { colors = { red = 0, green = 255, blue = 0, accent = { red = 0, green = 100, blue = 0 } }}}

function Game.start()
    Game.nextStep()
end

function Game.startAfter(seconds)
    tmr.alarm(5, 1000, 1, function()
        if (Clock.seconds > seconds) then
            Game.start()
            tmr.stop(5)
        end
    end)
end

function Game.nextStep()

    Led.alarm({
        a = { g = 255, r = 0, b = 0 },
        b = { g = 255, r = 0, b = 0 },
        c = { g = 255, r = 0, b = 0 },
        d = { g = 255, r = 0, b = 0 },
        e = { g = 255, r = 0, b = 0 },
        f = { g = 255, r = 0, b = 0 },
        z = { g = 100, r = 0, b = 0 },
    }, 60)
    Sensor.waitForInteraction(function()
        Led.off()
        --Game.nextStep()
    end)


end
