Games = {
    a = { a = 'RANDOM' },
    b = { a = 'RANDOM_NOSERVER' },
    c = { a = 'SERVER', b = 'A', c = 'B', d = 'C', e = 'D' }
}

Game = { config = { colors = { red = 0, green = 255, blue = 0, accent = { red = 0, green = 100, blue = 0 } } }, previous = nil, step = 1 }

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

    if (Games['a'][Game.step] == 'RANDOM') then
        Game.random(true)
    end

    if (Games['a'][Game.step] == 'RANDOM_NOSERVER') then
        Game.random(false)
    end

    if (Games['a'][Game.step] == 'SERVER') then
        Game.alarmLocal()
    end

    --todo alarm clients by index

    Game.step = Game.step + 1
    if (tablelength(Games['a']) < Game.step) then
        Game.step = 1
    end

end

function Game.alarmLocal()
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
        Game.nextStep()
    end)
end

function Game.random(includeLocal)
    local random
    if (includeLocal) then
        random = math.random(0, tablelength(Server.connections))
    else
        random = math.random(1, tablelength(Server.connections))
    end
    if Game.previous == random then
        Game.random()
    else
        Game.previous = random
        if random == 0 then
            Game.alarmLocal()
        else
            local i = 1
            for mac, _ in pairs(Server.connections) do
                if i == random then
                    Server.sendToMac(mac, { action = "alarm" })
                end
                i = i + 1
            end
        end
    end
end
