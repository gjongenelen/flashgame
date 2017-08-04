Config = {
    button0Count = 0,
    button0Pushed = false,
    switch0State = 0,
    inConfigMenu = false
}

function Config.enterConfigMenu()
    Led.off()
    Game.stop()
    Config.inConfigMenu = true
    Config.button0Pushed = false

    Config.paintRing()
    Server.indicateOrder()
end

function Config.exitConfigMenu()
    Config.inConfigMenu = false
    Config.button0Pushed = false
    Led.off()
end

function Config.handleButton0Val(value)
    if value == 1 then -- raise
        Config.button0Count = 0
        if Config.button0Pushed and Config.inConfigMenu then
            Game.addRound()
            Config.paintRing()
            Config.button0Pushed = false
        end
        if Config.button0Pushed and not Config.inConfigMenu then
            Game.startAfter(2)
            Config.button0Pushed = false
        end
        Config.button0Pushed = false
    else
        if Config.button0Count == 0 then
            Config.button0Pushed = true
        end
        Config.button0Count = Config.button0Count + 1
    end
end

function Config.handleSwitch0Val(value)
    if value == 1 then
        Config.switch0State = true
        Game.setRandom(true)
    else
        Config.randomButton = false
        Game.setRandom(false)
    end
end

function Config.startListening()
    gpio.mode(0, gpio.OUTPUT)

    tmr.alarm(3, 1000, 1, function()

        Config.handleButton0Val(gpio.read(0))
        Config.handleSwitch0Val(gpio.read(1))

        if Config.button0Count == 10 and not Config.inConfigMenu then
            Config.enterConfigMenu()
        elseif Config.button0Count == 10 and Config.inConfigMenu then
            Config.exitConfigMenu()
        end
    end)
end

function Config.paintRing()
    if Game.rounds == 0 then
        Led.set({
            a = { g = 0, r = 0, b = 255 },
            b = { g = 0, r = 0, b = 255 },
            c = { g = 0, r = 0, b = 255 },
            d = { g = 0, r = 0, b = 255 },
            e = { g = 0, r = 0, b = 255 },
            f = { g = 0, r = 0, b = 255 },
            g = { g = 0, r = 0, b = 255 }
        })
    else
        local config = {
            a = { g = 0, r = 255, b = 0 },
            b = { g = 0, r = 0, b = 0 },
            c = { g = 0, r = 0, b = 0 },
            d = { g = 0, r = 0, b = 0 },
            e = { g = 0, r = 0, b = 0 },
            f = { g = 0, r = 0, b = 0 },
            g = { g = 0, r = 0, b = 0 }
        }
        if Game.rounds > 1 then
            config['b'] = { g = 0, r = 255, b = 0 }
        end
        if Game.rounds > 2 then
            config['c'] = { g = 0, r = 255, b = 0 }
        end
        if Game.rounds > 3 then
            config['d'] = { g = 0, r = 255, b = 0 }
        end
        if Game.rounds > 4 then
            config['e'] = { g = 0, r = 255, b = 0 }
        end
        if Game.rounds > 5 then
            config['f'] = { g = 0, r = 255, b = 0 }
        end
        if Game.rounds > 6 then
            config['g'] = { g = 0, r = 255, b = 0 }
        end
        Led.set(config)
    end
end
