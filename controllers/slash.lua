local control = require("control")


local brain = {character=nil}

function brain.newInstance(origin)

    local slash = {}

    slash.x = origin.x
    slash.y = origin.y
    slash.orientation = origin.orientation
    slash.dx = 0
    slash.dy = 0
    slash.state = "idle"

    return slash
end

function brain.controller(slash, player, map, screen)

    local controller = {}

    local started = false

    function controller.update(dt)

        local events = {}

        local slashBox = player.frame.attackbox

        if slashBox ~= nil then
            started = true

            slash.x, slash.y = control.actionOrigin(player)

            slash.dx = slashBox.w
            slash.dy = slashBox.h

        elseif started == true then
            events.slashComplete = { from = slash }
        end

        return events
    end

    return controller
end


return brain