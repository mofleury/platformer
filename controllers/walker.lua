local control = require("control")


local brain = {character="resources/characters/walker.lua"}

function brain.newInstance()
    return {}
end

function brain.controller(walker, player, map)

    local controller = {}

    local speed = 1

    local y_velocity = 0

    walker.state = "walking"

    walker.x = player.x + 100
    walker.y = player.y
    walker.dx = 25 walker.dy = 52

    function controller.update(dt)

        local orientation = control.sign(player.x - walker.x)

        local distance = math.abs(player.x - walker.x)

        walker.orientation = orientation

        local moving = false

        if (distance > 10) then
            moving = true

            walker.x = walker.x + speed * orientation
        end

        walker.y = (walker.y + y_velocity * dt)

        local colliding, details = control.mapContacts(map, walker)


        if (not colliding or details.bottom == nil) then
            y_velocity = y_velocity + control.gravity * dt
        else
            y_velocity = 0
            walker.y = (details.bottom.y + details.bottom.dy)
        end

        if colliding then
            if details.left and orientation == -1 and details.left.y >= walker.y then
                moving = false
                walker.x = (details.left.x + details.left.dx + 1)
            end
            if details.right and orientation == 1 and details.right.y >= walker.y then
                moving = false
                walker.x = (details.right.x - walker.dx - 1)
            end
        end

        if moving then
            walker.state = "walking"
        else
            walker.state = "idle"
        end
    end

    return controller
end

return brain