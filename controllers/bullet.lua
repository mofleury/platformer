local control = require("control")


local brain = {character="resources/characters/bullet.lua"}

function brain.newInstance(origin)

    local bullet = {}

    bullet.x = origin.x
    bullet.y = origin.y
    bullet.orientation = origin.orientation
    bullet.dx = 8
    bullet.dy = 8
    bullet.state = "idle"

    return bullet
end

function brain.controller(bullet, player, map, screen)

    local controller = {}

    local speed = 10
    local margin = 100


    function controller.update(dt)

        local events = {}

        bullet.x = bullet.x + speed * bullet.orientation

        local obstacles = map.obstaclesAround(bullet, 3)

        -- bullets should not go through walls
        local colliding, details = control.mapContacts(map, bullet)

        if colliding or (bullet.x < screen.x - margin) or (bullet.x > screen.x + screen.dx + margin) then
            events.bulletLost = { from = bullet }
        end

        return events
    end

    return controller
end


return brain