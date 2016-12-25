platform = {}
player = {}

obstacles = {}
animators = {}

screen = {}

debug_data = {}

animation = require "animation"

function love.load()

    package.path = [[/home/mofleury/.IdeaIC2016.3/config/plugins/Lua/mobdebug/?.lua;]] .. package.path
    require("mobdebug").start()


    love.window.setMode(1600, 1200, { highdpi = true })

    screen.dx = love.graphics.getWidth() / 2
    screen.dy = love.graphics.getHeight() / 2

    zero_spritesheet = dofile("zero_sprites.lua")
    zero = animation.animator(zero_spritesheet, player)


    player.x = 100

    player.y = 7 * screen.dy / 8 - 40

    player.dx = 48
    player.dy = 48

    player.orientation = 1

    current_anim = 1

    player.state = "idle"
end

released = true

function love.update(dt)

    local reverse = {}
    local c = 1
    for i, k in pairs(zero_spritesheet.animations) do
        reverse[c] = i
        c = c + 1
    end
    total_anim = c


    if love.keyboard.isDown('space') then
        zero.update(dt)
    end

    local reset = false

    if released and love.keyboard.isDown('d') then
        current_anim = current_anim + 1
        released = false
        reset = true
    elseif released and love.keyboard.isDown('a') then
        current_anim = current_anim - 1
        released = false
        reset = true
    end

    if not (love.keyboard.isDown('d') or love.keyboard.isDown('a')) then
        released = true
    end



    if (current_anim >= total_anim) then
        current_anim = 1
    elseif current_anim < 1 then
        current_anim = total_anim - 1
    end

    debug_data = { state = reverse[current_anim] }

    player.state = reverse[current_anim]
    if reset then
        zero.update(dt)
    end
end


local function deepPrint(t)

    local function deepPrintWithGap(t, gap, buffer)
        for key, value in pairs(t) do
            if (type(value) == "table") then
                table.insert(buffer, gap .. key)
                deepPrintWithGap(value, gap .. "  ", buffer)
            else
                table.insert(buffer, gap .. key .. " = " .. tostring(value))
            end
        end
    end

    local b = {}
    deepPrintWithGap(t, "", b)

    love.graphics.print(table.concat(b, "\n"))
end

function love.draw()

    love.graphics.scale(8, 8)

    zero.draw()


    deepPrint(debug_data)
    debug_data = {}
end
