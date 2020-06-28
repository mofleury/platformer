local control = require("control")


local brain = { character = "resources/characters/walker.lua" }

local speed = 1

local approach_distance = 100

local detect_distance = 200

local wander_duration = 1.5
local pause_duration = 0.5

local behaviors = {}

function brain.newInstance(origin)

    local walker = {}

    walker.state = "walking"

    walker.x = origin.x + 100
    walker.y = origin.y

    walker.dx = 25 walker.dy = 52

    walker.y_velocity = 0

    walker.orientation = 1

    walker.behavior = behaviors.patrol

    walker.last_transition = 0
    walker.next_transiton = 0

    return walker
end

local function move_if_possible(walker, new_x, map)
    local has_footing = control.has_footing(walker, new_x, map)

    if (has_footing) then
        walker.x = new_x
        return true
    end

    return false
end

function behaviors.approach(walker, player, map, dt)
    walker.orientation = control.sign(player.x - walker.x)

    local distance = math.abs(player.x - walker.x)

    local new_x = walker.x + speed * walker.orientation

    if (distance > approach_distance) then
        move_if_possible(walker, new_x, map)
    end

    if distance > detect_distance then
        return behaviors.pause
    else
        return behaviors.approach
    end
end

function behaviors.pause(walker, player, map, dt)
    if walker.last_transition > pause_duration then
        walker.orientation = -1 * walker.orientation
        return behaviors.patrol
    else
        return behaviors.pause
    end
end

function behaviors.patrol(walker, player, map, dt)


    if walker.last_transition > wander_duration then
        return behaviors.pause
    else
        local new_x = walker.x + speed * walker.orientation
        if move_if_possible(walker, new_x, map) then
            return behaviors.patrol
        else
            return behaviors.pause
        end
    end
end


function brain.controller(walker, player, map, screen)

    local controller = {}

    function controller.update(dt)

        local old_x = walker.x

        local distance = math.abs(player.x - walker.x)


        local new_behavior = nil

        if distance < detect_distance then
            walker.behavior = behaviors.approach
        end

        walker.last_transition = walker.last_transition + dt

        new_behavior = walker.behavior(walker, player, map, dt)
        if new_behavior ~= walker.behavior then
            walker.behavior = new_behavior
            walker.last_transition = 0
        end

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