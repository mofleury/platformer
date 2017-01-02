local animation = require "animation"
local control = require "control"
local tiles = require "tiles"

local obstacles = {}
local animators = {}
local controllers = {}
local players = {}

local screen = {}

local map = nil

debug_data = {}

local function create_player(map, x, y, keys)
    local player = {}

    local zero_spritesheet = dofile("zero_sprites.lua")
    local animator = animation.animator(zero_spritesheet, player, screen)
    table.insert(animators, animator)


    player.x = x
    player.y = y

    player.dx = 30
    player.dy = 45

    player.orientation = 1
    player.state = "idle"

    table.insert(controllers, control.player(player, map, keys))

    return player
end


function love.load()
    if arg[#arg] == "-debug" then require("mobdebug").start()
    end
    if arg[#arg] == "-ideadebug" then
        package.path = [[/home/mofleury/.IdeaIC2016.3/config/plugins/Lua/mobdebug/?.lua;]] .. package.path
        require("mobdebug").start()
    end

    love.window.setMode(1600, 1200, { highdpi = true })

    screen.x = 0
    screen.y = 0
    screen.dx = love.graphics.getWidth() / 2
    screen.dy = love.graphics.getHeight() / 2

    map = tiles.tilemap("resources/levels/sandbox/sandbox", "resources/levels/sandbox", screen)


    table.insert(players, create_player(map, screen.dx / 2, 400, { left = 'left', right = 'right', jump = 'a', dash = 's' }))


    --    table.insert(players, create_player(map, screen.dx / 2 + 50, 400, { left = 'k', right = 'l', jump = 'q', dash = 'w' }))


    --    table.insert(obstacles, { x = 10, y = 30, dx = 10, dy = 20 })
    --    table.insert(obstacles, { x = 100, y = 50, dx = 10, dy = 30 })
    --    table.insert(obstacles, { x = 200, y = 80, dx = 20, dy = 20 })
    --    table.insert(obstacles, { x = 500, y = 20, dx = 50, dy = 20 })
    --    table.insert(obstacles, { x = 600, y = 50, dx = 50, dy = 20 })
    --    table.insert(obstacles, { x = 100, y = 120, dx = 200, dy = 20 })
    --    table.insert(obstacles, { x = 200, y = 140, dx = 200, dy = 20 })
    --    table.insert(obstacles, { x = 550, y = 200, dx = 200, dy = 20 })
    --
    --    table.insert(obstacles, { x = 400, y = 100, dx = 20, dy = 20 })
    --    table.insert(obstacles, { x = 200, y = 100, dx = 20, dy = 600 })
    --
    --    table.insert(obstacles, { x = 0, y = 0, dx = 10, dy = screen.dy })
    --    table.insert(obstacles, { x = screen.dx - 10, y = 0, dx = 10, dy = screen.dy })
    --    table.insert(obstacles, { x = 0, y = 0, dx = screen.dx, dy = 20 })
end



function love.update(dt)

    debug_data.players = players
    debug_data.screen = screen
    --    debug_data.controllers = controllers

    for i, c in ipairs(controllers) do
        c.update(dt)
    end

    for i, a in ipairs(animators) do
        a.update(dt)
    end

    screen.x = players[1].x - screen.dx/2
    screen.y = players[1].y - screen.dy/2

end


local function drawBox(b)
    --    love.graphics.setColor(200, 200, 200)
    love.graphics.rectangle('fill', b.x, screen.dy - b.y - b.dy, b.dx, b.dy)
end

local function deepPrint(t)

    local function deepPrintWithGap(t, gap, buffer)
        for key, value in pairs(t) do
            if (type(value) == "table") then
                table.insert(buffer, gap .. tostring(key))
                deepPrintWithGap(value, gap .. "  ", buffer)
            else
                table.insert(buffer, gap .. tostring(key) .. " = " .. tostring(value))
            end
        end
    end

    local b = {}
    deepPrintWithGap(t, "", b)

    love.graphics.print(table.concat(b, "\n"))
end

function love.draw()

    --    love.graphics.translate(0, 500)
    --    love.graphics.scale(0.5, 0.5)


    love.graphics.scale(2, 2)

    map.draw()


    for i, a in ipairs(animators) do
        a.draw()
    end

    for i, a in pairs(debug_data.colliding) do
        drawBox(a)
    end

    deepPrint(debug_data)
    debug_data = {}

    love.graphics.print("FPS : " .. love.timer.getFPS(), 100, 20)
end
