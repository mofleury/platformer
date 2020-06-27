local control = require("control")

local brain = {character="resources/characters/rabbit.lua"}

function brain.newInstance(origin)

    local rabbit = {};

    rabbit.state = "idle"

    rabbit.x = origin.x
    rabbit.y = origin.y
    rabbit.dx = 25 rabbit.dy = 52

    return rabbit
end

function brain.controller(rabbit, player, map, screen)

    local controller = {}

    local speed = 1
    local jump_impulsion = 200

    local y_velocity = 0

    local airborne = false
    local jump_orientation = 1

    function controller.update(dt)


        rabbit.orientation = jump_orientation


        if (airborne) then
            rabbit.x = rabbit.x + speed * jump_orientation
            y_velocity = y_velocity + control.gravity * dt
        else
            y_velocity = jump_impulsion
            jump_orientation = control.sign(player.x - rabbit.x)
        end


        rabbit.y = (rabbit.y + y_velocity * dt)

        local colliding, details = control.mapContacts(map, rabbit)


        if (not colliding or details.bottom == nil) then
            airborne = true
        else
            if airborne then
                rabbit.state = "landing"
            end

            airborne = false
            y_velocity = 0
            rabbit.y = (details.bottom.y + details.bottom.dy)
        end

        if colliding then
            if details.left and jump_orientation == -1 and details.left.y >= rabbit.y then
                rabbit.x = (details.left.x + details.left.dx + 1)
            end
            if details.right and jump_orientation == 1 and details.right.y >= rabbit.y then
                rabbit.x = (details.right.x - rabbit.dx - 1)
            end
        end

        if airborne then
            if y_velocity > 0 then
                rabbit.state = "jumping"
            else
                rabbit.state = "falling"
            end
        else
            rabbit.state = "idle"
        end
    end

    return controller
end

return brain