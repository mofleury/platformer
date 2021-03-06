local control = {}

local collision = require "collision"

local buttons_released = {}
local buttons_actionable = {}

local action_buttons = {}

control.gravity = -800

function control.sign(x)
    if x < 0 then
        return -1
    elseif x > 0 then
        return 1
    else
        return 0
    end
end

function control.has_footing(walker, new_x, map)
    local around = {}

    local footing = false

    for i, o in ipairs(map.obstaclesAround(walker, 0)) do
        if (o.y < walker.y) then
            around[i] = o
            if ((walker.orientation == -1 and o.x <= new_x) or (walker.orientation == 1 and  o.x + o.dx > new_x + walker.dx )) then
                footing = true
            end
        end
    end

    return footing
end

function control.constrain_walker_update(walker, map, dt)

    walker.y = (walker.y + walker.y_velocity * dt)

    local colliding, details = control.mapContacts(map, walker)


    if (not colliding or details.bottom == nil) then
        walker.y_velocity = walker.y_velocity + control.gravity * dt
    else
        walker.y_velocity = 0
        walker.y = (details.bottom.y + details.bottom.dy)
    end

    if colliding then

        if walker.orientation == -1 and (details.left and details.left.y >= walker.y) then
           walker.x = (details.left.x + details.left.dx + 1)
        end
        if walker.orientation == 1 and  (details.right and details.right.y >= walker.y) then
           walker.x = (details.right.x - walker.dx - 1)
        end

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

function control.mapContacts(map, object)

    local obstacles = map.obstaclesAround(object, 3)

    local colliding, details = false, {}
    for i, o in ipairs(obstacles) do
        local c, d = collision.collide(object, o)
        if (c) then
            colliding = true
            for k, e in pairs(d) do
                details[k] = o
                --                table.insert(debug_data.colliding, o)
            end
        end
    end

    return colliding, details
end



function control.player(player, map, keys)

    table.insert(action_buttons, keys.jump)
    table.insert(action_buttons, keys.dash)
    table.insert(action_buttons, keys.shoot)
    table.insert(action_buttons, keys.slash)

    local controller = {}

    local jump_height = 300

    local running_speed = 200
    local dashing_speed = 450

    local dashing_duration = 0.35
    local shooting_duration = 0.25
    local slashing_duration = 0.7
    local slashin_freeze = 0.5
    local wall_jump_duration = 0.2
    local wall_land_stick = 0.2
    local walling_speed_cap = -200


    local airborne = true
    local dash_credit = 1
    local timeSinceTransition = 0
    local x_velocity = 0
    local y_velocity = 0

    local readyState = {}
    local dashingState = {}
    local powerJumpingState = {}
    local slashingState = {}
    local wallingState = {}
    local wallJumpingState = {}

    local dashIfAvailable = function()
        if not airborne then
            return dashingState
        elseif (dash_credit > 0) then
            dash_credit = dash_credit - 1;
            return dashingState

        else
            return nil
        end
    end

    readyState.name = "ready"
    readyState.onDash = dashIfAvailable
    readyState.onSlash = slashingState
    readyState.onShoot = readyState
    readyState.onLand = readyState
    readyState.onWall = wallingState
    readyState.onJump = function()
        if airborne then
            return nil
        end
        return readyState
    end
    readyState.forceMove = false
    readyState.x_speed = running_speed
    readyState.y_velocity_cap = function()
        return y_velocity
    end
    readyState.after = function()
        return readyState
    end
    readyState.canMove = function(backwards, movePressed)
        return readyState
    end
    readyState.preserveXVelocity = function(backwards, movePressed)
        return airborne and (not backwards or not movePressed)
    end


    dashingState.name = "dashing"
    dashingState.onDash = function() return nil end
    dashingState.onSlash = nil
    dashingState.onShoot = dashingState
    dashingState.onLand = dashingState
    dashingState.onWall = wallingState
    dashingState.forceMove = true
    dashingState.onJump = function()
        if airborne then
            return nil
        end
        return powerJumpingState
    end
    dashingState.x_speed = dashing_speed
    dashingState.y_velocity_cap = function()
        return 0
    end
    dashingState.after = function()
        if (timeSinceTransition <= dashing_duration) then
            return dashingState
        end
        return readyState
    end
    dashingState.canMove = function(backwards, movePressed)
        -- dash can be cancelled by going backwards
        if backwards then
            return readyState
        end
        return nil
    end
    dashingState.preserveXVelocity = function(backwards, movePressed)
        return false
    end

    powerJumpingState.name = "powerJumping"
    powerJumpingState.onDash = function() return nil end
    powerJumpingState.onSlash = slashingState
    powerJumpingState.onShoot = powerJumpingState
    powerJumpingState.onLand = readyState
    powerJumpingState.onWall = wallingState
    powerJumpingState.forceMove = true
    powerJumpingState.onJump = function()
        return nil
    end
    powerJumpingState.x_speed = dashing_speed
    powerJumpingState.y_velocity_cap = function()
        return y_velocity
    end
    powerJumpingState.after = function()
        return powerJumpingState
    end
    powerJumpingState.canMove = function(backwards, movePressed)
        -- dash can be cancelled by going backwards
        if backwards then
            return readyState
        end
        return nil
    end
    powerJumpingState.preserveXVelocity = function(backwards, movePressed)
        return airborne and (not backwards or not movePressed)
    end

    slashingState.name = "slashing"
    slashingState.onDash = function() return nil end
    slashingState.onSlash = nil
    slashingState.onShoot = nil
    slashingState.onLand = slashingState
    slashingState.onWall = wallingState
    slashingState.forceMove = false
    slashingState.onJump = function()
        if timeSinceTransition > slashin_freeze then
            return readyState
        end
        return nil
    end
    slashingState.x_speed = running_speed
    slashingState.y_velocity_cap = function()
        return y_velocity
    end
    slashingState.after = function()
        if (timeSinceTransition <= slashing_duration) then
            return slashingState
        end
        return readyState
    end
    slashingState.canMove = function(backwards, movePressed)
        -- only allow player to move if not in slashing freeze
        if timeSinceTransition <= slashin_freeze then
            if airborne then
                return slashingState
            end
            return nil
        end
        return readyState
    end
    slashingState.preserveXVelocity = function(backwards, movePressed)
        return airborne and (not backwards or not movePressed)
    end

    wallingState.name = "walling"
    wallingState.onDash = function() return nil end
    wallingState.onSlash = nil
    wallingState.onShoot = wallingState
    wallingState.onLand = readyState
    wallingState.forceMove = false
    wallingState.onWall = wallingState
    wallingState.onJump = function()
        return wallJumpingState
    end
    wallingState.x_speed = running_speed
    wallingState.y_velocity_cap = function()
        if timeSinceTransition <= wall_land_stick then
            return 0
        end
        return math.max(y_velocity, walling_speed_cap)
    end
    wallingState.after = function()
        return wallingState
    end
    wallingState.canMove = function(backwards, movePressed)
        if not backwards and movePressed then
            return wallingState
        end
        return readyState
    end
    wallingState.preserveXVelocity = function(backwards, movePressed)
        return false
    end

    wallJumpingState.name = "wallJumping"
    wallJumpingState.onDash = dashIfAvailable
    wallJumpingState.onSlash = slashingState
    wallJumpingState.onShoot = wallJumpingState
    wallJumpingState.onLand = readyState
    wallJumpingState.onWall = wallJumpingState
    wallJumpingState.forceMove = true
    wallJumpingState.onJump = function()
        return nil
    end
    wallJumpingState.x_speed = -running_speed
    wallJumpingState.y_velocity_cap = function()
        return y_velocity
    end
    wallJumpingState.after = function()
        if timeSinceTransition <= wall_jump_duration then
            return wallJumpingState
        end
        return readyState
    end
    wallJumpingState.canMove = function(backwards, movePressed)
        if timeSinceTransition > wall_jump_duration and backwards then
            return readyState
        end
        return nil
    end
    wallJumpingState.preserveXVelocity = function(backwards, movePressed)
        return false
    end



    local state = readyState


    local shooting_timer = 0

    local function setState(s)
        if state ~= s then
            state = s
            timeSinceTransition = 0
        end
    end


    function controller.update(dt)

        --debug_data.state = state.name
        --debug_data.airborne = airborne

        --debug_data.dash_credit = dash_credit

        local events = {}

        update_buttons(love.keyboard)

        timeSinceTransition = timeSinceTransition + dt

        shooting_timer = shooting_timer - dt
        if shooting_timer <= 0 and player.subState["shooting"] == true then
            player.subState["shooting"] = nil
        end

        local movePressed = love.keyboard.isDown(keys.right) or love.keyboard.isDown(keys.left)

        local backwards = false

        if love.keyboard.isDown(keys.right) and player.orientation == -1 then
            backwards = true
        end
        if love.keyboard.isDown(keys.left) and player.orientation == 1 then
            backwards = true
        end

        local stateBefore = state
        setState(state.after())

        if state ~= stateBefore then
            if stateBefore == wallJumpingState and (backwards or not movePressed) then
                -- need to hack orientation if finishing a wall jump to be able to powerjump from wall
                backwards = false
                player.orientation = -player.orientation
            elseif stateBefore == dashingState then
                -- need to cancel speed after a dash
                x_velocity = running_speed
            end
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


        if was_pressed(keys.dash) then
            local afterDash = state.onDash()
            if afterDash ~= nil then
                setState(afterDash)
            end
        end

        local moving = false


        local afterMove = state.canMove(backwards, movePressed)
        if afterMove ~= nil then
            setState(afterMove)
        end

        --        debug_data.x_velocity = x_velocity
        --        debug_data.backwards = backwards

        if state.preserveXVelocity(backwards, movePressed) then
            -- preserve velocity
            x_velocity = math.max(state.x_speed, math.abs(x_velocity))
        else
            x_velocity = state.x_speed
        end
        if state == wallJumpingState and love.keyboard.isDown(keys.dash) then
            x_velocity = -dashing_speed
        end


        if love.keyboard.isDown(keys.right) and afterMove ~= nil then
            player.orientation = 1

            player.x = (player.x + x_velocity * dt)

            moving = true

        elseif love.keyboard.isDown(keys.left) and afterMove ~= nil then
            player.orientation = -1

            player.x = (player.x - (x_velocity * dt))

            moving = true

        elseif state.forceMove then
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

        local afterJump = state.onJump()
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
            y_velocity = y_velocity + control.gravity * dt
        end
        y_velocity = state.y_velocity_cap()

        local obstacles = map.obstaclesAround(player, 3)

        local colliding, details = control.mapContacts(map, player)

        --        debug_data[player] = { colliding = colliding, details = details }

        if (colliding) then

            if details.bottom then
                dash_credit = 1

                -- corner case : when running on the edge of a block towards the block, we can stay in levitation while running
                -- in this case, consider collision on bottom only
                if details.left == details.bottom then
                    details.left = nil
                elseif details.right == details.bottom then
                    details.right = nil
                end
            end

            if (details.left or details.right) then
                dash_credit = 1
                if (details.left) then
                    player.x = (details.left.x + details.left.dx + 1)
                    if airborne and love.keyboard.isDown(keys.left) then
                        player.state = "wall_landing"
                        local afterWall = state.onWall
                        if (afterWall ~= nil) then
                            setState(afterWall)
                        end
                        y_velocity = state.y_velocity_cap()
                    end
                else -- right
                    player.x = (details.right.x - player.dx - 1)
                    if airborne and love.keyboard.isDown(keys.right) then
                        player.state = "wall_landing"
                        local afterWall = state.onWall
                        if (afterWall ~= nil) then
                            setState(afterWall)
                        end
                        y_velocity = state.y_velocity_cap()
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

function control.actionOrigin(object)
    local attackbox = object.frame.attackbox

    local x, y = object.x, object.y + object.dy / 2

    if attackbox ~= nil then

        if object.orientation == 1 then
            x = object.x + object.dx / 2 - object.frame.anchor.x + attackbox.x
        else
            x = object.x + object.dx / 2 + object.frame.anchor.x - attackbox.x - attackbox.w
        end
        y = object.y - object.frame.anchor.y + attackbox.y
    end
    return x, y
end


return control

