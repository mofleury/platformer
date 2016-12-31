local control = {}


buttons_released = {}
buttons_actionable = {}

action_buttons = { 's', 'a' }

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

function control.player(player)
    local controller = {}

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

    function controller.update(dt)
        update_buttons(love.keyboard)

        if love.keyboard.isDown('right') or love.keyboard.isDown('left') then
            free_powerjump = false
        end

        --may need to cancel dash
        if love.keyboard.isDown('right') and player.orientation == -1 then
            dash_timer = 0
            dashing = false
        end
        if love.keyboard.isDown('left') and player.orientation == 1 then
            dash_timer = 0
            dashing = false
        end

        if was_pressed('s') then
            if dash_timer <= 0 and dash_credit > 0 and not powerjump and not walling then
                dashing = true
                dash_timer = 0.25
                dash_credit = dash_credit - 1
            end
        elseif not airborne or walling then
            dash_credit = 1
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

        if love.keyboard.isDown('right') and wall_jump_timer <= 0 then

            player.orientation = 1

            player.x = (player.x + x_speed * dt)

            moving = true
        elseif love.keyboard.isDown('left') and wall_jump_timer <= 0 then

            player.orientation = -1

            player.x = (player.x - (x_speed * dt))

            moving = true
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

        if was_pressed('a') then
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
                    if love.keyboard.isDown('s') then
                        powerjump = true
                        free_powerjump = true
                        x_speed = dashing_speed
                    end
                end

                walling = false
            end
        elseif y_velocity > 0 and not love.keyboard.isDown('a') then
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
                    if airborne and love.keyboard.isDown('left') then
                        player.state = "wall_landing"
                        walling = true
                        if not love.keyboard.isDown('s') then
                            powerjump = false
                            free_powerjump = false
                        end
                    end
                else -- right
                    player.x = (details.right.x - player.dx - 1)
                    if airborne and love.keyboard.isDown('right') then
                        player.state = "wall_landing"
                        walling = true

                        if not love.keyboard.isDown('s') then
                            powerjump = false
                            free_powerjump = false
                        end
                    end
                end
            end
            if details.bottom then
                y_velocity = 0
                if airborne then
                    player.state = "landing"
                end

                player.y = (details.bottom.y + details.bottom.dy)
                airborne = false
                powerjump = false
                free_powerjump = false
                walling = false
            end
            if details.top then
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
    end

    return controller
end

return control

