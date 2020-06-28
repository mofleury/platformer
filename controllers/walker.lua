local control = require("control")


local brain = { character = "resources/characters/walker.lua" }

local speed = 1

local approach_distance = 100

local behaviors = {}

function brain.newInstance(origin)

    local walker = {}

    walker.state = "walking"

    walker.x = origin.x + 100
    walker.y = origin.y

    walker.dx = 25 walker.dy = 52

    walker.y_velocity = 0

    walker.orientation = 1

    walker.behavior = behaviors.approach

    return walker
end


function behaviors.approach(walker, player, map)
    walker.orientation = control.sign(player.x - walker.x)

    local distance = math.abs(player.x - walker.x)

    local new_x = walker.x + speed * walker.orientation

local has_footing = control.has_footing(walker, new_x, map)

    if (distance > approach_distance and has_footing) then
        walker.x = new_x
    end
end


function brain.controller(walker, player, map, screen)

    local controller = {}

    function controller.update(dt)

       local old_x = walker.x

        walker.behavior(walker, player, map)

       control.constrain_walker_update(walker, map, dt)

        if old_x ~= walker.x then
            walker.state = "walking"
        else
            walker.state = "idle"
        end
    end

    return controller
end

return brain