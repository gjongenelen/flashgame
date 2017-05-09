Games = {
    a = { 'RANDOM' },
    b = { 'RANDOM_NOSERVER' },
    c = { 'SERVER', 'A', 'B', 'C', 'D' }
}

Game = { config = { colors = { red = 0, green = 255, blue = 0, accent = { red = 0, green = 100, blue = 0 } } }, previous = nil, step = 1, running = false, currentNode = nil }

function Game.start()
    if not Game.running then
        Game.running = true
        Game.nextStep()
    end
end

function Game.startAfter(seconds)
    tmr.alarm(5, 1000, 1, function()
        if (Clock.seconds > seconds) then
            Game.start()
            tmr.stop(5)
        end
    end)
end

function Game.repeatStep()
    Game.step = Game.step - 1
    if (Game.step == 0) then
        Game.step = 1
    end
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

function Game.alarmLocal(callback)
    Game.currentNode = "LOCAL"
    Led.alarm({
        a = { g = Game.config.colors.green, r = Game.config.colors.red, b = Game.config.colors.blue },
        b = { g = Game.config.colors.green, r = Game.config.colors.red, b = Game.config.colors.blue },
        c = { g = Game.config.colors.green, r = Game.config.colors.red, b = Game.config.colors.blue },
        d = { g = Game.config.colors.green, r = Game.config.colors.red, b = Game.config.colors.blue },
        e = { g = Game.config.colors.green, r = Game.config.colors.red, b = Game.config.colors.blue },
        f = { g = Game.config.colors.green, r = Game.config.colors.red, b = Game.config.colors.blue },
        z = { g = Game.config.colors.accent.green, r = Game.config.colors.accent.red, b = Game.config.colors.accent.blue },
    }, 60)
    Sensor.waitForInteraction(function()
        Led.off()
        callback()
    end)
end

function Game.random(includeLocal)
    local random
    if (includeLocal) then
        random = math.random(0, tablelength(Server.connections))
    else
        random = math.random(1, tablelength(Server.connections))
    end
    print(tablelength(Server.connections))
    if Game.previous == random and tablelength(Server.connections) > 0 then
        Game.random(includeLocal)
    else
        Game.previous = random
        if random == 0 then
            Game.alarmLocal(function()
                Game.nextStep()
            end)
        else
            local i = 1
            for mac, _ in pairs(Server.connections) do
                if i == random then
                    Game.currentNode = mac
                    Server.sendToMac(mac, { action = "startBlinking" })
                end
                i = i + 1
            end
        end
    end
end
