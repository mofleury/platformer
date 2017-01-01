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

function create_player(x, y, keys)
    local player = {}

    local zero_spritesheet = dofile("zero_sprites.lua")
    local animator = animation.animator(zero_spritesheet, player, screen)
    table.insert(animators, animator)

    map = tiles.tilemap("resources/levels/sandbox/sandbox", "resources/levels/sandbox", screen)

    player.x = x
    player.y = y

    player.dx = 30
    player.dy = 45

    player.orientation = 1
    player.state = "idle"

    table.insert(controllers, control.player(player, obstacles, keys))

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

    screen.dx = love.graphics.getWidth() / 2
    screen.dy = love.graphics.getHeight() / 2

    table.insert(players, create_player(screen.dx / 2, 200, { left = 'left', right = 'right', jump = 'a', dash = 's' }))


    table.insert(players, create_player(screen.dx / 2 + 50, 200, { left = 'k', right = 'l', jump = 'q', dash = 'w' }))


    table.insert(obstacles, { x = 10, y = 30, dx = 10, dy = 20 })
    table.insert(obstacles, { x = 100, y = 50, dx = 10, dy = 30 })
    table.insert(obstacles, { x = 200, y = 80, dx = 20, dy = 20 })
    table.insert(obstacles, { x = 500, y = 20, dx = 50, dy = 20 })
    table.insert(obstacles, { x = 600, y = 50, dx = 50, dy = 20 })
    table.insert(obstacles, { x = 100, y = 120, dx = 200, dy = 20 })
    table.insert(obstacles, { x = 200, y = 140, dx = 200, dy = 20 })
    table.insert(obstacles, { x = 550, y = 200, dx = 200, dy = 20 })

    table.insert(obstacles, { x = 400, y = 100, dx = 20, dy = 20 })
    table.insert(obstacles, { x = 200, y = 100, dx = 20, dy = 600 })

    table.insert(obstacles, { x = 0, y = 0, dx = 10, dy = screen.dy })
    table.insert(obstacles, { x = screen.dx - 10, y = 0, dx = 10, dy = screen.dy })
    table.insert(obstacles, { x = 0, y = 0, dx = screen.dx, dy = 20 })
end



function love.update(dt)

    debug_data.players = players
    --    debug_data.controllers = controllers

    for i, c in ipairs(controllers) do
        c.update(dt)
    end

    for i, a in ipairs(animators) do
        a.update(dt)
    end
end


local function drawBox(b)
    love.graphics.setColor(200, 200, 200)
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

    love.graphics.translate(400, 800)
    love.graphics.scale(0.5, 0.5)


    for i, o in ipairs(obstacles) do
        drawBox(o)
    end

    for i, a in ipairs(animators) do
        a.draw()
    end

    map.draw()

    deepPrint(debug_data)
    debug_data = {}
end
