platform = {}
player = {}

obstacles = {}

screen = {}

zero = nil



function love.load()
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    if arg[#arg] == "-ideadebug" then
        package.path = [[/home/mofleury/.IdeaIC2016.3/config/plugins/Lua/classes/mobdebug/?.lua;]] .. package.path
        require("mobdebug").start()
    end

    screen.dx = love.graphics.getWidth()
    screen.dy = love.graphics.getHeight()

    platform.dx = love.graphics.getWidth()
    platform.dy = 20

    platform.x = 0
    platform.y = 0

    player.x = screen.dx / 2

    player.y = platform.y + platform.dy + 200


    player.dx = 32
    player.dy = 32

    player.speed = 200

    player.img = love.graphics.newImage('resources/purple.png')

    player.ground = player.y - 1

    player.y_velocity = 0

    player.jump_height = 300
    player.gravity = -800

    table.insert(obstacles, { x = 10, y = 30, dx = 10, dy = 20 })
    table.insert(obstacles, platform)

    zero = dofile("zero_sprites.lua")
end

local function collide(o1, o2)
    return o1.x < o2.x + o2.dx and
            o2.x < o1.x + o1.dx and
            o1.y < o2.y + o2.dy and
            o2.y < o1.y + o1.dy
end

function player:setX(x)
    self.oldx, self.x = self.x, x
end


function player:setY(y)
    self.oldy, self.y = self.y, y
end

function love.update(dt)

    if love.keyboard.isDown('d') then
        if player.x < (screen.dx - player.dx) then
            player:setX(player.x + player.speed * dt)
        end
    elseif love.keyboard.isDown('a') then
        if player.x > 0 then
            player:setX(player.x - (player.speed * dt))
        end
    end

    if love.keyboard.isDown('space') then
        if player.y_velocity == 0 then
            player.y_velocity = player.jump_height
        end
    elseif player.y_velocity > 0 then
        -- mid jump, but not hitting jum key anymore : small jump
        player.y_velocity = 0
    end

    player:setY(player.y + player.y_velocity * dt)
    player.y_velocity = player.y_velocity + player.gravity * dt

    local colliding = false
    for i, o in ipairs(obstacles) do
        if (collide(player, o)) then
            player.y_velocity = 0
            colliding = true
            break
        end
    end

    if (colliding) then
        player:setX(player.oldx)
        player:setY(player.oldy)
        player.y_velocity = 0
    end

    -- clean original values for next iteration
    player.oldx = player.x
    player.oldy = player.y
end


local function drawBox(b)
    love.graphics.setColor(200, 200, 200)
    love.graphics.rectangle('fill', b.x, screen.dy - b.y - b.dy, b.dx, b.dy)
end

function love.draw()

    love.graphics.draw(zero.image, --The image
        --Current frame of the current animation
        zero.animations.idle[1],
        player.x,
        player.y)

    drawBox(platform)

    drawBox(player)
    -- love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 32)

    for i, o in ipairs(obstacles) do
        drawBox(o)
    end
end
