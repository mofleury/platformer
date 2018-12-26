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

    local walling_speed_cap = -200
    local running_speed = 200
    local dashing_speed = 450
    local gravity = -800
    local jump_height = 300


    local x_speed = 200

    local airborne = true

    local y_velocity = 0


    local dash_timer = 0
    local dash_credit = 1
    local wall_jump_timer = 0

    local powerjump = false
    local free_powerjump = false

    local dashing = false
    local walling = false
    local slashing = false

    local shooting_timer = 0
    local shooting_duration = 0.25

    local slashing_timer = 0
    local slashing_duration = 0.7
    local slashin_freeze = 0.5

    function controller.update(dt)

        local events = {}

        update_buttons(love.keyboard)


        slashing_timer = slashing_timer - dt
        if slashing_timer <= 0 and slashing then
            slashing = false
        end

        shooting_timer = shooting_timer - dt
        if shooting_timer <= 0 and player.subState == "shooting" then
            player.subState = nil
        end

        local slash_ready = slashing_timer <= (slashing_duration - slashin_freeze)

        -- only allow player to move if not in slashing freeze
        local frozen_slashing = not airborne and not slash_ready
        if frozen_slashing then
            -- consume inputs
            for key, value in pairs(buttons_actionable) do
                buttons_actionable[key] = false
            end
        else
            if was_pressed(keys.slash) then
                if slash_ready then
                    slashing = true
                    events.playerSlash = { from = player, orientation = player.orientation }
                    slashing_timer = slashing_duration
                    if not airborne then
                        frozen_slashing = true
                    end
                end
            end

            if was_pressed(keys.shoot) then
                local o
                if walling then
                    o = -player.orientation
                else
                    o = player.orientation
                end
                events.playerShot = { from = player, orientation = o }
                player.subState = "shooting"
                shooting_timer = shooting_duration
            end

            if love.keyboard.isDown(keys.right) or love.keyboard.isDown(keys.left) then
                free_powerjump = false
            end

            --may need to cancel dash
            if love.keyboard.isDown(keys.right) and player.orientation == -1 then
                dash_timer = 0
                dashing = false
            end
            if love.keyboard.isDown(keys.left) and player.orientation == 1 then
                dash_timer = 0
                dashing = false
            end

            if was_pressed(keys.dash) then
                if dash_timer <= 0 and dash_credit > 0 and not powerjump and not walling then
                    dashing = true
                    dash_timer = 0.25
                    dash_credit = dash_credit - 1
                end
            elseif not airborne or walling then
                dash_credit = 1
            end
        end

        if (dash_timer > 0) then
            dash_timer = dash_timer - dt
        end
        if (wall_jump_timer > 0) then
            wall_jump_timer = wall_jump_timer - dt
        end


        if (dash_timer > 0) then

            x_speed = dashing_speed
            if not powerjump then
                y_velocity = 0
            end
        elseif not powerjump then
            dashing = false
            x_speed = running_speed
        end


        local moving = false

        if love.keyboard.isDown(keys.right) and wall_jump_timer <= 0 and not frozen_slashing then

            player.orientation = 1

            player.x = (player.x + x_speed * dt)

            moving = true
            if not airborne then
                slashing = false
            end
        elseif love.keyboard.isDown(keys.left) and wall_jump_timer <= 0 and not frozen_slashing then

            player.orientation = -1

            player.x = (player.x - (x_speed * dt))

            moving = true
            if not airborne then
                slashing = false
            end
        elseif wall_jump_timer > 0 then
            player.x = (player.x - player.orientation * (x_speed * dt))
        elseif free_powerjump then
            player.x = (player.x + player.orientation * (x_speed * dt))
        elseif dashing then

            player.x = (player.x + player.orientation * (x_speed * dt))
        elseif not (airborne or player.state == "landing") then
            player.state = "idle"
        end

        if dashing then
            player.state = "dashing"
        elseif not airborne then
            if moving then
                player.state = "running"
            end
        elseif not dashing then
            if y_velocity > 0 then
                player.state = "jumping"
            else
                player.state = "falling"
            end
        end
        debug_data.slashing = slashing
        debug_data.airborne = airborne
        if slashing then
            player.state = "slashing"
            if airborne then
                player.subState = "airborne"
            else
                player.subState = nil
            end
        end

        if was_pressed(keys.jump) then
            if not airborne or walling then
                y_velocity = jump_height
                airborne = true


                if dashing then
                    powerjump = true
                    free_powerjump = true
                    dashing = false
                end

                if walling then
                    player.state = "wall_jumping"
                    wall_jump_timer = 0.2

                    -- when walling, powerjump can be done without releasing dash button
                    if love.keyboard.isDown(keys.dash) then
                        powerjump = true
                        free_powerjump = true
                        x_speed = dashing_speed
                    end
                end

                walling = false
            end
        elseif y_velocity > 0 and not love.keyboard.isDown(keys.jump) then
            -- mid jump, but not hitting jum key anymore : small jump
            y_velocity = 0
            --        player.state = "landing"
        end

        player.y = (player.y + y_velocity * dt)

        if airborne then
            y_velocity = y_velocity + gravity * dt
            if walling then
                y_velocity = math.max(walling_speed_cap, y_velocity)
            end
        end

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

                        -- if just landing on the wall, dont move up or down
                        if not walling and wall_jump_timer < 0 then
                            y_velocity = 0
                        end

                        walling = true
                        if not love.keyboard.isDown(keys.dash) then
                            powerjump = false
                            free_powerjump = false
                        end
                    end
                else -- right
                    player.x = (details.right.x - player.dx - 1)
                    if airborne and love.keyboard.isDown(keys.right) then
                        player.state = "wall_landing"
                        walling = true

                        if not love.keyboard.isDown(keys.dash) then
                            powerjump = false
                            free_powerjump = false
                        end
                    end
                end
            end
            if details.bottom and not alignedVertically(details) then
                y_velocity = 0
                if airborne and not slashing then
                    player.state = "landing"
                end

                player.y = (details.bottom.y + details.bottom.dy)
                airborne = false
                powerjump = false
                free_powerjump = false
                walling = false
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
        else
            walling = false
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

