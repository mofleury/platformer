local animation = require "animation"
local control = require "control"
local tiles = require "tiles"

local obstacles = {}
local animators = {}
local controllers = {}
local players = {}

local screen = {}

local map = nil

local side_margin = 200

local camera_window

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

local FPSCAP = 60 -- change if you want higher/lower max fps

local lastframe

local function sleepIfPossible(dt)

    if lastframe then

        local slack = 1 / FPSCAP - (love.timer.getTime() - lastframe)
        if slack > 0 then
            love.timer.sleep(slack)
        end
        local now = love.timer.getTime()
        local diff = now - lastframe
    end
    lastframe = love.timer.getTime()
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

    local camera_window_width = 100
    camera_window = { x = screen.dx / 2 - camera_window_width / 2, y = screen.dy / 2 - 100, dx = camera_window_width, dy = 200 }


    map = tiles.tilemap("resources/levels/sandbox", "resources/levels", screen)


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

    local p = players[1]

    if p.x < screen.x + camera_window.x then
        screen.x = p.x - camera_window.x
    elseif p.x + p.dx > screen.x + camera_window.x + camera_window.dx then
        screen.x = p.x + p.dx - (camera_window.x + camera_window.dx)
    end


    if p.y < screen.y + camera_window.y then
        screen.y = p.y - camera_window.y
    elseif p.y + p.dy > screen.y + camera_window.y + camera_window.dy then
        screen.y = p.y + p.dy - (camera_window.y + camera_window.dy)
    end

    --    screen.x = players[1].x - screen.dx/2
    --    screen.y = players[1].y - screen.dy / 2

    sleepIfPossible(dt)
end


local function drawBox(b)
    --    love.graphics.setColor(200, 200, 200)
    love.graphics.rectangle('line', b.x - screen.x, screen.dy - (b.y + b.dy - screen.y), b.dx, b.dy)
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

    --    drawBox({ x = screen.x + camera_window.x, y = screen.y + camera_window.y, dx = camera_window.dx, dy = camera_window.dy })

    map.draw()


    for i, a in ipairs(animators) do
        a.draw()
    end

    for i, a in pairs(debug_data.colliding) do
        drawBox(a)
    end

    deepPrint(debug_data)
    debug_data = {}

    love.graphics.print("FPS : " .. love.timer.getFPS(), screen.dx - 100, 20)
end
