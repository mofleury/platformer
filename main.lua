animation = require "animation"
collision = require "collision"

player = {}

obstacles = {}
animators = {}

screen = {}

zero = nil

debug_data = {}
anim_debug_data = {}

local walling_speed_cap = -200

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



    player.x = screen.dx / 2

    player.y = 200

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
    player.wall_jump_timer = 0

    player.powerjump = false
    player.walling = false

    table.insert(obstacles, { x = 10, y = 30, dx = 10, dy = 20 })
    table.insert(obstacles, { x = 100, y = 50, dx = 10, dy = 30 })
    table.insert(obstacles, { x = 200, y = 80, dx = 20, dy = 20 })
    table.insert(obstacles, { x = 500, y = 20, dx = 50, dy = 20 })
    table.insert(obstacles, { x = 600, y = 50, dx = 50, dy = 20 })
    table.insert(obstacles, { x = 100, y = 120, dx = 200, dy = 20 })
    table.insert(obstacles, { x = 200, y = 140, dx = 200, dy = 20 })

    table.insert(obstacles, { x = 400, y = 100, dx = 20, dy = 20 })
    table.insert(obstacles, { x = 200, y = 100, dx = 20, dy = 600 })

    table.insert(obstacles, { x = 0, y = 0, dx = 10, dy = screen.dy })
    table.insert(obstacles, { x = screen.dx - 10, y = 0, dx = 10, dy = screen.dy })
    table.insert(obstacles, { x = 0, y = 0, dx = screen.dx, dy = 20 })
end

function love.update(dt)

    debug_data.player = player



    --may need to cancel dash
    if love.keyboard.isDown('right') and player.orientation == -1 then
        player.dash_timer = 0
        player.dashing = false
    end
    if love.keyboard.isDown('left') and player.orientation == 1 then
        player.dash_timer = 0
        player.dashing = false
    end

    if love.keyboard.isDown('s') then
        if player.dash_timer <= 0 and player.dash_credit > 0 then
            player.dashing = true
            player.dash_timer = 0.25
            player.dash_credit = player.dash_credit - 1
        end
    elseif not player.airborne or player.walling then
        player.dash_credit = 1
    end


    if (player.dash_timer > 0) then
        player.dash_timer = player.dash_timer - dt
    end
    if (player.wall_jump_timer > 0) then
        player.wall_jump_timer = player.wall_jump_timer - dt
    end


    if (player.dash_timer > 0) then

        player.x_speed = 450
        if not player.powerjump then
            player.y_velocity = 0
        end
    elseif not player.powerjump then
        player.dashing = false
        player.x_speed = 200
    end


    local moving = false

    if love.keyboard.isDown('right') and player.wall_jump_timer <= 0 then

        player.orientation = 1

        player.x = (player.x + player.x_speed * dt)

        moving = true
    elseif love.keyboard.isDown('left') and player.wall_jump_timer <= 0 then

        player.orientation = -1

        player.x = (player.x - (player.x_speed * dt))

        moving = true
    elseif player.wall_jump_timer > 0 then
        player.x = (player.x - player.orientation * (player.x_speed * dt))
    elseif player.dashing then

        player.x = (player.x + player.orientation * (player.x_speed * dt))
    elseif not (player.airborne or player.state == "landing") then
        player.state = "idle"
    end

    if player.dashing then
        player.state = "dashing"
    elseif not player.airborne then
        if moving then
            player.state = "running"
        end
    elseif not player.dashing then
        if player.y_velocity > 0 then
            player.state = "jumping"
        else
            player.state = "falling"
        end
    end

    if love.keyboard.isDown('a') then
        if not player.airborne or player.walling then
            player.y_velocity = player.jump_height
            player.airborne = true


            if player.dashing then
                player.powerjump = true
                player.dashing = false
            end

            if player.walling then
                player.state = "wall_jumping"
                player.wall_jump_timer = 0.2
            end

            player.walling = false
        end
    elseif player.y_velocity > 0 then
        -- mid jump, but not hitting jum key anymore : small jump
        player.y_velocity = 0
        --        player.state = "landing"
    end

    player.y = (player.y + player.y_velocity * dt)

    if player.airborne then
        player.y_velocity = player.y_velocity + player.gravity * dt
        if player.walling then
            player.y_velocity = math.max(walling_speed_cap, player.y_velocity)
        end
    end

    local colliding, details = false, {}
    for i, o in ipairs(obstacles) do
        local c, d = collision.collide(player, o)
        if (c) then
            colliding = true
            for k, e in pairs(d) do
                details[k] = o
            end
        end
    end

    debug_data.colliding = colliding
    debug_data.details = details

    if (colliding) then


        if (details.left or details.right) then
            if (details.left) then
                player.x = (details.left.x + details.left.dx + 1)
                if player.airborne and love.keyboard.isDown('left') then
                    player.state = "wall_landing"
                    player.walling = true
                    player.x_speed = 200
                end
            else -- right
                player.x = (details.right.x - player.dx - 1)
                if player.airborne and love.keyboard.isDown('right') then
                    player.state = "wall_landing"
                    player.walling = true
                    player.x_speed = 200
                end
            end
        end
        if (details.bottom or details.top) then
            player.y_velocity = 0
            if details.bottom then
                if player.airborne then
                    player.state = "landing"
                end

                player.y = (details.bottom.y + details.bottom.dy)
                player.airborne = false
                player.powerjump = false
                player.walling = false

            else -- top
                player.y = (details.top.y - player.dy - 1)
            end
        end

    elseif not player.airborne then
        local below = { x = player.x, y = player.y - 2, dx = player.dx, dy = 2 }
        local nothingBelow = true
        for i, o in ipairs(obstacles) do
            if (collision.overlap(below, o)) then
                nothingBelow = false
                break
            end
        end

        if nothingBelow then
            player.airborne = true
        end
    else
        player.walling = false
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
