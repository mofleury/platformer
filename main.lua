local animation = require "animation"
local control = require "control"
local tiles = require "tiles"
local cameras = require "cameras"

local animators = {}
local controllers = {}
local players = {}
local mobs = {}

local screen = {}

local map = nil

local camera

debug_data = {}

local function create_player(map, x, y, keys)
    local player = {}

    local zero_spritesheet = dofile("resources/characters/zerox3.lua")
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
    local camera_window = { x = screen.dx / 2 - camera_window_width / 2, y = screen.dy / 2 - 100, dx = camera_window_width, dy = 200 }

    map = tiles.tilemap("resources/levels/sandbox", "resources/levels", screen)

    table.insert(players, create_player(map, screen.dx / 2, 400, { left = 'left', right = 'right', jump = 'a', dash = 's' }))

    camera = cameras.windowCamera(camera_window, screen, players[1])

    local mob = { x = 100, y = 100, dx = 22, dy = 26, orientation = 1, state = "idle" }

    local mobAnimator = animation.animator(dofile("resources/characters/blob.lua"), mob, screen)
    table.insert(animators, mobAnimator)

    local mobController = control.blob(mob, players[1], map)
    table.insert(controllers, mobController)


    --    table.insert(players, create_player(map, screen.dx / 2 + 50, 400, { left = 'k', right = 'l', jump = 'q', dash = 'w' }))
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

    camera.update(dt)

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

    --    drawBox(camera.windowBox())

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
