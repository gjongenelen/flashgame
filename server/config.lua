
Config = { resetCount = 0, inConfigMenu = false, settingPushed = false, settingPush = 0, randomButton = false }


function Config.startListening()
    gpio.mode(0, gpio.OUTPUT)

    local first = true
    tmr.alarm(3, 100, 1, function()
        local resetButtonVal = gpio.read(0)
        local gameButtonVal = gpio.read(1)

        if first then
            if gameButtonVal == 1 then
                Config.randomButton = true
                Game.isRandom = true
            else
                Config.randomButton = false
                Game.isRandom = false
            end
            first = false
        end

        if resetButtonVal == 1 then
            Config.resetCount = 0
            if Config.settingPushed and Config.inConfigMenu then
                Game.addRound()
                Config.paintRing()
                Config.settingPushed = false
            end
            if Config.settingPushed and not Config.inConfigMenu then
                Game.startAfter(2)

                Config.settingPushed = false
            end
            Config.settingPushed = false
        elseif resetButtonVal == 0 then
            if Config.resetCount == 0 then
                Config.settingPushed = true
            end
        
            Config.resetCount = Config.resetCount + 1
        end
        if Config.resetCount == 10 and not Config.inConfigMenu  then
            Led.off()
            Game.stop()
            Config.inConfigMenu = true
            Config.settingPushed = false
            Config.paintRing()
        elseif Config.resetCount == 10 and Config.inConfigMenu  then
            Config.inConfigMenu = false
            Config.settingPushed = false
            Led.off()
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
