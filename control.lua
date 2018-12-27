local control = {}

local collision = require "collision"

local buttons_released = {}
local buttons_actionable = {}

local action_buttons = {}

local function sign(x)
    if x < 0 then
        return -1
    elseif x > 0 then
        return 1
    else
        return 0
    end
end



local function alignedVertically(details)
    if (details.bottom ~= nil) then
        return ((details.left ~= nil and details.left.x + details.left.dx == details.bottom.x + details.bottom.dx)
                or (details.right ~= nil and details.right.x == details.bottom.x))
    elseif details.top ~= nil then
        return ((details.left ~= nil and details.left.x + details.left.dx == details.top.x + details.top.dx)
                or (details.right ~= nil and details.right.x == details.top.x))
    end
end

local function update_buttons(keyboard)

    for i, b in ipairs(action_buttons) do
        if keyboard.isDown(b) then
            if buttons_released[b] == true then
                buttons_actionable[b] = true
                buttons_released[b] = false
            end
        else
            buttons_released[b] = true
        end
    end
end

local function was_pressed(button)
    if buttons_actionable[button] == true then
        buttons_actionable[button] = false
        return true
    end
    return false
end




function control.player(player, map, keys)

    table.insert(action_buttons, keys.jump)
    table.insert(action_buttons, keys.dash)
    table.insert(action_buttons, keys.shoot)
    table.insert(action_buttons, keys.slash)

    local controller = {}
    controller.debug_data = {}

    local gravity = -800
    local jump_height = 300

    local running_speed = 200
    local dashing_speed = 450

    local dashing_duration = 0.25
    local shooting_duration = 0.25
    local slashing_duration = 0.7
    local slashin_freeze = 0.5
    local wall_jump_duration = 0.2
    local wall_land_stick = 0.2
    local walling_speed_cap = -200

    local readyState = {}
    local dashingState = {}
    local powerJumpingState = {}
    local slashingState = {}
    local wallingState = {}
    local wallJumpingState = {}

    readyState.name = "ready"
    readyState.onDash = dashingState
    readyState.onSlash = slashingState
    readyState.onShoot = readyState
    readyState.onLand = readyState
    readyState.onWall = wallingState
    readyState.onJump = function(dt, airborne)
        if airborne then
            return nil
        end
        return readyState
    end
    readyState.forceMove = false
    readyState.x_speed = running_speed
    readyState.y_velocity_cap = function(dt, y_velocity)
        return y_velocity
    end
    readyState.after = function(dt)
        return readyState
    end
    readyState.canMove = function(dt, airborne, backwards, movePressed)
        return readyState
    end


    dashingState.name = "dashing"
    dashingState.onDash = nil
    dashingState.onSlash = nil
    dashingState.onShoot = dashingState
    dashingState.onLand = dashingState
    dashingState.onWall = wallingState
    dashingState.forceMove = true
    dashingState.onJump = function(dt, airborne)
        if airborne then
            return nil
        end
        return powerJumpingState
    end
    dashingState.x_speed = dashing_speed
    dashingState.y_velocity_cap = function(dt, y_velocity)
        return 0
    end
    dashingState.after = function(dt)
        if (dt <= dashing_duration) then
            return dashingState
        end
        return readyState
    end
    dashingState.canMove = function(dt, airborne, backwards, movePressed)
        -- dash can be cancelled by going backwards
        if backwards then
            return readyState
        end
        return nil
    end

    powerJumpingState.name = "powerJumping"
    powerJumpingState.onDash = nil
    powerJumpingState.onSlash = slashingState
    powerJumpingState.onShoot = powerJumpingState
    powerJumpingState.onLand = readyState
    powerJumpingState.onWall = wallingState
    powerJumpingState.forceMove = true
    powerJumpingState.onJump = function(dt, airborne)
        return nil
    end
    powerJumpingState.x_speed = dashing_speed
    powerJumpingState.y_velocity_cap = function(dt, y_velocity)
        return y_velocity
    end
    powerJumpingState.after = function(dt)
        return powerJumpingState
    end
    powerJumpingState.canMove = function(dt, airborne, backwards, movePressed)
        -- dash can be cancelled by going backwards
        if backwards then
            return readyState
        end
        return nil
    end

    slashingState.name = "slashing"
    slashingState.onDash = nil
    slashingState.onSlash = nil
    slashingState.onShoot = nil
    slashingState.onLand = slashingState
    slashingState.onWall = wallingState
    slashingState.forceMove = false
    slashingState.onJump = function(dt, airborne)
        if dt > slashin_freeze then
            return readyState
        end
        return nil
    end
    slashingState.x_speed = running_speed
    slashingState.y_velocity_cap = function(dt, y_velocity)
        return y_velocity
    end
    slashingState.after = function(dt)
        if (dt <= slashing_duration) then
            return slashingState
        end
        return readyState
    end
    slashingState.canMove = function(dt, airborne, backwards, movePressed)
        -- only allow player to move if not in slashing freeze
        if dt <= slashin_freeze then
            if airborne then
                return slashingState
            end
            return nil
        end
        return readyState
    end

    wallingState.name = "walling"
    wallingState.onDash = nil
    wallingState.onSlash = nil
    wallingState.onShoot = wallingState
    wallingState.onLand = readyState
    wallingState.forceMove = false
    wallingState.onWall = wallingState
    wallingState.onJump = function(dt, airborne)
        return wallJumpingState
    end
    wallingState.x_speed = running_speed
    wallingState.y_velocity_cap = function(dt, y_velocity)
        if dt <= wall_land_stick then
            return 0
        end
        return math.max(y_velocity, walling_speed_cap)
    end
    wallingState.after = function(dt)
        return wallingState
    end
    wallingState.canMove = function(dt, airborne, backwards, movePressed)
        if not backwards and movePressed then
            return wallingState
        end
        return readyState
    end

    wallJumpingState.name = "wallJumping"
    wallJumpingState.onDash = dashingState
    wallJumpingState.onSlash = slashingState
    wallJumpingState.onShoot = wallJumpingState
    wallJumpingState.onLand = readyState
    wallJumpingState.onWall = wallJumpingState
    wallJumpingState.forceMove = true
    wallJumpingState.onJump = function(dt, airborne)
        return nil
    end
    wallJumpingState.x_speed = -running_speed
    wallJumpingState.y_velocity_cap = function(dt, y_velocity)
        return y_velocity
    end
    wallJumpingState.after = function(dt)
        if dt <= wall_jump_duration then
            return wallJumpingState
        end
        return readyState
    end
    wallJumpingState.canMove = function(dt, airborne, backwards, movePressed)
        if dt > wall_jump_duration and backwards then
            return readyState
        end
        return nil
    end

    local airborne = true

    local x_velocity = 0
    local y_velocity = 0

    local state = readyState
    local timeSinceTransition = 0

    local shooting_timer = 0

    local function setState(s)
        if state ~= s then
            state = s
            timeSinceTransition = 0
        end
    end


    function controller.update(dt)

        debug_data.state = state.name
        debug_data.airborne = airborne

        local events = {}

        update_buttons(love.keyboard)

        timeSinceTransition = timeSinceTransition + dt

        setState(state.after(timeSinceTransition))


        shooting_timer = shooting_timer - dt
        if shooting_timer <= 0 and player.subState["shooting"] == true then
            player.subState["shooting"] = nil
        end

        local backwards = false

        if love.keyboard.isDown(keys.right) and player.orientation == -1 then
            backwards = true
        end
        if love.keyboard.isDown(keys.left) and player.orientation == 1 then
            backwards = true
        end

        if was_pressed(keys.slash) then
            local next = state.onSlash
            if next ~= nil then
                setState(next)

                events.playerSlash = { from = player, orientation = player.orientation }
            end
        end

        if was_pressed(keys.shoot) then
            local o
            if state == wallingState then
                o = -player.orientation
            else
                o = player.orientation
            end
            events.playerShot = { from = player, orientation = o }
            player.subState["shooting"] = true
            shooting_timer = shooting_duration
        end

        local afterDash = state.onDash
        if was_pressed(keys.dash) and afterDash ~= nil then
            setState(afterDash)
        end

        local moving = false


        local movePressed = love.keyboard.isDown(keys.right) or love.keyboard.isDown(keys.left)
        local afterMove = state.canMove(timeSinceTransition, airborne, backwards, movePressed)
        if afterMove ~= nil then
            setState(afterMove)
        end

        debug_data.x_velocity = x_velocity


        local powerSlash = state == slashingState and airborne and not backwards
        if powerSlash then
            -- preserve velocity
        else
            x_velocity = state.x_speed
        end


        if love.keyboard.isDown(keys.right) and afterMove ~= nil then
            player.orientation = 1

            player.x = (player.x + x_velocity * dt)

            moving = true

        elseif love.keyboard.isDown(keys.left) and afterMove ~= nil then
            player.orientation = -1

            player.x = (player.x - (x_velocity * dt))

            moving = true

        elseif state.forceMove or powerSlash then
            player.x = (player.x + player.orientation * (x_velocity * dt))
        elseif not (airborne or player.state == "landing") then
            player.state = "idle"
        end

        if state == dashingState then
            player.state = "dashing"
        elseif not airborne then
            if moving then
                player.state = "running"
            end
        elseif state ~= dashingState then
            if y_velocity > 0 then
                player.state = "jumping"
            else
                player.state = "falling"
            end
        end

        if state == slashingState then
            player.state = "slashing"
            if airborne then
                player.subState["airborne"] = true
            else
                player.subState["airborne"] = nil
            end
        end

        local afterJump = state.onJump(timeSinceTransition, airborne)
        if was_pressed(keys.jump) and afterJump ~= nil then

            setState(afterJump)

            y_velocity = jump_height
            airborne = true


            if afterJump == wallJumpingState then
                player.state = "wall_jumping"

                -- when walling, powerjump can be done without releasing dash button
                --                    if love.keyboard.isDown(keys.dash) then
                --                        powerjump = true
                --                        --x_speed = dashing_speed
                --                    end
            end

        elseif y_velocity > 0 and not love.keyboard.isDown(keys.jump) then
            -- mid jump, but not hitting jum key anymore : small jump
            y_velocity = 0
        end

        player.y = (player.y + y_velocity * dt)

        if airborne then
            y_velocity = y_velocity + gravity * dt
        end
        y_velocity = state.y_velocity_cap(timeSinceTransition, y_velocity)

        debug_data.colliding = {}

        local obstacles = map.obstaclesAround(player, 3)

        local colliding, details = false, {}
        for i, o in ipairs(obstacles) do
            local c, d = collision.collide(player, o)
            if (c) then
                colliding = true
                for k, e in pairs(d) do
                    details[k] = o
                    --                    table.insert(debug_data.colliding, o)
                end
            end
        end

        --        debug_data[player] = { colliding = colliding, details = details }

        if (colliding) then

            if details.bottom then

                -- corner case : when running on the edge of a block towards the block, we can stay in levitation while running
                -- in this case, consider collision on bottom only
                if details.left == details.bottom then
                    details.left = nil
                elseif details.right == details.bottom then
                    details.right = nil
                end
            end

            if (details.left or details.right) then
                if (details.left) then
                    player.x = (details.left.x + details.left.dx + 1)
                    if airborne and love.keyboard.isDown(keys.left) then
                        player.state = "wall_landing"
                        local afterWall = state.onWall
                        if (afterWall ~= nil) then
                            setState(afterWall)
                        end
                        y_velocity = state.y_velocity_cap(timeSinceTransition, y_velocity)
                    end
                else -- right
                    player.x = (details.right.x - player.dx - 1)
                    if airborne and love.keyboard.isDown(keys.right) then
                        player.state = "wall_landing"
                        local afterWall = state.onWall
                        if (afterWall ~= nil) then
                            setState(afterWall)
                        end
                        y_velocity = state.y_velocity_cap(timeSinceTransition, y_velocity)
                    end
                end
            end
            if details.bottom and not alignedVertically(details) then
                y_velocity = 0
                if airborne then
                    setState(state.onLand)
                    if state ~= slashingState then
                        player.state = "landing"
                    end
                end

                player.y = (details.bottom.y + details.bottom.dy)
                airborne = false
            end
            if details.top and not alignedVertically(details) then
                y_velocity = 0
                player.y = (details.top.y - player.dy - 1)
            end

        elseif not airborne then
            local below = { x = player.x, y = player.y - 2, dx = player.dx, dy = 2 }
            local nothingBelow = true
            for i, o in ipairs(obstacles) do
                if (collision.overlap(below, o)) then
                    nothingBelow = false
                    break
                end
            end

            if nothingBelow then
                airborne = true
            end
        elseif state == wallingState then
            setState(readyState)
        end

        return events
    end

    return controller
end

function control.blob(blob, player, map)

    local controller = {}

    local speed = 1

    function controller.update(dt)

        blob.x = blob.x + speed * sign(player.x - blob.x)
    end

    return controller
end

function control.bullet(bullet, map, screen)

    local controller = {}

    local speed = 10
    local margin = 100

    function controller.update(dt)

        local events = {}

        bullet.x = bullet.x + speed * bullet.orientation

        local obstacles = map.obstaclesAround(bullet, 3)

        -- bullets should not go through walls
        local colliding = false
        for i, o in ipairs(obstacles) do
            local c, d = collision.collide(bullet, o)
            if (c) then
                colliding = true
            end
        end

        if colliding or (bullet.x < screen.x - margin) or (bullet.x > screen.x + screen.dx + margin) then
            events.bulletLost = { from = bullet }
        end

        return events
    end

    return controller
end


local slashBoxes = {
    { x = -5, y = 8, dx = 2, dy = 2 },
    { x = -5, y = 8, dx = 2, dy = 2 },
    { x = -15, y = 8, dx = 23, dy = 20 },
    { x = -15, y = 3, dx = 24, dy = 31 },
    { x = -5, y = 28, dx = 55, dy = 40 },
    { x = 35, y = 3, dx = 40, dy = 49 },
    { x = 35, y = 3, dx = 40, dy = 49 },
    { x = 35, y = 3, dx = 40, dy = 49 },
    { x = 35, y = 3, dx = 40, dy = 9 },
    { x = 35, y = 3, dx = 40, dy = 9 },
    { x = 35, y = 3, dx = 5, dy = 5 },
    { x = 35, y = 3, dx = 5, dy = 5 },
}

function control.slash(slash, player)

    local controller = {}

    local duration = 0
    local slash_total_duration = 0.7

    local initX = player.x
    local initY = player.y

    function controller.update(dt)

        duration = duration + dt

        local events = {}

        local slashBox = slashBoxes[math.min(math.floor(duration / 0.05) + 1, table.getn(slashBoxes))]

        if slash.orientation == 1 then
            slash.x = initX + slashBox.x
        else
            slash.x = initX - slashBox.x - slashBox.dx + player.dx
        end
        slash.y = initY + slashBox.y
        slash.dx = slashBox.dx
        slash.dy = slashBox.dy

        if duration > slash_total_duration or player.x ~= initX or player.y ~= initY then
            events.slashComplete = { from = slash }
        end

        return events
    end

    return controller
end

return control

