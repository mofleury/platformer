platform = {}
player = {}

obstacles= {}

screen = {}

function love.load()
	if arg[#arg] == "-debug" then require("mobdebug").start() end

	screen.dx = love.graphics.getWidth()
	screen.dy = love.graphics.getHeight()

	platform.dx = love.graphics.getWidth()
	platform.dy = 20

	platform.x = 0
	platform.y = 0

	player.x = screen.dx / 2
	player.y = platform.y + platform.dy
	player.dx = 32
	player.dy = 32

	player.speed = 200
 
	player.img = love.graphics.newImage('resources/purple.png')
 
	player.ground = player.y-1
 
	player.y_velocity = 0
 
	player.jump_height = 300
	player.gravity = -800

	table.insert(obstacles, {x=10, y=30, dx=10, dy=20})

end
 
function love.update(dt)

	if love.keyboard.isDown('d') then
		if player.x < (screen.dx - player.dx) then
			player.x = player.x + (player.speed * dt)
		end
	elseif love.keyboard.isDown('a') then
		if player.x > 0 then 
			player.x = player.x - (player.speed * dt)
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
 
	if player.y >= player.ground then
		player.y = player.y + player.y_velocity * dt
		player.y_velocity = player.y_velocity + player.gravity * dt
	end
 
	if player.y <= player.ground then
		player.y_velocity = 0
    	player.y = player.ground
	end
end


local function drawBox(b)
	love.graphics.setColor(200, 200, 200)
	love.graphics.rectangle('fill', b.x, screen.dy- b.y -b.dy, b.dx, b.dy)
end

function love.draw()


	drawBox(platform)

	drawBox(player)
	-- love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 32)

	for i,o in ipairs(obstacles) do
		drawBox(o)
	end
end
