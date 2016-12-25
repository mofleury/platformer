platform = {}
player = {}

obstacles = {}
animators = {}

screen = {}

zero = nil

debug_data = {}

animation = require "animation"

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

    player.dx = 48
    player.dy = 48

    player.orientation = 1
    player.state = "idle"

    player.speed = 200

    player.img = love.graphics.newImage('resources/purple.png')

    player.ground = player.y - 1

    player.y_velocity = 0

    player.jump_height = 300
    player.gravity = -800

    table.insert(obstacles, { x = 10, y = 30, dx = 10, dy = 20 })
    table.insert(obstacles, { x = 100, y = 50, dx = 10, dy = 30 })
    table.insert(obstacles, { x = 200, y = 80, dx = 20, dy = 20 })
    table.insert(obstacles, platform)
end

local function collide(o1, o2)

    local w = 0.5 * (o1.dx + o2.dx);
    local h = 0.5 * (o1.dy + o2.dy);
    local dx = (o1.x + o1.dx / 2) - (o2.x + o2.dx / 2);
    local dy = (o1.y + o1.dy / 2) - (o2.y + o2.dy / 2);

    if (math.abs(dx) <= w and math.abs(dy) <= h) then

        local wy = w * dy;
        local hx = h * dx;

        local details = {}

        if (wy > hx) then

            if (wy > -hx) then
                -- / * collision at the bottom * /
                details.bottom = true
            else
                -- / * on the right * /
                details.right = true
            end
        else
            if (wy > -hx) then
                --  / * on the left * /
                details.left = true
            else
                -- / * at the top * /
                details.top = true
            end
        end

        if (math.abs(math.abs(wy) - math.abs(hx)) <= player.speed) then
            -- edge case : we are on a corner, we should say that both egdes collide
            if (wy > 0 and hx > 0) then
                details.bottom = true
                details.left = true
            elseif (wy > 0 and hx < 0) then
                details.bottom = true
                details.right = true
            elseif (wy < 0 and hx > 0) then
                details.top = true
                details.left = true
            elseif (wy < 0 and hx < 0) then
                details.top = true
                details.right = true
            end
        end

        return true, details
    end

    return false, {}
end

function player:setX(x)
    self.oldx, self.x = self.x, x
end


function player:setY(y)
    self.oldy, self.y = self.y, y
end



function love.update(dt)

    if love.keyboard.isDown('d') then
        player.orientation = 1
        if (player.y_velocity == 0) then
            player.state = "running"
        end
        if player.x < (screen.dx - player.dx) then
            player:setX(player.x + player.speed * dt)
        end
    elseif love.keyboard.isDown('a') then
        player.orientation = -1
        if (player.y_velocity == 0) then
            player.state = "running"
        end
        if player.x > 0 then
            player:setX(player.x - (player.speed * dt))
        end
    elseif (player.y_velocity == 0) then
        player.state = "idle"
    end

    if love.keyboard.isDown('space') then
        if player.y_velocity == 0 then
            player.y_velocity = player.jump_height
            player.state = "jumping"
        end
    elseif player.y_velocity > 0 then
        -- mid jump, but not hitting jum key anymore : small jump
        player.y_velocity = 0
--        player.state = "landing"
    end

    player:setY(player.y + player.y_velocity * dt)
    player.y_velocity = player.y_velocity + player.gravity * dt

    local colliding, details = false, {}
    for i, o in ipairs(obstacles) do
        colliding, details = collide(player, o)
        if (colliding) then
            break
        end
    end

    if (colliding) then

        -- debug_data.collision = details
        if (details.bottom or details.top) then
            player.y_velocity = 0
            player:setY(player.oldy)
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
