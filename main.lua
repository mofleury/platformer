animation = require "animation"
collision = require "collision"

platform = {}
player = {}

obstacles = {}
animators = {}

screen = {}

zero = nil

debug_data = {}
anim_debug_data = {}



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

    local zero_spritesheet = dofile("zero_sprites.lua")
    local zero = animation.animator(zero_spritesheet, player)
    table.insert(animators, zero)

    platform.dx = screen.dx
    platform.dy = 20

    platform.x = 0
    platform.y = 0

    player.x = screen.dx / 2

    player.y = platform.y + platform.dy + 200

    player.dx = 30
    player.dy = 45

    player.orientation = 1
    player.state = "idle"

    player.x_speed = 200

    player.airborne = true

    player.ground = player.y - 1

    player.y_velocity = 0

    player.jump_height = 300
    player.gravity = -800

    player.dash_timer = 0
    player.dash_credit = 1

    table.insert(obstacles, { x = 10, y = 30, dx = 10, dy = 20 })
    table.insert(obstacles, { x = 100, y = 50, dx = 10, dy = 30 })
    table.insert(obstacles, { x = 200, y = 80, dx = 20, dy = 20 })
    table.insert(obstacles, { x = 500, y = 20, dx = 50, dy = 20 })
    table.insert(obstacles, { x = 600, y = 50, dx = 50, dy = 20 })
    table.insert(obstacles, { x = 0, y = 0, dx = 10, dy = screen.dy })
    table.insert(obstacles, { x = screen.dx - 10, y = 0, dx = 10, dy = screen.dy })
    table.insert(obstacles, platform)
end

function player:setX(x)
    self.oldx, self.x = self.x, x
end


function player:setY(y)
    self.oldy, self.y = self.y, y
end



function love.update(dt)

    --may need to cancel dash
    if love.keyboard.isDown('right') and player.orientation == -1 then
        player.dash_timer = 0
    end
    if love.keyboard.isDown('left') and player.orientation == 1 then
        player.dash_timer = 0
    end

    if love.keyboard.isDown('s') then
        if player.dash_timer <= 0 and player.dash_credit > 0 then
            player.dash_timer = 0.25
            player.dash_credit = player.dash_credit - 1
        end
    elseif not player.airborne then
        player.dash_credit = 1
    end


    if (player.dash_timer > 0) then
        player.dash_timer = player.dash_timer - dt
    end

    local dashing = false

    debug_data.player = player

    if (player.dash_timer > 0) then
        dashing = true
        player.x_speed = 450
        player.y_velocity = 0
    else
        player.x_speed = 200
    end

    if dashing then
        player.state = "dashing"
    elseif not player.airborne then
        player.state = "running"
    elseif not dashing then
        if player.y_velocity > 0 then
            player.state = "jumping"
        else
            player.state = "falling"
        end
    end


    if love.keyboard.isDown('right') then

        player.orientation = 1

        player:setX(player.x + player.x_speed * dt)
    elseif love.keyboard.isDown('left') then

        player.orientation = -1

        player:setX(player.x - (player.x_speed * dt))

    elseif dashing then

        player:setX(player.x + player.orientation * (player.x_speed * dt))

    elseif not player.airborne then
        player.state = "idle"
    end

    if love.keyboard.isDown('a') then
        if not player.airborne then
            player.y_velocity = player.jump_height
            player.airborne = true
        end
    elseif player.y_velocity > 0 then
        -- mid jump, but not hitting jum key anymore : small jump
        player.y_velocity = 0
        --        player.state = "landing"
    end

    player:setY(player.y + player.y_velocity * dt)

    if player.airborne and not dashing then
        player.y_velocity = player.y_velocity + player.gravity * dt
    end

    local colliding, details = false, {}
    for i, o in ipairs(obstacles) do
        local c, d = collision.collide(player, o)
        if (c) then
            colliding = true
            for k, e in pairs(d) do
                details[k] = e
            end
        end
    end

    debug_data.colliding = colliding

    if (colliding) then

        -- debug_data.collision = details
        if (details.bottom or details.top) then
            player.y_velocity = 0
            player:setY(player.oldy)
        end

        if (details.bottom) then
            player.airborne = false
        end

        if (details.left or details.right) then
            player:setX(player.oldx)
        end
    end

    -- cleanup original values for next iteration
    player.oldx = player.x
    player.oldy = player.y

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

    love.graphics.scale(2, 2)

    for i, o in ipairs(obstacles) do
        drawBox(o)
    end

    for i, a in ipairs(animators) do
        a.draw()
    end

    deepPrint(debug_data)
    debug_data = {}
end
