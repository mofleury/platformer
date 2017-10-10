local animation = require "animation"
local control = require "control"
local tiles = require "tiles"
local cameras = require "cameras"
local collision = require "collision"
local minimap = require "minimap"

local animators = {}
local controllers = {}
local players = {}
local mobs = {}
local bullets = {}
local slashes = {}

local screen = {}


local map = nil

local camera
local mini = nil

local bulletSpriteSheet

debug_data = {}

local function create_player(map, x, y, keys)
    local player = {}

    local zero_spritesheet = dofile("resources/characters/zerox3.lua")
    local animator = animation.animator(zero_spritesheet, player, screen)
    animators[player] = animator


    player.x = x
    player.y = y

    player.dx = 30
    player.dy = 45

    player.orientation = 1
    player.state = "idle"

    controllers[player] = control.player(player, map, keys)

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

local function createMob()
    local mob = { x = 100, y = 100, dx = 22, dy = 26, orientation = 1, state = "idle" }
    mobs[mob] = true

    local mobAnimator = animation.animator(dofile("resources/characters/blob.lua"), mob, screen)
    animators[mob] = mobAnimator

    local mobController = control.blob(mob, players[1], map)
    controllers[mob] = mobController
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

    local minimap_location = { x = 6 * screen.dx / 8, y = 6 * screen.dy / 8, dx = screen.dx / 8, dy = screen.dy / 8 }


    local camera_window_width = 100
    local camera_window = { x = screen.dx / 2 - camera_window_width / 2, y = screen.dy / 2 - 100, dx = camera_window_width, dy = 200 }

    map = tiles.tilemap("resources/levels/sandbox", "resources/levels", screen)

    table.insert(players, create_player(map, screen.dx / 2, 400, { left = 'left', right = 'right', jump = 'a', dash = 's', shoot = 'd', slash = 'x' }))

    camera = cameras.windowCamera(camera_window, screen, players[1])

    mini = minimap.minimap(screen, map, players, minimap_location, 20, 40)

    bulletSpriteSheet = dofile("resources/characters/bullet.lua")

    --    table.insert(players, create_player(map, screen.dx / 2 + 50, 400, { left = 'k', right = 'l', jump = 'q', dash = 'w' }))
end



local function newBullet(playerShotEvent)
    local source = playerShotEvent.from

    local frame = animators[source].currentFrame()

    local xb
    if playerShotEvent.orientation == 1 then
        xb = source.x + frame.ax + 10
    else
        xb = source.x + source.dx - frame.ax - 10
    end

    local bullet = { x = xb, y = source.y + frame.ay - 5, dx = 10, dy = 10, orientation = playerShotEvent.orientation, state = "idle" }

    local c = control.bullet(bullet, map, screen)

    controllers[bullet] = c

    local a = animation.animator(bulletSpriteSheet, bullet, screen)

    animators[bullet] = a

    bullets[bullet] = true
end

local function newSlash(playerSlashEvent)
    local source = playerSlashEvent.from

    local slash = { x = source.x, y = source.y, dx = 10, dy = 10, orientation = source.orientation }

    local c = control.slash(slash, source)

    controllers[slash] = c

    slashes[slash] = true
end

local function endSlash(event)
    local slash = event.from
    controllers[slash] = nil
    slashes[slash] = nil
end


local function destroyBullet(bullet)
    controllers[bullet] = nil
    animators[bullet] = nil
    bullets[bullet] = nil
end



local function bulletLost(bulletLostEvent)
    destroyBullet(bulletLostEvent.from)
end

local function destroyMob(mob)
    controllers[mob] = nil
    animators[mob] = nil
    mobs[mob] = nil
end

function love.update(dt)

    --    debug_data.players = players
    --    debug_data.screen = screen
    --    debug_data.controllers = controllers
    --    debug_data.animators = animators

    if (love.keyboard.isDown('f')) then
        createMob()
    end


    local allEvents = {}

    for i, c in pairs(controllers) do
        local events = c.update(dt)
        if events ~= nil then
            table.insert(allEvents, events)
        end
    end

    for i, a in pairs(animators) do
        a.update(dt)
    end

    for i, events in ipairs(allEvents) do
        if events.playerShot then
            newBullet(events.playerShot)
        end
        if events.bulletLost then
            bulletLost(events.bulletLost)
        end
        if events.playerSlash then
            newSlash(events.playerSlash)
        end
        if events.slashComplete then
            endSlash(events.slashComplete)
        end
    end

    debug_data.things = { events, mobs, bullets, slashes }

    for b, i in pairs(bullets) do
        for m, j in pairs(mobs) do
            if collision.overlap(b, m) then
                destroyBullet(b)
                destroyMob(m)
            end
        end
    end
    for b, i in pairs(slashes) do
        for m, j in pairs(mobs) do
            if collision.overlap(b, m) then
                destroyMob(m)
            end
        end
    end

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


    for i, a in pairs(animators) do
        a.draw()
    end

    for i, a in pairs(debug_data.colliding) do
        drawBox(a)
    end

    mini.draw()

    deepPrint(debug_data)
    debug_data = {}

    love.graphics.print("FPS : " .. love.timer.getFPS(), screen.dx - 100, 20)
end
