Games = {
    a = { 'RANDOM' },
    b = { 'RANDOM_NOSERVER' },
    c = { 'SERVER', 'A', 'B', 'C', 'D' }
}

Game = {
    config = { colors = { red = 0, green = 255, blue = 0, accent = { red = 255, green = 0, blue = 0 } } },
    previous = nil,
    step = 1,
    running = false,
    currentNode = nil,
    seqIndex = 0,
    rounds = 0,
    stepCount = 0,
    currentRound = 0,
    isRandom = false,
    waitingForClient = false
}

function Game.setRandom(random)
    Game.isRandom = random
end

function Game.start()
    if not Game.running then
        Led.off()
        Game.running = true
        Game.nextStep()
    end
end

function Game.stop(softly)
    Game.stepCount = 0
    Game.running = false
    Game.step = 1
    if Game.currentNode == "LOCAL" then
        Led.off()
    else
        if not softly then
            Server.sendToMac(Game.currentNode, { action = "stopBlinking" })
        end

    end
end

function Game.startIfWaiting()
    if Game.waitingForClient then
        Led.off()
        Game.start()
        tmr.stop(5)
    end
end

function Game.startAfter(seconds)
    if Game.running then
        return
    end

    if tablelength(Server.connections) > 0 then
        tmr.alarm(5, 1000, 1, function()
            if (Clock.seconds > seconds) then
                Game.start()
                tmr.stop(5)
            end
        end)
    else
        Game.waitingForClient = true
        Led.alarm({
            a = { g = 0, r = 0, b = 0 },
            b = { g = 0, r = 0, b = 0 },
            c = { g = 0, r = 0, b = 0 },
            d = { g = 0, r = 0, b = 0 },
            e = { g = 0, r = 0, b = 0 },
            f = { g = 0, r = 0, b = 0 },
            g = { g = 0, r = 0, b = 0 },
            z = { g = 0, r = 100, b = 0 },
        }, 100)
    end
end

function Game.addRound()
    Game.rounds = Game.rounds + 1
    if Game.rounds > 7 then
        Game.rounds = 0
    end
    Game.currentRound = 0
end

function Game.repeatStep()
    Game.seqIndex = Game.seqIndex - 1
    if (Game.seqIndex < 0) then
        Game.seqIndex = 0
    end
    Game.nextStep()
end

function Game.nextStep()
    if not Game.running then
        return
    end

    if Game.isRandom then
        if Game.stepCount >= (Game.rounds * 5) and Game.rounds ~= 0 then
            Game.stop(true)
            Server.sendDone()
            Led.alarmDone()
        else
            Game.random(true)
            Game.stepCount = Game.stepCount + 1
        end
    else
        if Game.stepCount >= (Game.rounds * 5) and Game.rounds ~= 0 then
            Game.stop()
            Server.sendDone()
            Led.alarmDone()
        else
            Game.sequential()
            Game.stepCount = Game.stepCount + 1
        end
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
        g = { g = Game.config.colors.green, r = Game.config.colors.red, b = Game.config.colors.blue },
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
    random = nil
end


function Game.sequential()
    if Game.seqIndex > tablelength(Server.clients) then
        Game.seqIndex = 0
    end
    if Game.seqIndex == 0 then
        Game.alarmLocal(function()
            Game.nextStep()
        end)
    else
        local count = 1
        for mac, _ in pairs(Server.clients) do
            if count == Game.seqIndex then
                Game.currentNode = mac
                Server.sendToMac(mac, { action = "startBlinking" })
                count = count + 1
            else
                count = count + 1
            end
        end
    end

    Game.seqIndex = Game.seqIndex + 1
end
