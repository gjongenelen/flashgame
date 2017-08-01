
Led = { alarmOn = false }

function Led.init()
    ws2812.init() -- GRB

    Led.off()
end

function Led.off()
    Led.alarmOn = false
    Led.set({
        a = { g = 0, r = 0, b = 0 },
        b = { g = 0, r = 0, b = 0 },
        c = { g = 0, r = 0, b = 0 },
        d = { g = 0, r = 0, b = 0 },
        e = { g = 0, r = 0, b = 0 },
        f = { g = 0, r = 0, b = 0 },
        g = { g = 0, r = 0, b = 0 }
    })
end

function Led.set(config)
    local buffer = ws2812.newBuffer(7, 3)
    buffer:set(1, string.char(config['a']['g'], config['a']['r'], config['a']['b']))
    buffer:set(2, string.char(config['b']['g'], config['b']['r'], config['b']['b']))
    buffer:set(3, string.char(config['c']['g'], config['c']['r'], config['c']['b']))
    buffer:set(4, string.char(config['d']['g'], config['d']['r'], config['d']['b']))
    buffer:set(5, string.char(config['e']['g'], config['e']['r'], config['e']['b']))
    buffer:set(6, string.char(config['f']['g'], config['f']['r'], config['f']['b']))
    buffer:set(7, string.char(config['g']['g'], config['g']['r'], config['g']['b']))
    ws2812.write(buffer)
end

function Led.alarm(config, speed)
    Led.alarmOn = true
    local loopstate = 1
    tmr.alarm(6, speed, 1, function()
        if (Led.alarmOn) then
            loopstate = loopstate + 1
            if (loopstate == 8) then
                loopstate = 1
            end
            local buffer = ws2812.newBuffer(7, 3)
            buffer:set(1, string.char(config['a']['g'], config['a']['r'], config['a']['b']))
            buffer:set(2, string.char(config['b']['g'], config['b']['r'], config['b']['b']))
            buffer:set(3, string.char(config['c']['g'], config['c']['r'], config['c']['b']))
            buffer:set(4, string.char(config['d']['g'], config['d']['r'], config['d']['b']))
            buffer:set(5, string.char(config['e']['g'], config['e']['r'], config['e']['b']))
            buffer:set(6, string.char(config['f']['g'], config['f']['r'], config['f']['b']))
            buffer:set(7, string.char(config['g']['g'], config['g']['r'], config['g']['b']))
            buffer:set(loopstate, string.char(config['z']['g'], config['z']['r'], config['z']['b']))
            if loopstate == 7 then
                buffer:set(1, string.char(config['z']['g'], config['z']['r'], config['z']['b']))
            else
                buffer:set(loopstate + 1, string.char(config['z']['g'], config['z']['r'], config['z']['b']))
            end

            ws2812.write(buffer)
        else
            tmr.stop(6)
            Led.off()
        end
    end)
end
